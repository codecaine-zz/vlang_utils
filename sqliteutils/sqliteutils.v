module sqliteutils

import db.sqlite
import json
import os

// sanitize_identifier validates that a SQL identifier (table/column name) contains
// only safe characters (letters, digits, underscores, hyphens) and is non-empty.
// Table/column identifiers cannot be bound as ? parameters in SQLite, so we validate
// them strictly instead of relying on quote-escaping.
fn sanitize_identifier(name string) !string {
	if name.len == 0 {
		return error('SQL identifier must not be empty')
	}
	for ch in name {
		if !ch.is_letter() && !ch.is_digit() && ch != `_` && ch != `-` {
			return error('SQL identifier "${name}" contains disallowed character: ${ch.ascii_str()}')
		}
	}
	return name
}

// Helper function to create parent directories if path is a file path.
fn ensure_db_dir(path string) ! {
	if path == ':memory:' || path == '' {
		return
	}
	dir := os.dir(path)
	if dir.len > 0 {
		os.mkdir_all(dir) or { return err }
	}
}

// Connection & Database Management

// Opens a SQLite database connection, creating parent directories automatically if needed.
pub fn open_db(path string) !sqlite.DB {
	ensure_db_dir(path) or { return err }
	mut db := sqlite.connect(path) or { return err }
	return db
}

// Executes a raw DDL/DML SQL query without expecting row returns.
// Caller is responsible for ensuring the query string contains no user-supplied data.
pub fn exec_sql(mut db sqlite.DB, query string) ! {
	db.exec(query) or { return err }
}

// Checks if a table exists in the database.
pub fn table_exists(mut db sqlite.DB, table_name string) !bool {
	rows := db.exec_param("SELECT name FROM sqlite_master WHERE type='table' AND name=?",
		table_name) or { return err }
	return rows.len > 0
}

// Returns a list of all non-system table names in the database.
pub fn get_table_names(mut db sqlite.DB) ![]string {
	query := "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"
	rows := db.exec(query) or { return err }
	mut names := []string{}
	for row in rows {
		if row.vals.len > 0 {
			names << row.vals[0]
		}
	}
	return names
}

// Returns the total row count for a table.
pub fn count_rows(mut db sqlite.DB, table_name string) !int {
	// Identifiers cannot be parameterized; sanitize_identifier guards against injection.
	tbl := sanitize_identifier(table_name)!
	rows := db.exec('SELECT COUNT(*) FROM "${tbl}";') or { return err }
	if rows.len == 0 || rows[0].vals.len == 0 {
		return 0
	}
	return rows[0].vals[0].int()
}

// Key-Value Store Helpers

// Creates a standard key-value table (key TEXT PRIMARY KEY, val TEXT).
pub fn create_kv_table(mut db sqlite.DB, table_name string) ! {
	tbl := sanitize_identifier(table_name)!
	db.exec('CREATE TABLE IF NOT EXISTS "${tbl}" (key TEXT PRIMARY KEY, val TEXT);') or {
		return err
	}
}

// Sets or updates a key-value pair in a key-value table.
pub fn set_kv(mut db sqlite.DB, table_name string, key string, val string) ! {
	tbl := sanitize_identifier(table_name)!
	// val is passed twice: once for INSERT and once for the ON CONFLICT UPDATE.
	db.exec_param_many('INSERT INTO "${tbl}" (key, val) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET val=?',
		[key, val, val]) or { return err }
}

// Gets the value for a key in a key-value table, returning an error if key is not found.
pub fn get_kv(mut db sqlite.DB, table_name string, key string) !string {
	tbl := sanitize_identifier(table_name)!
	rows := db.exec_param('SELECT val FROM "${tbl}" WHERE key = ?', key) or { return err }
	if rows.len == 0 || rows[0].vals.len == 0 {
		return error('Key "${key}" not found in table "${table_name}"')
	}
	return rows[0].vals[0]
}

// Deletes a key-value pair from a key-value table.
pub fn delete_kv(mut db sqlite.DB, table_name string, key string) ! {
	tbl := sanitize_identifier(table_name)!
	db.exec_param('DELETE FROM "${tbl}" WHERE key = ?', key) or { return err }
}

// Retrieves all key-value pairs from a key-value table as a map.
pub fn get_all_kv(mut db sqlite.DB, table_name string) !map[string]string {
	tbl := sanitize_identifier(table_name)!
	rows := db.exec('SELECT key, val FROM "${tbl}";') or { return err }
	mut result := map[string]string{}
	for row in rows {
		if row.vals.len >= 2 {
			result[row.vals[0]] = row.vals[1]
		}
	}
	return result
}

// Struct & JSON Document Store Helpers

// Creates a JSON document store table (id TEXT PRIMARY KEY, json_data TEXT).
pub fn create_json_store(mut db sqlite.DB, table_name string) ! {
	tbl := sanitize_identifier(table_name)!
	db.exec('CREATE TABLE IF NOT EXISTS "${tbl}" (id TEXT PRIMARY KEY, json_data TEXT);') or {
		return err
	}
}

