module main

import os
import fileutils
import sqliteutils
import strutils
import sliceutils
import envutils
import cryptoutils
import timeutils
import httputils
import cliutils
import sysutils
import netutils
import validutils
import structutils
import statutils
import stateutils
import time

struct Person {
	name string
	age  int
}

struct AppStateDemo {
pub mut:
	theme         string
	window_width  int
	window_height int
	recent_files  []string
}

fn main() {
	println(cliutils.bold(cliutils.cyan('==================================================')))
	println(cliutils.bold(cliutils.cyan('     vlang_utils Complete 15-Module Showcase      ')))
	println(cliutils.bold(cliutils.cyan('==================================================')))

	// 1. FILEUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('1. [fileutils] File & Data Persistence:')))
	demo_dir := '.fileutils_demo'
	os.mkdir_all(demo_dir) or { panic(err) }
	defer { os.rmdir_all(demo_dir) or {} }

	people := [
		Person{ name: 'Alice', age: 30 },
		Person{ name: 'Bob', age: 25 },
	]
	people_path := '${demo_dir}/people.json'
	fileutils.save_struct_array_to_file(people_path, people) or { panic(err) }
	loaded_people := fileutils.load_struct_array_from_file[Person](people_path) or { panic(err) }
	println(' - Loaded ${loaded_people.len} people from JSON file')

	csv_path := '${demo_dir}/users.csv'
	fileutils.write_csv(csv_path, [
		['id', 'name', 'status'],
		['1', 'Alice', 'active'],
		['2', 'Bob', 'pending'],
	], `,`) or { panic(err) }
	csv_rows := fileutils.read_csv(csv_path, `,`) or { panic(err) }
	println(' - CSV Rows written & read: ${csv_rows.len} rows')
	println(' - Human file size: ${fileutils.file_size_human(csv_path) or { "" }}')

	// 2. SQLITEUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('2. [sqliteutils] SQLite Ergonomics & KV/Doc Store:')))
	sqlite_dir := '.sqliteutils_demo'
	db_path := '${sqlite_dir}/demo.db'
	mut db := sqliteutils.open_db(db_path) or { panic(err) }
	defer {
		db.close() or {}
		os.rmdir_all(sqlite_dir) or {}
	}

	sqliteutils.create_kv_table(mut db, 'app_settings') or { panic(err) }
	sqliteutils.set_kv(mut db, 'app_settings', 'theme', 'dark') or { panic(err) }
	theme := sqliteutils.get_kv(mut db, 'app_settings', 'theme') or { panic(err) }
	println(' - KV Setting theme: ${theme}')

	sqliteutils.create_json_store(mut db, 'users_store') or { panic(err) }
	sqliteutils.save_struct(mut db, 'users_store', 'user_alice', people[0]) or { panic(err) }
	loaded_alice := sqliteutils.load_struct[Person](mut db, 'users_store', 'user_alice') or { panic(err) }
	println(' - Document loaded from SQLite store: ${loaded_alice.name} (${loaded_alice.age})')

	// Parameterized CRUD & Injection Defense
	sqliteutils.exec_sql(mut db, 'CREATE TABLE accounts (id INTEGER PRIMARY KEY, name TEXT);') or { panic(err) }
	acct_id := sqliteutils.insert_row(mut db, 'accounts', { 'name': "Alice' OR 1=1; --" }) or { panic(err) }
	accts := sqliteutils.select_rows(mut db, 'accounts', ['id', 'name'], 'id = ?', ['${acct_id}']) or { panic(err) }
	println(' - Safe Parameterized Insert & Select: id=${accts[0]["id"]}, name="${accts[0]["name"]}"')

	// 3. STRUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('3. [strutils] String Manipulation & Formatting:')))
	raw_text := 'vLang_Utilities: The Ultimate ToolKit'
	println(' - Slug: ${strutils.slugify(raw_text)}')
	println(' - Snake Case: ${strutils.to_snake_case(raw_text)}')
	println(' - Kebab Case: ${strutils.to_kebab_case(raw_text)}')
	println(' - Camel Case: ${strutils.to_camel_case(raw_text)}')
	println(' - Pascal Case: ${strutils.to_pascal_case(raw_text)}')
	println(' - Truncate words: ${strutils.truncate_words('The quick brown fox jumps over the lazy dog', 4, '...')}')
	println(' - Mask email: ${strutils.mask_email('developer.antigravity@google.com')}')
	println(' - Levenshtein distance (kitten -> sitting): ${strutils.levenshtein_distance('kitten', 'sitting')}')
	println(' - Random token (16): ${strutils.random_alphanumeric(16)}')

	// 4. SLICEUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('4. [sliceutils] Generic Collection Utilities:')))
	numbers := [1, 2, 2, 3, 4, 4, 5, 6, 7, 8, 9, 10]
	println(' - Unique numbers: ${sliceutils.unique(numbers)}')
	chunks := sliceutils.chunk(numbers, 4)
	println(' - Chunked (size 4): ${chunks}')
	evens, odds := sliceutils.partition(numbers, fn (n int) bool { return n % 2 == 0 })
	println(' - Partitioned -> Evens: ${evens}, Odds: ${odds}')
	println(' - Sum: ${sliceutils.sum_int(numbers)}, Average: ${sliceutils.average_int(numbers):.2f}')

	// 5. ENVUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('5. [envutils] Environment & Configuration:')))
	os.setenv('APP_PORT', '8080', true)
	os.setenv('APP_DEBUG', 'true', true)
	port := envutils.get_int('APP_PORT', 3000)
	debug := envutils.get_bool('APP_DEBUG', false)
	println(' - Typed Env: Port=${port}, Debug=${debug}')
	expanded := envutils.expand_env('Server running on port \$APP_PORT with debug=\$APP_DEBUG')
	println(' - Expanded Env string: ${expanded}')

	// 6. CRYPTOUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('6. [cryptoutils] Cryptography, Hashes & UUIDs:')))
	println(' - SHA-256("hello"): ${cryptoutils.sha256("hello")}')
	println(' - MD5("hello"): ${cryptoutils.md5("hello")}')
	println(' - HMAC-SHA256: ${cryptoutils.hmac_sha256("secret-key", "my-payload")}')
	println(' - UUID v4: ${cryptoutils.uuid_v4()}')
	println(' - Base64 Encoded: ${cryptoutils.base64_encode("Antigravity IDE")}')

	// 7. TIMEUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('7. [timeutils] Relative Time, Formatting & Stopwatch:')))
	mut sw := timeutils.new_stopwatch()
	time.sleep(15 * time.millisecond)
	sw.stop()
	println(' - Stopwatch benchmark: ${sw.elapsed_ms():.2f} ms')
	sample_time := time.now().add(-3600 * 3 * time.second)
	println(' - Relative time (3h ago): ${timeutils.time_ago(sample_time)}')
	println(' - ISO 8601 string: ${timeutils.to_iso8601(time.now())}')

	// 8. HTTPUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('8. [httputils] Query String & HTTP Client:')))
	qs := httputils.build_query_string({
		'query': 'v language utils'
		'page': '1'
		'format': 'json'
	})
	println(' - Encoded Query String: ${qs}')
	parsed_qs := httputils.parse_query_string(qs)
	println(' - Parsed Query Map: ${parsed_qs}')

	// 9. CLIUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('9. [cliutils] Terminal RAD, Visualization & Formatting:')))
	println(' - Sparkline: ' + cliutils.sparkline([1.0, 3.0, 5.0, 8.0, 4.0, 2.0, 9.0, 7.0, 10.0]))
	println(' - Gauge: ' + cliutils.gauge('RAM', 7.2, 10.0, 'GB'))
	println(' - Bar Chart:\n' + cliutils.bar_chart('Resource Usage', {
		'CPU': 45.0
		'MEM': 78.5
		'DISK': 62.0
	}, 20))
	tree := cliutils.TreeNode{
		label: 'Project Root'
		children: [
			cliutils.TreeNode{ label: 'src/main.v' },
			cliutils.TreeNode{
				label: 'modules'
				children: [
					cliutils.TreeNode{ label: 'sysutils' },
					cliutils.TreeNode{ label: 'netutils' },
					cliutils.TreeNode{ label: 'cliutils' },
				]
			}
		]
	}
	println(' - Tree View:\n' + cliutils.render_tree(tree))

	// 10. SYSUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('10. [sysutils] System Telemetry & Process Execution:')))
	cores := sysutils.get_cpu_count()
	total_ram, used_ram, ram_pct := sysutils.get_memory_stats()
	total_disk, used_disk, disk_pct := sysutils.get_disk_stats('/')
	uptime := sysutils.get_uptime()
	l1, l5, l15 := sysutils.get_load_averages()
	println(' - CPU Cores: ${cores}')
	println(' - System Uptime: ${uptime}s')
	println(' - RAM Usage: ${used_ram / (1024 * 1024)} MB / ${total_ram / (1024 * 1024)} MB (${ram_pct:.1f}%)')
	println(' - Disk Usage (/): ${used_disk / (1024 * 1024 * 1024)} GB / ${total_disk / (1024 * 1024 * 1024)} GB (${disk_pct:.1f}%)')
	println(' - Load Averages: 1m=${l1:.2f}, 5m=${l5:.2f}, 15m=${l15:.2f}')
	safe_out, safe_code := sysutils.exec_safe('echo', ['vlang_utils safe exec test'])
	println(' - Safe Exec: "${safe_out.trim_space()}" (code: ${safe_code})')

	// 11. NETUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('11. [netutils] Network Discovery & Diagnostics:')))
	online := netutils.is_online()
	local_ip := netutils.get_local_ip()
	dns_servers := netutils.get_dns_servers()
	println(' - Online Status: ${online}')
	println(' - Local IP: ${local_ip}')
	println(' - DNS Servers: ${dns_servers}')

	// 12. VALIDUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('12. [validutils] Comprehensive Data Validation:')))
	println(' - validate_email("dev@google.com"): ${validutils.validate_email("dev@google.com")}')
	println(' - validate_url("https://vlang.io"): ${validutils.validate_url("https://vlang.io")}')
	println(' - validate_ip("192.168.1.1"): ${validutils.validate_ip("192.168.1.1")}')
	println(' - validate_uuid("550e8400-e29b-41d4-a716-446655440000"): ${validutils.validate_uuid("550e8400-e29b-41d4-a716-446655440000")}')
	println(' - validate_json("{\"active\": true}"): ${validutils.validate_json("{\"active\": true}")}')

	// 13. STRUCTUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('13. [structutils] RAD Generic Data Structures:')))
	mut stack := structutils.new_stack[string]()
	stack.push('first')
	stack.push('second')
	println(' - Stack Pop: ${stack.pop() or { "" }} (remaining: ${stack.len()})')

	mut queue := structutils.new_queue[int]()
	queue.push(100)
	queue.push(200)
	println(' - Queue Pop: ${queue.pop() or { -1 }} (remaining: ${queue.len()})')

	mut ring := structutils.new_ring_buffer[string](3)
	ring.push('a')
	ring.push('b')
	ring.push('c')
	ring.push('d') // overwrites 'a'
	println(' - Ring Buffer (capacity 3, after pushing a,b,c,d): ${ring.to_array()}')

	mut heap := structutils.new_min_heap()
	heap.push(42)
	heap.push(10)
	heap.push(27)
	println(' - MinHeap Root: ${heap.pop() or { -1 }}')

	// 14. STATUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('14. [statutils] Comprehensive Statistical Analysis & Regression:')))
	dataset := [12.0, 15.0, 18.0, 20.0, 22.0, 25.0, 30.0, 45.0, 45.0, 50.0]
	summary := statutils.stats_summary(dataset)
	println(' - Dataset: ${dataset}')
	println(' - Summary: Mean=${summary.mean:.2f} | Median=${summary.median:.2f} | Sample StdDev=${summary.sample_std_dev:.2f} | IQR=${summary.iqr:.2f} | Skew=${summary.skewness:.2f}')
	
	// Bivariate Analysis
	x_vals := [1.0, 2.0, 3.0, 4.0, 5.0]
	y_vals := [2.1, 3.9, 6.2, 8.0, 9.9]
	lr := statutils.stats_linear_regression(x_vals, y_vals) or { statutils.LinearRegressionResult{} }
	println(' - OLS Regression (x->y): slope=${lr.slope:.2f}, intercept=${lr.intercept:.2f}, R²=${lr.r_squared:.4f}')

	// Moving Average & Outliers
	ma := statutils.stats_moving_average(dataset, 3) or { []f64{} }
	println(' - 3-Point Moving Average: ${ma}')


	// 15. STATEUTILS DEMO
	println('\n' + cliutils.bold(cliutils.yellow('15. [stateutils] OS-Recommended App State Saving:')))
	app_name := 'vlang_utils_demo_app'
	defer {
		os.rmdir_all(stateutils.get_app_dir(app_name, .data)) or {}
		os.rmdir_all(stateutils.get_app_dir(app_name, .config)) or {}
	}

	mut app_store := stateutils.new_app_state[AppStateDemo](app_name, AppStateDemo{
		theme:         'system_dark'
		window_width:  1280
		window_height: 800
		recent_files:  ['src/main.v', 'v.mod']
	})
	println(' - Recommended OS Path: ${app_store.path()}')

	app_store.auto_save = true
	app_store.update(fn (mut s AppStateDemo) {
		s.theme = 'dracula'
		s.recent_files << 'README.md'
	}) or { panic(err) }
	println(' - State updated & auto-saved atomically!')

	// Re-load state from recommended path to verify persistence
	mut reloaded_store := stateutils.new_app_state[AppStateDemo](app_name, AppStateDemo{})
	loaded_state := reloaded_store.get()
	println(' - Reloaded State: Theme=${loaded_state.theme}, Width=${loaded_state.window_width}, Files=${loaded_state.recent_files}')

	// Dynamic Key-Value app state
	mut kv := stateutils.new_kv_state(app_name)
	kv.auto_save = true
	kv.set_str('user_locale', 'en-US') or {}
	kv.set_int('launch_count', 15) or {}
	println(' - Dynamic KV State: user_locale=${kv.get_str("user_locale", "")}, launches=${kv.get_int("launch_count", 0)}')

	println('\n' + cliutils.bold(cliutils.green('✔ All 15 modules in vlang_utils demonstrated successfully!')))
}
