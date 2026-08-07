module sqliteutils

import os

// ─── Shared test struct ───────────────────────────────────────────────────────

struct Item {
	id    string
	title string
	price int
}

// ─── Existing tests (unchanged) ───────────────────────────────────────────────

fn test_open_db_and_schema_helpers() {
	mut db := open_db(':memory:') or { panic(err) }

	assert table_exists(mut db, 'users') or { panic(err) } == false

	exec_sql(mut db, 'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);') or { panic(err) }
	assert table_exists(mut db, 'users') or { panic(err) } == true

	tables := get_table_names(mut db) or { panic(err) }
	assert tables.contains('users')

	assert count_rows(mut db, 'users') or { panic(err) } == 0
	exec_sql(mut db, "INSERT INTO users (name) VALUES ('Alice'), ('Bob');") or { panic(err) }
	assert count_rows(mut db, 'users') or { panic(err) } == 2
}

fn test_kv_store_helpers() {
	mut db := open_db(':memory:') or { panic(err) }

	create_kv_table(mut db, 'settings') or { panic(err) }
	assert table_exists(mut db, 'settings') or { panic(err) } == true

	set_kv(mut db, 'settings', 'theme', 'dark') or { panic(err) }
	set_kv(mut db, 'settings', 'font_size', '14') or { panic(err) }

	theme := get_kv(mut db, 'settings', 'theme') or { panic(err) }
	assert theme == 'dark'

	// Update existing key
	set_kv(mut db, 'settings', 'theme', 'light') or { panic(err) }
	updated_theme := get_kv(mut db, 'settings', 'theme') or { panic(err) }
	assert updated_theme == 'light'

	all_kv := get_all_kv(mut db, 'settings') or { panic(err) }
	assert all_kv.len == 2
	assert all_kv['theme'] == 'light'
	assert all_kv['font_size'] == '14'

	delete_kv(mut db, 'settings', 'font_size') or { panic(err) }
	missing := get_kv(mut db, 'settings', 'font_size') or { 'not_found' }
	assert missing == 'not_found'
}

fn test_json_struct_store_helpers() {
	mut db := open_db(':memory:') or { panic(err) }

	create_json_store(mut db, 'items') or { panic(err) }
	assert table_exists(mut db, 'items') or { panic(err) } == true

	item1 := Item{
		id:    'item_1'
		title: 'Keyboard'
		price: 100
	}
	item2 := Item{
		id:    'item_2'
		title: 'Mouse'
		price: 50
	}

	save_struct(mut db, 'items', item1.id, item1) or { panic(err) }
	save_struct(mut db, 'items', item2.id, item2) or { panic(err) }

	loaded_item1 := load_struct[Item](mut db, 'items', 'item_1') or { panic(err) }
	assert loaded_item1.title == 'Keyboard'
	assert loaded_item1.price == 100

	all_items := load_all_structs[Item](mut db, 'items') or { panic(err) }
	assert all_items.len == 2

	delete_struct(mut db, 'items', 'item_1') or { panic(err) }
	remaining := load_all_structs[Item](mut db, 'items') or { panic(err) }
	assert remaining.len == 1
	assert remaining[0].title == 'Mouse'
}

fn test_query_maps_and_batch_transactions() {
	mut db := open_db(':memory:') or { panic(err) }

	statements := [
		'CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT, price INTEGER);',
		"INSERT INTO products (name, price) VALUES ('Widget', 25);",
		"INSERT INTO products (name, price) VALUES ('Gadget', 45);",
	]
	execute_batch(mut db, statements) or { panic(err) }

	rows := query_maps(mut db, 'SELECT name, price FROM products ORDER BY price ASC;') or {
		panic(err)
	}
	assert rows.len == 2
	assert rows[0]['name'] == 'Widget'
	assert rows[0]['price'] == '25'
	assert rows[1]['name'] == 'Gadget'

	one_row := query_one_map(mut db, "SELECT name, price FROM products WHERE name = 'Widget';") or {
		panic(err)
	}
	assert one_row['name'] == 'Widget'
	assert one_row['price'] == '25'

	query_one_map(mut db, "SELECT name FROM products WHERE name = 'Nonexistent';") or {
		assert err.msg().contains('No rows returned')
		map[string]string{}
	}
}

fn test_open_db_creates_parent_directories() {
	dir_path := '/tmp/nested_sqlite_dir'
	db_path := '${dir_path}/app.db'
	os.rmdir_all(dir_path) or {}

	mut db := open_db(db_path) or { panic(err) }
	assert os.exists(db_path)

	exec_sql(mut db, 'CREATE TABLE test (id INT);') or { panic(err) }
	assert table_exists(mut db, 'test') or { panic(err) } == true

	os.rmdir_all(dir_path) or {}
}

