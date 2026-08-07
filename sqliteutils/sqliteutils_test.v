module sqliteutils

import os

struct Item {
	id    string
	title string
	price int
}

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
