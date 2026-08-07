module sqliteutils

import db.sqlite
import json
import os

// Helper function to escape single quotes in SQL string literals.
fn escape_sql(s string) string {
	return s.replace("'", "''")
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
pub fn exec_sql(mut db sqlite.DB, query string) ! {
	db.exec(query) or { return err }
}

// Checks if a table exists in the database.
pub fn table_exists(mut db sqlite.DB, table_name string) !bool {
	escaped := escape_sql(table_name)
	query := "SELECT name FROM sqlite_master WHERE type='table' AND name='${escaped}';"
	rows := db.exec(query) or { return err }
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
	query := "SELECT COUNT(*) FROM '${escape_sql(table_name)}';"
	rows := db.exec(query) or { return err }
	if rows.len == 0 || rows[0].vals.len == 0 {
		return 0
	}
	return rows[0].vals[0].int()
}

// Key-Value Store Helpers

// Creates a standard key-value table (key TEXT PRIMARY KEY, val TEXT).
pub fn create_kv_table(mut db sqlite.DB, table_name string) ! {
	query := "CREATE TABLE IF NOT EXISTS '${escape_sql(table_name)}' (key TEXT PRIMARY KEY, val TEXT);"
	db.exec(query) or { return err }
}

// Sets or updates a key-value pair in a key-value table.
pub fn set_kv(mut db sqlite.DB, table_name string, key string, val string) ! {
	tbl := escape_sql(table_name)
	k := escape_sql(key)
	v := escape_sql(val)
	query := "INSERT INTO '${tbl}' (key, val) VALUES ('${k}', '${v}') ON CONFLICT(key) DO UPDATE SET val='${v}';"
	db.exec(query) or { return err }
}

// Gets the value for a key in a key-value table, returning an error if key is not found.
pub fn get_kv(mut db sqlite.DB, table_name string, key string) !string {
	tbl := escape_sql(table_name)
	k := escape_sql(key)
	query := "SELECT val FROM '${tbl}' WHERE key = '${k}';"
	rows := db.exec(query) or { return err }
	if rows.len == 0 || rows[0].vals.len == 0 {
		return error('Key "${key}" not found in table "${table_name}"')
	}
	return rows[0].vals[0]
}

// Deletes a key-value pair from a key-value table.
pub fn delete_kv(mut db sqlite.DB, table_name string, key string) ! {
	tbl := escape_sql(table_name)
	k := escape_sql(key)
	query := "DELETE FROM '${tbl}' WHERE key = '${k}';"
	db.exec(query) or { return err }
}

// Retrieves all key-value pairs from a key-value table as a map.
pub fn get_all_kv(mut db sqlite.DB, table_name string) !map[string]string {
	tbl := escape_sql(table_name)
	query := "SELECT key, val FROM '${tbl}';"
	rows := db.exec(query) or { return err }
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
	query := "CREATE TABLE IF NOT EXISTS '${escape_sql(table_name)}' (id TEXT PRIMARY KEY, json_data TEXT);"
	db.exec(query) or { return err }
}

// Saves a struct as a JSON document under a given ID.
pub fn save_struct[T](mut db sqlite.DB, table_name string, id string, data T) ! {
	encoded := json.encode(data)
	tbl := escape_sql(table_name)
	escaped_id := escape_sql(id)
	escaped_json := escape_sql(encoded)
	query := "INSERT INTO '${tbl}' (id, json_data) VALUES ('${escaped_id}', '${escaped_json}') ON CONFLICT(id) DO UPDATE SET json_data='${escaped_json}';"
	db.exec(query) or { return err }
}

// Loads a struct from a JSON document by ID.
pub fn load_struct[T](mut db sqlite.DB, table_name string, id string) !T {
	tbl := escape_sql(table_name)
	escaped_id := escape_sql(id)
	query := "SELECT json_data FROM '${tbl}' WHERE id = '${escaped_id}';"
	rows := db.exec(query) or { return err }
	if rows.len == 0 || rows[0].vals.len == 0 {
		return error('Record with ID "${id}" not found in table "${table_name}"')
	}
	return json.decode(T, rows[0].vals[0])
}

// Loads all struct records from a JSON document store table.
pub fn load_all_structs[T](mut db sqlite.DB, table_name string) ![]T {
	tbl := escape_sql(table_name)
	query := "SELECT json_data FROM '${tbl}';"
	rows := db.exec(query) or { return err }
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
	tbl := escape_sql(table_name)
	escaped_id := escape_sql(id)
	query := "DELETE FROM '${tbl}' WHERE id = '${escaped_id}';"
	db.exec(query) or { return err }
}

// Dynamic Query & Batch Transaction Helpers

// Executes a SELECT query and returns rows as a list of column-name -> string-value maps.
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

// Executes a query and returns the first row as a map, or an error if no rows are returned.
pub fn query_one_map(mut db sqlite.DB, query string) !map[string]string {
	maps := query_maps(mut db, query) or { return err }
	if maps.len == 0 {
		return error('No rows returned for query')
	}
	return maps[0]
}

// Executes multiple SQL statements inside a single transaction with automatic rollback on error.
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