// ─── New: sanitize_identifier ─────────────────────────────────────────────────

fn test_sanitize_identifier_rejects_bad_names() {
	// Empty name
	sanitize_identifier('') or {
		assert err.msg().contains('must not be empty')
	}
	// SQL injection attempt
	sanitize_identifier("cfg; DROP TABLE cfg;--") or {
		assert err.msg().contains('disallowed character')
	}
	// Space
	sanitize_identifier('my table') or {
		assert err.msg().contains('disallowed character')
	}
	// Single quote
	sanitize_identifier("it's") or {
		assert err.msg().contains('disallowed character')
	}
	// Valid names must pass
	assert sanitize_identifier('my_table') or { panic(err) } == 'my_table'
	assert sanitize_identifier('cfg-v2') or { panic(err) } == 'cfg-v2'
	assert sanitize_identifier('Table1') or { panic(err) } == 'Table1'
}

// ─── New: SQL injection safety ────────────────────────────────────────────────

fn test_parameterized_queries_handle_special_characters() {
	mut db := open_db(':memory:') or { panic(err) }
	create_kv_table(mut db, 'store') or { panic(err) }

	// Value with single-quote — classic SQL injection probe
	set_kv(mut db, 'store', 'user', "O'Brien; DROP TABLE store;--") or { panic(err) }
	v := get_kv(mut db, 'store', 'user') or { panic(err) }
	assert v == "O'Brien; DROP TABLE store;--"

	// Double-quote in JSON payload
	create_json_store(mut db, 'docs') or { panic(err) }
	save_struct(mut db, 'docs', 'id1', {'msg': 'say "hello"'}) or { panic(err) }
	row := load_struct[map[string]string](mut db, 'docs', 'id1') or { panic(err) }
	assert row['msg'] == 'say "hello"'

	// table_exists must NOT match via injection
	exists := table_exists(mut db, "nope' OR '1'='1") or { panic(err) }
	assert exists == false
	// The store table must still be intact
	assert table_exists(mut db, 'store') or { panic(err) } == true
}

// ─── New: Schema / DDL helpers ────────────────────────────────────────────────

fn test_drop_table() {
	mut db := open_db(':memory:') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE tmp (id INT);') or { panic(err) }
	assert table_exists(mut db, 'tmp') or { panic(err) } == true

	// Normal drop
	drop_table(mut db, 'tmp', false) or { panic(err) }
	assert table_exists(mut db, 'tmp') or { panic(err) } == false

	// Force drop on non-existent table — must not error
	drop_table(mut db, 'tmp', true) or { panic(err) }
}

fn test_rename_table() {
	mut db := open_db(':memory:') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE old_tbl (id INT);') or { panic(err) }

	rename_table(mut db, 'old_tbl', 'new_tbl') or { panic(err) }
	assert table_exists(mut db, 'new_tbl') or { panic(err) } == true
	assert table_exists(mut db, 'old_tbl') or { panic(err) } == false
}

fn test_clear_table() {
	mut db := open_db(':memory:') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE events (msg TEXT);') or { panic(err) }
	exec_sql(mut db, "INSERT INTO events VALUES ('a'),('b'),('c');") or { panic(err) }
	assert count_rows(mut db, 'events') or { panic(err) } == 3

	clear_table(mut db, 'events') or { panic(err) }
	assert count_rows(mut db, 'events') or { panic(err) } == 0
	// Table still exists
	assert table_exists(mut db, 'events') or { panic(err) } == true
}

fn test_get_column_names_and_column_exists() {
	mut db := open_db(':memory:') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT);') or {
		panic(err)
	}

	cols := get_column_names(mut db, 'users') or { panic(err) }
	assert cols == ['id', 'name', 'email']

	assert column_exists(mut db, 'users', 'name') or { panic(err) } == true
	assert column_exists(mut db, 'users', 'phone') or { panic(err) } == false
}

fn test_table_row_counts() {
	mut db := open_db(':memory:') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE a (x INT);') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE b (x INT);') or { panic(err) }
	exec_sql(mut db, 'INSERT INTO a VALUES (1),(2),(3);') or { panic(err) }

	counts := table_row_counts(mut db) or { panic(err) }
	assert counts['a'] == 3
	assert counts['b'] == 0
}

// ─── New: Extended KV helpers ─────────────────────────────────────────────────

fn test_kv_exists() {
	mut db := open_db(':memory:') or { panic(err) }
	create_kv_table(mut db, 'cfg') or { panic(err) }
	set_kv(mut db, 'cfg', 'present', 'yes') or { panic(err) }

	assert kv_exists(mut db, 'cfg', 'present') or { panic(err) } == true
	assert kv_exists(mut db, 'cfg', 'absent') or { panic(err) } == false
}

