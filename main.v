module main

import os
import fileutils
import sqliteutils

struct Person {
	name string
	age  int
}

fn main() {
	// --- FILEUTILS DEMO ---
	demo_dir := '.fileutils_demo'
	os.mkdir_all(demo_dir) or { panic(err) }

	println('==================================================')
	println('Starting fileutils demo...')
	println('Demo output directory: ${demo_dir}')

	people := [Person{
		name: 'Alice'
		age:  30
	}, Person{
		name: 'Bob'
		age:  25
	}]

	people_path := '${demo_dir}/people.json'
	fileutils.save_struct_array_to_file(people_path, people) or { panic(err) }
	loaded_people := fileutils.load_struct_array_from_file[Person](people_path) or { panic(err) }
	println('Loaded ${loaded_people.len} people from ${people_path}')

	person_path := '${demo_dir}/person.json'
	fileutils.save_struct_to_file(person_path, Person{
		name: 'Charlie'
		age:  40
	}) or { panic(err) }
	person := fileutils.load_struct_from_file[Person](person_path) or { panic(err) }
	println('Single struct loaded: ${person.name} (${person.age})')

	log_path := '${demo_dir}/notes.log'
	fileutils.append_line_to_file(log_path, 'First log entry') or { panic(err) }
	fileutils.append_line_to_file(log_path, 'Second log entry') or { panic(err) }

	config_path := '${demo_dir}/app.conf'
	os.write_file(config_path, 'host=localhost\nport=8080\n# comment\n') or { panic(err) }
	defaults := {
		'mode': 'prod'
		'port': '3000'
	}
	config := fileutils.load_config_from_file(config_path, defaults) or { panic(err) }
	println('Config values: host=${config['host']}, port=${config['port']}, mode=${config['mode']}')

	// --- SQLITEUTILS DEMO ---
	println('\n==================================================')
	println('Starting sqliteutils demo...')
	sqlite_dir := '.sqliteutils_demo'
	db_path := '${sqlite_dir}/demo.db'

	mut db := sqliteutils.open_db(db_path) or { panic(err) }
	println('Opened SQLite DB at: ${db_path}')

	// 1. Table inspection & SQL Execution
	sqliteutils.exec_sql(mut db, 'CREATE TABLE IF NOT EXISTS logs (id INTEGER PRIMARY KEY, msg TEXT);') or {
		panic(err)
	}
	tables := sqliteutils.get_table_names(mut db) or { panic(err) }
	println('Database tables: ${tables}')

	// 2. Key-Value Store
	sqliteutils.create_kv_table(mut db, 'app_settings') or { panic(err) }
	sqliteutils.set_kv(mut db, 'app_settings', 'theme', 'dark') or { panic(err) }
	sqliteutils.set_kv(mut db, 'app_settings', 'lang', 'en') or { panic(err) }
	theme := sqliteutils.get_kv(mut db, 'app_settings', 'theme') or { panic(err) }
	println('KV Setting theme: ${theme}')

	all_kv := sqliteutils.get_all_kv(mut db, 'app_settings') or { panic(err) }
	println('All KV settings: ${all_kv}')

	// 3. JSON Struct Document Store
	sqliteutils.create_json_store(mut db, 'users_store') or { panic(err) }
	user1 := Person{
		name: 'Diana'
		age:  29
	}
	user2 := Person{
		name: 'Ethan'
		age:  34
	}
	sqliteutils.save_struct(mut db, 'users_store', 'user_diana', user1) or { panic(err) }
	sqliteutils.save_struct(mut db, 'users_store', 'user_ethan', user2) or { panic(err) }

	loaded_user := sqliteutils.load_struct[Person](mut db, 'users_store', 'user_diana') or {
		panic(err)
	}
	println('Loaded struct from SQLite: ${loaded_user.name} (${loaded_user.age})')

	all_users := sqliteutils.load_all_structs[Person](mut db, 'users_store') or { panic(err) }
	println('Loaded all structs count: ${all_users.len}')

	// 4. Managed Transaction Batch
	batch := [
		"INSERT INTO logs (msg) VALUES ('Service started');",
		"INSERT INTO logs (msg) VALUES ('User logged in');",
	]
	sqliteutils.execute_batch(mut db, batch) or { panic(err) }

	// 5. Dynamic Map Queries
	log_rows := sqliteutils.query_maps(mut db, 'SELECT id, msg FROM logs;') or { panic(err) }
	println('Log rows from SQLite query:')
	for r in log_rows {
		println(' - [ID ${r['id']}] ${r['msg']}')
	}

	println('\nDemo complete.')
}