// Saves a struct as a JSON document under a given ID.
pub fn save_struct[T](mut db sqlite.DB, table_name string, id string, data T) ! {
	tbl := sanitize_identifier(table_name)!
	encoded := json.encode(data)
	// encoded is passed twice: for the INSERT value and for the ON CONFLICT UPDATE.
	db.exec_param_many('INSERT INTO "${tbl}" (id, json_data) VALUES (?, ?) ON CONFLICT(id) DO UPDATE SET json_data=?',
		[id, encoded, encoded]) or { return err }
}

// Loads a struct from a JSON document by ID.
pub fn load_struct[T](mut db sqlite.DB, table_name string, id string) !T {
	tbl := sanitize_identifier(table_name)!
	rows := db.exec_param('SELECT json_data FROM "${tbl}" WHERE id = ?', id) or { return err }
	if rows.len == 0 || rows[0].vals.len == 0 {
		return error('Record with ID "${id}" not found in table "${table_name}"')
	}
	return json.decode(T, rows[0].vals[0])
}

// Loads all struct records from a JSON document store table.
pub fn load_all_structs[T](mut db sqlite.DB, table_name string) ![]T {
	tbl := sanitize_identifier(table_name)!
	rows := db.exec('SELECT json_data FROM "${tbl}";') or { return err }
	mut result := []T{}
	for row in rows {
		if row.vals.len > 0 {
			item := json.decode(T, row.vals[0]) or { continue }
			result << item
		}
	}
	return result
}

// Deletes a struct document record by ID.
pub fn delete_struct(mut db sqlite.DB, table_name string, id string) ! {
	tbl := sanitize_identifier(table_name)!
	db.exec_param('DELETE FROM "${tbl}" WHERE id = ?', id) or { return err }
}

// Dynamic Query & Batch Transaction Helpers

// Executes a static SELECT query and returns rows as a list of column-name -> string-value maps.
// Caller is responsible for ensuring the query string contains no user-supplied data.
// Use query_maps_params when the query must include user values.
pub fn query_maps(mut db sqlite.DB, query string) ![]map[string]string {
	rows := db.exec(query) or { return err }
	mut result := []map[string]string{}
	for row in rows {
		mut row_map := map[string]string{}
		for i in 0 .. row.vals.len {
			col_name := if i < row.names.len { row.names[i] } else { i.str() }
			row_map[col_name] = row.vals[i]
		}
		result << row_map
	}
	return result
}

// Executes a parameterized SELECT query with ? placeholders and returns rows as maps.
// Use this variant whenever the query includes user-supplied values.
pub fn query_maps_params(mut db sqlite.DB, query string, params []string) ![]map[string]string {
	rows := db.exec_param_many(query, params) or { return err }
	mut result := []map[string]string{}
	for row in rows {
		mut row_map := map[string]string{}
		for i in 0 .. row.vals.len {
			col_name := if i < row.names.len { row.names[i] } else { i.str() }
			row_map[col_name] = row.vals[i]
		}
		result << row_map
	}
	return result
}

// Executes a static query and returns the first row as a map, or an error if no rows are returned.
// Caller is responsible for ensuring the query string contains no user-supplied data.
// Use query_one_map_params when the query must include user values.
pub fn query_one_map(mut db sqlite.DB, query string) !map[string]string {
	maps := query_maps(mut db, query) or { return err }
	if maps.len == 0 {
		return error('No rows returned for query')
	}
	return maps[0]
}

// Executes a parameterized query and returns the first row as a map.
// Use this variant whenever the query includes user-supplied values.
pub fn query_one_map_params(mut db sqlite.DB, query string, params []string) !map[string]string {
	maps := query_maps_params(mut db, query, params) or { return err }
	if maps.len == 0 {
		return error('No rows returned for query')
	}
	return maps[0]
}

// Executes multiple static SQL statements inside a single transaction with automatic rollback on error.
// Statements must contain no user-supplied data. Use execute_batch_params for parameterized statements.
pub fn execute_batch(mut db sqlite.DB, statements []string) ! {
	db.exec('BEGIN TRANSACTION;') or { return err }
	for stmt in statements {
		db.exec(stmt) or {
			db.exec('ROLLBACK;') or {}
			return err
		}
	}
	db.exec('COMMIT;') or { return err }
}

// ParamStatement pairs a parameterized SQL query with its bound values for use in execute_batch_params.
pub struct ParamStatement {
pub:
	query  string
	params []string
}

// Executes multiple parameterized SQL statements (each with its own params slice) inside a single
// transaction with automatic rollback on error.
pub fn execute_batch_params(mut db sqlite.DB, statements []ParamStatement) ! {
	db.exec('BEGIN TRANSACTION;') or { return err }
	for ps in statements {
		db.exec_param_many(ps.query, ps.params) or {
			db.exec('ROLLBACK;') or {}
			return err
		}
	}
	db.exec('COMMIT;') or { return err }
}