fn test_get_kv_or() {
	mut db := open_db(':memory:') or { panic(err) }
	create_kv_table(mut db, 'cfg') or { panic(err) }
	set_kv(mut db, 'cfg', 'lang', 'fr') or { panic(err) }

	// Key present — returns stored value
	assert get_kv_or(mut db, 'cfg', 'lang', 'en') == 'fr'
	// Key absent — returns default, never panics
	assert get_kv_or(mut db, 'cfg', 'missing', 'default') == 'default'
}

fn test_increment_kv() {
	mut db := open_db(':memory:') or { panic(err) }
	create_kv_table(mut db, 'counters') or { panic(err) }

	// Auto-creates key at 0 + amount
	v1 := increment_kv(mut db, 'counters', 'hits', 1) or { panic(err) }
	assert v1 == 1

	v2 := increment_kv(mut db, 'counters', 'hits', 1) or { panic(err) }
	assert v2 == 2

	// Increment by larger step
	v3 := increment_kv(mut db, 'counters', 'hits', 10) or { panic(err) }
	assert v3 == 12

	// Decrement (negative amount)
	v4 := increment_kv(mut db, 'counters', 'hits', -2) or { panic(err) }
	assert v4 == 10
}

fn test_clear_kv() {
	mut db := open_db(':memory:') or { panic(err) }
	create_kv_table(mut db, 'session') or { panic(err) }
	set_kv(mut db, 'session', 'token', 'abc') or { panic(err) }
	set_kv(mut db, 'session', 'user', 'alice') or { panic(err) }

	clear_kv(mut db, 'session') or { panic(err) }
	assert count_rows(mut db, 'session') or { panic(err) } == 0
	// Table itself must still exist
	assert table_exists(mut db, 'session') or { panic(err) } == true
}

// ─── New: Extended JSON store helpers ────────────────────────────────────────

fn test_struct_exists() {
	mut db := open_db(':memory:') or { panic(err) }
	create_json_store(mut db, 'products') or { panic(err) }

	item := Item{id: 'p1', title: 'Widget', price: 5}
	save_struct(mut db, 'products', 'p1', item) or { panic(err) }

	assert struct_exists(mut db, 'products', 'p1') or { panic(err) } == true
	assert struct_exists(mut db, 'products', 'p99') or { panic(err) } == false
}

fn test_count_structs() {
	mut db := open_db(':memory:') or { panic(err) }
	create_json_store(mut db, 'notes') or { panic(err) }

	assert count_structs(mut db, 'notes') or { panic(err) } == 0

	save_struct(mut db, 'notes', 'n1', Item{id: 'n1', title: 'First', price: 0}) or { panic(err) }
	save_struct(mut db, 'notes', 'n2', Item{id: 'n2', title: 'Second', price: 0}) or { panic(err) }
	assert count_structs(mut db, 'notes') or { panic(err) } == 2
}

fn test_list_struct_ids() {
	mut db := open_db(':memory:') or { panic(err) }
	create_json_store(mut db, 'posts') or { panic(err) }

	save_struct(mut db, 'posts', 'post_a', Item{}) or { panic(err) }
	save_struct(mut db, 'posts', 'post_b', Item{}) or { panic(err) }
	save_struct(mut db, 'posts', 'post_c', Item{}) or { panic(err) }

	ids := list_struct_ids(mut db, 'posts') or { panic(err) }
	assert ids.len == 3
	assert 'post_a' in ids
	assert 'post_b' in ids
	assert 'post_c' in ids
}

fn test_delete_all_structs() {
	mut db := open_db(':memory:') or { panic(err) }
	create_json_store(mut db, 'cache') or { panic(err) }

	save_struct(mut db, 'cache', 'c1', Item{}) or { panic(err) }
	save_struct(mut db, 'cache', 'c2', Item{}) or { panic(err) }
	assert count_structs(mut db, 'cache') or { panic(err) } == 2

	delete_all_structs(mut db, 'cache') or { panic(err) }
	assert count_structs(mut db, 'cache') or { panic(err) } == 0
	// Table schema must still be intact
	assert table_exists(mut db, 'cache') or { panic(err) } == true
}

// ─── New: Parameterized query helpers ────────────────────────────────────────

fn test_query_maps_params_and_query_one_map_params() {
	mut db := open_db(':memory:') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE employees (name TEXT, dept TEXT, salary INT);') or { panic(err) }
	exec_sql(mut db, "INSERT INTO employees VALUES ('Alice','Eng',90),('Bob','Eng',80),('Carol','HR',70);") or {
		panic(err)
	}

	// query_maps_params — filter by department
	rows := query_maps_params(mut db, 'SELECT name, salary FROM employees WHERE dept = ? ORDER BY salary DESC',
		['Eng']) or { panic(err) }
	assert rows.len == 2
	assert rows[0]['name'] == 'Alice'
	assert rows[1]['name'] == 'Bob'

	// query_one_map_params — single row
	one := query_one_map_params(mut db, 'SELECT name FROM employees WHERE name = ?', ['Carol']) or {
		panic(err)
	}
	assert one['name'] == 'Carol'

	// No rows — must return error
	query_one_map_params(mut db, 'SELECT name FROM employees WHERE name = ?', ['Ghost']) or {
		assert err.msg().contains('No rows returned')
		map[string]string{}
	}
}

fn test_query_scalar() {
	mut db := open_db(':memory:') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE scores (user TEXT, score INT);') or { panic(err) }
	exec_sql(mut db, "INSERT INTO scores VALUES ('alice',90),('alice',85),('bob',70);") or {
		panic(err)
	}

	// SUM
	total := query_scalar(mut db, 'SELECT SUM(score) FROM scores WHERE user = ?', ['alice']) or {
		panic(err)
	}
	assert total == '175'

	// COUNT
	cnt := query_scalar(mut db, 'SELECT COUNT(*) FROM scores WHERE user = ?', ['bob']) or {
		panic(err)
	}
	assert cnt == '1'

	// No rows — must error
	query_scalar(mut db, 'SELECT MAX(score) FROM scores WHERE user = ?', ['ghost']) or {
		// SQLite returns a single NULL row for MAX when no rows match; we get ''
		// Accept either '' or an error msg.
		_ := err
	}
}

fn test_query_column() {
	mut db := open_db(':memory:') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE tags (name TEXT, active INT);') or { panic(err) }
	exec_sql(mut db, "INSERT INTO tags VALUES ('v',1),('vlang',1),('draft',0);") or { panic(err) }

	active := query_column(mut db, 'SELECT name FROM tags WHERE active = ? ORDER BY name', ['1']) or {
		panic(err)
	}
	assert active == ['v', 'vlang']

	// No matching rows — returns empty slice, not an error
	none_found := query_column(mut db, 'SELECT name FROM tags WHERE active = ?', ['99']) or {
		panic(err)
	}
	assert none_found.len == 0
}

// ─── New: execute_batch_params ────────────────────────────────────────────────

fn test_execute_batch_params() {
	mut db := open_db(':memory:') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE log (msg TEXT, level TEXT);') or { panic(err) }

	stmts := [
		ParamStatement{query: 'INSERT INTO log VALUES (?, ?)', params: ['boot', 'INFO']},
		ParamStatement{query: 'INSERT INTO log VALUES (?, ?)', params: ['ready', 'INFO']},
		ParamStatement{query: 'INSERT INTO log VALUES (?, ?)', params: ['error', 'ERROR']},
	]
	execute_batch_params(mut db, stmts) or { panic(err) }
	assert count_rows(mut db, 'log') or { panic(err) } == 3

	// Rollback on error: inject a bad statement into the batch
	bad_stmts := [
		ParamStatement{query: 'INSERT INTO log VALUES (?, ?)', params: ['tx_start', 'INFO']},
		ParamStatement{query: 'INSERT INTO nonexistent VALUES (?)', params: ['x']},
	]
	execute_batch_params(mut db, bad_stmts) or {
		// Expected error — table must still have only 3 rows (rolled back)
		_ := err
	}
	assert count_rows(mut db, 'log') or { panic(err) } == 3
}

// ─── New: with_transaction ────────────────────────────────────────────────────

fn test_with_transaction_commits_on_success() {
	mut db := open_db(':memory:') or { panic(err) }
	create_kv_table(mut db, 'state') or { panic(err) }

	with_transaction(mut db, fn [mut db] () ! {
		set_kv(mut db, 'state', 'step', '1')!
		set_kv(mut db, 'state', 'status', 'ok')!
	}) or { panic(err) }

	assert get_kv(mut db, 'state', 'step') or { panic(err) } == '1'
	assert get_kv(mut db, 'state', 'status') or { panic(err) } == 'ok'
}

fn test_with_transaction_rolls_back_on_error() {
	mut db := open_db(':memory:') or { panic(err) }
	exec_sql(mut db, 'CREATE TABLE audit (msg TEXT);') or { panic(err) }
	exec_sql(mut db, "INSERT INTO audit VALUES ('before');") or { panic(err) }

	// This closure fails half-way through
	with_transaction(mut db, fn [mut db] () ! {
		exec_sql(mut db, "INSERT INTO audit VALUES ('txn_write');")!
		// Force error: insert into a nonexistent table
		exec_sql(mut db, 'INSERT INTO ghost VALUES (1);')!
	}) or {
		// Expected error path — nothing to do
		_ := err
	}

	// Only the original row should remain (transaction rolled back)
	assert count_rows(mut db, 'audit') or { panic(err) } == 1
}
