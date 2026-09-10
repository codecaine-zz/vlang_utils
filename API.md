# vlang_utils API Reference

Welcome to the API reference for `vlang_utils`. Each function below includes beginner-friendly code examples with explanatory comments.

---

# fileutils API

Import statement:
```v
import fileutils
```

## Struct helpers

### `save_struct_array_to_file[T](path string, data []T) !`

Saves a slice of structs to disk as a JSON array file. Automatically creates any missing parent directories.

```v
struct Person {
    name string
    age  int
}

// Create a list of Person structs
people := [
    Person{ name: 'Alice', age: 30 },
    Person{ name: 'Bob', age: 25 }
]

// Save the list to disk
fileutils.save_struct_array_to_file('data/people.json', people)!
println('Saved people array!')
```

---

### `load_struct_array_from_file[T](path string) ![]T`

Loads a slice of structs from a JSON array file back into memory.

```v
struct Person {
    name string
    age  int
}

// Load the slice of Person structs from file
people := fileutils.load_struct_array_from_file[Person]('data/people.json')!
println('Loaded ${people.len} people from file:')
for person in people {
    println('- ${person.name} (${person.age})')
}
```

---

### `save_struct_to_file[T](path string, data T) !`

Saves a single struct object to disk as a JSON file.

```v
struct Person {
    name string
    age  int
}

// Single struct object
person := Person{ name: 'Charlie', age: 40 }

// Save struct to disk
fileutils.save_struct_to_file('data/person.json', person)!
```

---

### `load_struct_from_file[T](path string) !T`

Loads a single struct object from a JSON file into memory.

```v
struct Person {
    name string
    age  int
}

// Load single struct from disk
person := fileutils.load_struct_from_file[Person]('data/person.json')!
println('Loaded single person: ${person.name}, age ${person.age}')
```

---

## Text File Helpers

### `append_line_to_file(path string, line string) !`

Appends a single text line to a file. Creates the file and any missing parent directories automatically if they do not exist.

```v
// Append log entries to a text file
fileutils.append_line_to_file('logs/app.log', 'First log entry')!
fileutils.append_line_to_file('logs/app.log', 'Second log entry')!
```

---

### `write_text_file(path string, content string) !`

Writes string content to a text file, creating parent directories automatically.

```v
// Write text content to a file
content := "Hello world!\nWelcome to RAD development with V."
fileutils.write_text_file('notes/readme.txt', content)!
```

---

### `read_text_file(path string) !string`

Reads an entire text file into a string variable.

```v
// Read file content back as a string
text := fileutils.read_text_file('notes/readme.txt')!
println(text)
```

---

### `read_lines_from_file(path string) ![]string`

Reads a text file line-by-line into a slice of strings (`[]string`).

```v
// Read file into lines
lines := fileutils.read_lines_from_file('logs/app.log')!
println('Total log lines: ${lines.len}')
for line in lines {
    println('Log: ${line}')
}
```

---

## Map & Config Helpers

### `save_map_to_file[K, V](path string, data map[K]V) !`

Saves a V map to disk as JSON for key-value configurations or lookup tables.

```v
mut settings := map[string]int{}
settings['max_connections'] = 100
settings['timeout_seconds'] = 30

fileutils.save_map_to_file('config/settings.json', settings)!
```

---

### `load_map_from_file[K, V](path string) !map[K]V`

Loads a V map from a JSON file into memory.

```v
settings := fileutils.load_map_from_file[string, int]('config/settings.json')!
println('Max connections: ${settings['max_connections']}')
```

---

### `load_config_from_file(path string, defaults map[string]string) !map[string]string`

Loads a simple `key=value` configuration file, ignoring `#` comments and falling back to default values when keys are missing.

```v
// Define default fallback values
defaults := {
    'host': 'localhost'
    'port': '3000'
    'mode': 'development'
}

// Load config file overlaying parsed values onto defaults
config := fileutils.load_config_from_file('app.conf', defaults)!
println('Server running on ${config['host']}:${config['port']} (${config['mode']} mode)')
```

---

## Directory Helpers

### `ensure_dir_exists(path string) !`

Creates the parent directory for a given file path if it doesn't already exist.

```v
// Ensure output directory exists before writing custom output
fileutils.ensure_dir_exists('exports/2026/report.csv')!
```

---

## JSON Helpers

### `write_json_file[T](path string, data T) !`

Writes any serializable data value or struct `T` as JSON to a file.

```v
struct Config {
    title string
    debug bool
}

cfg := Config{ title: 'My App', debug: true }
fileutils.write_json_file('config.json', cfg)!
```

---

### `read_json_file[T](path string) !T`

Reads a JSON file into a value or struct of type `T`.

```v
struct Config {
    title string
    debug bool
}

cfg := fileutils.read_json_file[Config]('config.json')!
println('App title: ${cfg.title}, debug enabled: ${cfg.debug}')
```

---

### `append_json_line[T](path string, data T) !`

Appends a JSON object as a single line to a newline-delimited JSON (NDJSON / `.jsonl`) file.

```v
struct LogEvent {
    level   string
    message string
}

event1 := LogEvent{ level: 'INFO', message: 'System boot' }
event2 := LogEvent{ level: 'WARN', message: 'High memory usage' }

fileutils.append_json_line('events.ndjson', event1)!
fileutils.append_json_line('events.ndjson', event2)!
```

---

## File Operations & CSV Helpers

### `copy_file(src string, dst string) !`

Copies a single file from `src` to `dst`. Automatically creates any missing parent directories for the destination.

```v
fileutils.copy_file('data/source.txt', 'backup/nested/copy.txt')!
```

---

### `copy_dir(src string, dst string) !`

Recursively copies a directory and all of its contents from `src` to `dst`.

```v
fileutils.copy_dir('assets', 'dist/assets')!
```

---

### `move(src string, dst string) !`

Moves or renames a file or directory. Automatically ensures destination parent folders exist.

```v
fileutils.move('temp/draft.txt', 'archive/final.txt')!
```

---

### `remove_file(path string) !`

Safely removes a file if it exists without throwing an error if absent.

```v
fileutils.remove_file('temp/scratch.txt')!
```

---

### `remove_dir(path string) !`

Safely and recursively removes a directory and all its contents if it exists.

```v
fileutils.remove_dir('temp/cache')!
```

---

### `list_files(dir string, recursive bool) ![]string`

Returns a list of all file paths inside `dir`. If `recursive` is `true`, traverses all nested directories.

```v
files := fileutils.list_files('logs', true)!
for f in files {
    println(f)
}
```

---

### `list_files_with_ext(dir string, ext string, recursive bool) ![]string`

Finds all files in `dir` matching a specific extension (e.g. `'json'` or `'.json'`).

```v
configs := fileutils.list_files_with_ext('conf', 'json', false)!
```

---

### `file_size(path string) !i64`

Returns the size of a file in bytes.

```v
bytes := fileutils.file_size('video.mp4')!
println('Size in bytes: ${bytes}')
```

---

### `file_size_human(path string) !string`

Returns a human-readable file size (e.g. `'450 B'`, `'1.50 MB'`, `'2.40 GB'`).

```v
readable := fileutils.file_size_human('dataset.csv')!
println('Size: ${readable}') // "12.45 MB"
```

---

### `file_extension(path string) string`

Returns the file extension without the leading dot.

```v
ext := fileutils.file_extension('image.png') // "png"
```

---

### `file_stem(path string) string`

Returns the base filename without extension or directory prefix.

```v
stem := fileutils.file_stem('/var/logs/app.conf') // "app"
```

---

### `read_csv(path string, delimiter rune) ![][]string`

Reads a CSV or TSV file into a 2D slice of strings. Delimiter defaults to `,` if `0` is passed.

```v
rows := fileutils.read_csv('users.csv', `,`)!
for row in rows {
    println('User: ${row[0]}, Role: ${row[1]}')
}
```

---

### `write_csv(path string, rows [][]string, delimiter rune) !`

Writes a 2D slice of strings to disk as a delimited CSV file, properly escaping cells containing quotes, delimiters, or newlines.

```v
table := [
    ['id', 'name', 'status'],
    ['1', 'Alice', 'active'],
    ['2', 'Bob', 'inactive'],
]
fileutils.write_csv('report.csv', table, `,`)!
```

---

### `temp_file(prefix string, suffix string) !string`

Creates a new empty temporary file with the given prefix and suffix and returns its absolute path.

```v
tmp := fileutils.temp_file('cache', '.tmp')!
defer { fileutils.remove_file(tmp) or {} }
```

---

### `temp_dir(prefix string) !string`

Creates a new temporary directory and returns its absolute path.

```v
dir := fileutils.temp_dir('build')!
defer { fileutils.remove_dir(dir) or {} }
```

---

# sqliteutils API

Import statement:
```v
import sqliteutils
```

---

## Connection & Database Management

### `open_db(path string) !sqlite.DB`

Opens a SQLite database connection to a file (or `:memory:`). Automatically creates parent folders if the file path directory does not exist.

```v
// Open or create a database in 'db/' folder
mut db := sqliteutils.open_db('db/app.db')!
println('Connected to database!')
```

---

### `close_db(mut db sqlite.DB) !`

Closes a SQLite database connection and releases all associated OS file handles. Always close a database when you are finished with it — leaving connections open can block other processes from writing to the same file.

The idiomatic pattern is to call `close_db` via `defer` immediately after opening:

```v
mut db := sqliteutils.open_db('app.db')!
defer { sqliteutils.close_db(mut db) or {} }

// … do work …
// close_db is called automatically when the function returns
```

---

### `last_insert_id(db sqlite.DB) i64`

Returns the row ID (typically the `INTEGER PRIMARY KEY`) assigned to the most recently inserted row on this connection. Returns `0` if no `INSERT` has been performed yet. Call this **immediately** after an `INSERT` before any other statement.

```v
mut db := sqliteutils.open_db(':memory:')!
defer { sqliteutils.close_db(mut db) or {} }

sqliteutils.exec_sql(mut db, 'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);')!

sqliteutils.exec_sql(mut db, "INSERT INTO users (name) VALUES ('Alice');")!
alice_id := sqliteutils.last_insert_id(db)
println('Alice inserted with id: ${alice_id}') // 1

sqliteutils.exec_sql(mut db, "INSERT INTO users (name) VALUES ('Bob');")!
bob_id := sqliteutils.last_insert_id(db)
println('Bob inserted with id: ${bob_id}') // 2
```

---

### `exec_sql(mut db sqlite.DB, query string) !`

Executes raw DDL or DML SQL statements (`CREATE TABLE`, `INSERT`, `UPDATE`, `DELETE`) without returning rows.

```v
mut db := sqliteutils.open_db(':memory:')!

// Create table using raw SQL
sqliteutils.exec_sql(mut db, 'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);')!

// Insert a row using raw SQL
sqliteutils.exec_sql(mut db, "INSERT INTO users (name) VALUES ('Alice');")!
```

---

### `table_exists(mut db sqlite.DB, table_name string) !bool`

Checks whether a specific table exists in the database.

```v
mut db := sqliteutils.open_db(':memory:')!

if sqliteutils.table_exists(mut db, 'users')! {
    println('Users table exists!')
} else {
    println('Users table does not exist yet.')
}
```

---

### `get_table_names(mut db sqlite.DB) ![]string`

Returns a slice containing all non-system table names in the database.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE users (id INT);')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE orders (id INT);')!

tables := sqliteutils.get_table_names(mut db)!
println('Tables in database: ${tables}') // Output: ['users', 'orders']
```

---

### `count_rows(mut db sqlite.DB, table_name string) !int`

Returns the total row count for a given table.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);')!
sqliteutils.exec_sql(mut db, "INSERT INTO users (name) VALUES ('Alice'), ('Bob');")!

count := sqliteutils.count_rows(mut db, 'users')!
println('Total rows in users table: ${count}') // Output: 2
```

---

## Key-Value Store Helpers

### `create_kv_table(mut db sqlite.DB, table_name string) !`

Creates a Key-Value table with schema `(key TEXT PRIMARY KEY, val TEXT)`.

```v
mut db := sqliteutils.open_db(':memory:')!

// Create a key-value table called 'settings'
sqliteutils.create_kv_table(mut db, 'settings')!
```

---

### `set_kv(mut db sqlite.DB, table_name string, key string, val string) !`

Inserts or updates a key-value pair in a Key-Value table.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_kv_table(mut db, 'settings')!

// Save key-value settings
sqliteutils.set_kv(mut db, 'settings', 'theme', 'dark')!
sqliteutils.set_kv(mut db, 'settings', 'fontSize', '16')!
```

---

### `get_kv(mut db sqlite.DB, table_name string, key string) !string`

Gets the string value for a key from a Key-Value table. Returns an error if the key is missing (allowing the `or { 'default' }` fallback pattern).

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_kv_table(mut db, 'settings')!
sqliteutils.set_kv(mut db, 'settings', 'theme', 'dark')!

// Fetch value with default fallback if key is missing
theme := sqliteutils.get_kv(mut db, 'settings', 'theme') or { 'light' }
println('Theme: ${theme}') // Output: dark

missing := sqliteutils.get_kv(mut db, 'settings', 'nonexistent_key') or { 'default_val' }
println('Missing key fallback: ${missing}') // Output: default_val
```

---

### `delete_kv(mut db sqlite.DB, table_name string, key string) !`

Deletes a key-value entry from a Key-Value table.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_kv_table(mut db, 'settings')!
sqliteutils.set_kv(mut db, 'settings', 'theme', 'dark')!

// Delete key
sqliteutils.delete_kv(mut db, 'settings', 'theme')!
```

---

### `get_all_kv(mut db sqlite.DB, table_name string) !map[string]string`

Retrieves all key-value entries from a Key-Value table as a V `map[string]string`.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_kv_table(mut db, 'settings')!
sqliteutils.set_kv(mut db, 'settings', 'theme', 'dark')!
sqliteutils.set_kv(mut db, 'settings', 'lang', 'en')!

all_settings := sqliteutils.get_all_kv(mut db, 'settings')!
println('Theme setting: ${all_settings['theme']}')
println('Language setting: ${all_settings['lang']}')
```

---

## Struct & JSON Document Store Helpers

### `create_json_store(mut db sqlite.DB, table_name string) !`

Creates a document store table with schema `(id TEXT PRIMARY KEY, json_data TEXT)` for persisting struct objects.

```v
mut db := sqliteutils.open_db(':memory:')!

// Create document store table
sqliteutils.create_json_store(mut db, 'user_store')!
```

---

### `save_struct[T](mut db sqlite.DB, table_name string, id string, data T) !`

Serializes a V struct into JSON and saves it in SQLite under a unique ID. Updates existing records if ID exists.

```v
struct Product {
    name  string
    price int
}

mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_json_store(mut db, 'products')!

item := Product{ name: 'Mechanical Keyboard', price: 120 }
sqliteutils.save_struct(mut db, 'products', 'prod_01', item)!
println('Saved product struct to SQLite!')
```

---

### `load_struct[T](mut db sqlite.DB, table_name string, id string) !T`

Loads and deserializes a struct from a SQLite document store by ID.

```v
struct Product {
    name  string
    price int
}

mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_json_store(mut db, 'products')!
sqliteutils.save_struct(mut db, 'products', 'prod_01', Product{ name: 'Keyboard', price: 100 })!

// Load struct by ID
product := sqliteutils.load_struct[Product](mut db, 'products', 'prod_01')!
println('Loaded product: ${product.name}, price: $${product.price}')
```

---

### `load_all_structs[T](mut db sqlite.DB, table_name string) ![]T`

Loads and deserializes all struct records in a document store table into a slice `[]T`.

```v
struct Product {
    name  string
    price int
}

mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_json_store(mut db, 'products')!

sqliteutils.save_struct(mut db, 'products', 'p1', Product{ name: 'Mouse', price: 40 })!
sqliteutils.save_struct(mut db, 'products', 'p2', Product{ name: 'Monitor', price: 300 })!

// Load all products
products := sqliteutils.load_all_structs[Product](mut db, 'products')!
println('Total products loaded: ${products.len}')
for p in products {
    println('- ${p.name}: $${p.price}')
}
```

---

### `delete_struct(mut db sqlite.DB, table_name string, id string) !`

Deletes a document record by ID from a document store table.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_json_store(mut db, 'products')!

// Delete record with ID 'p1'
sqliteutils.delete_struct(mut db, 'products', 'p1')!
```

---

## Dynamic Query & Transaction Helpers

### `query_maps(mut db sqlite.DB, query string) ![]map[string]string`

Executes a `SELECT` SQL query and returns rows as a slice of maps (`[]map[string]string`), where keys are column names.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE employees (name TEXT, role TEXT, salary INT);')!
sqliteutils.exec_sql(mut db, "INSERT INTO employees VALUES ('Alice', 'Developer', 90000), ('Bob', 'Designer', 80000);")!

// Run query returning rows as column maps
rows := sqliteutils.query_maps(mut db, 'SELECT name, role, salary FROM employees;')!
for row in rows {
    println('Employee ${row['name']}: ${row['role']} (Salary: $${row['salary']})')
}
```

---

### `query_one_map(mut db sqlite.DB, query string) !map[string]string`

Executes a `SELECT` query and returns the first row as a column map `map[string]string`. Returns an error if no rows match.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE users (id INT, name TEXT);')!
sqliteutils.exec_sql(mut db, "INSERT INTO users VALUES (1, 'Alice');")!

// Fetch single row
user := sqliteutils.query_one_map(mut db, 'SELECT name FROM users WHERE id = 1;')!
println('Found user: ${user['name']}') // Output: Alice
```

---

### `query_maps_params(mut db sqlite.DB, query string, params []string) ![]map[string]string`

Executes a **parameterized** `SELECT` query with `?` placeholders and returns rows as a slice of maps. Use this variant whenever the query includes user-supplied filter values.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE employees (name TEXT, dept TEXT, salary INT);')!
sqliteutils.exec_sql(mut db, "INSERT INTO employees VALUES ('Alice','Eng',90),('Bob','Eng',80),('Carol','HR',70);")!

// Safe parameterized filter — user input goes in params, not the query string
rows := sqliteutils.query_maps_params(mut db,
    'SELECT name, salary FROM employees WHERE dept = ? ORDER BY salary DESC',
    ['Eng'])!
for row in rows {
    println('${row['name']}: ${row['salary']}')
}
```

---

### `query_one_map_params(mut db sqlite.DB, query string, params []string) !map[string]string`

Executes a **parameterized** `SELECT` query and returns the first matching row as a map. Returns an error if no rows match.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE users (id INT, name TEXT);')!
sqliteutils.exec_sql(mut db, "INSERT INTO users VALUES (1, 'Alice');")!

// Safe lookup by user-supplied id
row := sqliteutils.query_one_map_params(mut db,
    'SELECT name FROM users WHERE id = ?',
    ['1'])!
println('Found: ${row['name']}') // Output: Alice
```

### `execute_batch(mut db sqlite.DB, statements []string) !`

Executes multiple SQL statements inside a single transaction (`BEGIN TRANSACTION ... COMMIT`). If any statement fails, the transaction automatically rolls back.

```v
mut db := sqliteutils.open_db(':memory:')!

// Run multiple statements atomically
batch := [
    'CREATE TABLE accounts (id INT PRIMARY KEY, balance INT);',
    'INSERT INTO accounts VALUES (1, 500);',
    'INSERT INTO accounts VALUES (2, 1000);',
    'UPDATE accounts SET balance = balance - 100 WHERE id = 1;',
    'UPDATE accounts SET balance = balance + 100 WHERE id = 2;'
]

sqliteutils.execute_batch(mut db, batch)!
println('Batch transaction executed successfully!')
```

---

### `execute_batch_params(mut db sqlite.DB, statements []ParamStatement) !`

Executes multiple **parameterized** SQL statements atomically. Each `ParamStatement` pairs a query string with its bound values. Rolls back automatically on any error.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE log (msg TEXT, level TEXT);')!

batch := [
    sqliteutils.ParamStatement{ query: 'INSERT INTO log VALUES (?, ?)', params: ['boot', 'INFO'] },
    sqliteutils.ParamStatement{ query: 'INSERT INTO log VALUES (?, ?)', params: ['ready', 'INFO'] },
]

sqliteutils.execute_batch_params(mut db, batch)!
println('Parameterized batch executed!')
```

---

## Schema / DDL Helpers

### `drop_table(mut db sqlite.DB, table_name string, force bool) !`

Drops a table. Pass `force: true` to use `DROP TABLE IF EXISTS` — no error is returned when the table is already absent.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE tmp (id INT);')!

// Normal drop — errors if table is missing
sqliteutils.drop_table(mut db, 'tmp', false)!

// Force drop — safe even when table doesn't exist
sqliteutils.drop_table(mut db, 'tmp', true)!
println('Dropped!')
```

---

### `rename_table(mut db sqlite.DB, old_name string, new_name string) !`

Renames a table using `ALTER TABLE … RENAME TO`. Both names must contain only letters, digits, underscores, or hyphens.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE old_name (id INT);')!

sqliteutils.rename_table(mut db, 'old_name', 'new_name')!
println('Renamed!')
```

---

### `clear_table(mut db sqlite.DB, table_name string) !`

Removes all rows from a table without dropping it (SQLite's equivalent of `TRUNCATE`).

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE events (msg TEXT);')!
sqliteutils.exec_sql(mut db, "INSERT INTO events VALUES ('one'),('two');")!

sqliteutils.clear_table(mut db, 'events')!
count := sqliteutils.count_rows(mut db, 'events')!
println('Rows after clear: ${count}') // Output: 0
```

---

### `get_column_names(mut db sqlite.DB, table_name string) ![]string`

Returns the ordered list of column names for a table via `PRAGMA table_info`.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE users (id INT, name TEXT, email TEXT);')!

cols := sqliteutils.get_column_names(mut db, 'users')!
println('Columns: ${cols}') // Output: ['id', 'name', 'email']
```

---

### `column_exists(mut db sqlite.DB, table_name string, column_name string) !bool`

Checks whether a specific column exists in a table.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE users (id INT, name TEXT);')!

println(sqliteutils.column_exists(mut db, 'users', 'name')!)  // true
println(sqliteutils.column_exists(mut db, 'users', 'phone')!) // false
```

---

### `table_row_counts(mut db sqlite.DB) !map[string]int`

Returns a map of every non-system table name to its current row count. Useful for quick database health checks.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE a (x INT);')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE b (x INT);')!
sqliteutils.exec_sql(mut db, 'INSERT INTO a VALUES (1),(2);')!

counts := sqliteutils.table_row_counts(mut db)!
println(counts) // {'a': 2, 'b': 0}
```

---

## Extended Key-Value Helpers

### `kv_exists(mut db sqlite.DB, table_name string, key string) !bool`

Checks whether a key is present in a key-value table without fetching the value.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_kv_table(mut db, 'cfg')!
sqliteutils.set_kv(mut db, 'cfg', 'theme', 'dark')!

println(sqliteutils.kv_exists(mut db, 'cfg', 'theme')!)  // true
println(sqliteutils.kv_exists(mut db, 'cfg', 'ghost')!)  // false
```

---

### `get_kv_or(mut db sqlite.DB, table_name string, key string, default_val string) string`

Gets a value by key, returning `default_val` if the key is absent. **Never errors** — designed for the zero-friction RAD read pattern.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_kv_table(mut db, 'cfg')!

lang := sqliteutils.get_kv_or(mut db, 'cfg', 'lang', 'en')
println('Language: ${lang}') // Output: en  (key absent, default returned)
```

---

### `increment_kv(mut db sqlite.DB, table_name string, key string, amount int) !int`

Atomically increments an integer stored at `key` by `amount`. Creates the key with value `amount` if it doesn't yet exist. Returns the updated value.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_kv_table(mut db, 'counters')!

v1 := sqliteutils.increment_kv(mut db, 'counters', 'page_views', 1)!
println(v1) // 1  (created from zero)

v2 := sqliteutils.increment_kv(mut db, 'counters', 'page_views', 1)!
println(v2) // 2
```

---

### `clear_kv(mut db sqlite.DB, table_name string) !`

Removes all key-value pairs from a table while keeping the table itself intact.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_kv_table(mut db, 'session')!
sqliteutils.set_kv(mut db, 'session', 'token', 'abc123')!

sqliteutils.clear_kv(mut db, 'session')!
println(sqliteutils.count_rows(mut db, 'session')!) // 0
```

---

## Extended JSON Document Store Helpers

### `struct_exists(mut db sqlite.DB, table_name string, id string) !bool`

Checks whether a document with the given ID exists in a JSON store table.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_json_store(mut db, 'users')!

struct User { name string }
sqliteutils.save_struct(mut db, 'users', 'u1', User{ name: 'Alice' })!

println(sqliteutils.struct_exists(mut db, 'users', 'u1')!)  // true
println(sqliteutils.struct_exists(mut db, 'users', 'u99')!) // false
```

---

### `count_structs(mut db sqlite.DB, table_name string) !int`

Returns the number of documents stored in a JSON store table. Alias for `count_rows` with clearer intent.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_json_store(mut db, 'items')!
sqliteutils.save_struct(mut db, 'items', 'i1', map[string]string{})!
sqliteutils.save_struct(mut db, 'items', 'i2', map[string]string{})!

println(sqliteutils.count_structs(mut db, 'items')!) // 2
```

---

### `delete_all_structs(mut db sqlite.DB, table_name string) !`

Deletes every document from a JSON store table while keeping the table schema intact.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_json_store(mut db, 'cache')!
sqliteutils.save_struct(mut db, 'cache', 'c1', map[string]string{})!

sqliteutils.delete_all_structs(mut db, 'cache')!
println(sqliteutils.count_structs(mut db, 'cache')!) // 0
```

---

### `list_struct_ids(mut db sqlite.DB, table_name string) ![]string`

Returns a slice of all document IDs stored in a JSON store table. Useful for iterating or bulk-loading records.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_json_store(mut db, 'posts')!
sqliteutils.save_struct(mut db, 'posts', 'post_1', map[string]string{})!
sqliteutils.save_struct(mut db, 'posts', 'post_2', map[string]string{})!

ids := sqliteutils.list_struct_ids(mut db, 'posts')!
println('Post IDs: ${ids}') // ['post_1', 'post_2']
```

---

## Query Helpers

### `query_scalar(mut db sqlite.DB, query string, params []string) !string`

Executes a parameterized query and returns the **first column of the first row** as a string. Ideal for scalar aggregates (`COUNT`, `MAX`, `SUM`, etc.).

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE orders (user TEXT, amount INT);')!
sqliteutils.exec_sql(mut db, "INSERT INTO orders VALUES ('alice', 50), ('alice', 30), ('bob', 20);")!

total := sqliteutils.query_scalar(mut db, 'SELECT SUM(amount) FROM orders WHERE user = ?', ['alice'])!
println('Alice total: ${total}') // 80
```

---

### `query_column(mut db sqlite.DB, query string, params []string) ![]string`

Executes a parameterized query and returns **every value from the first column** as a `[]string`. Useful for fetching a list of IDs, names, tags, etc.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE tags (name TEXT, active INT);')!
sqliteutils.exec_sql(mut db, "INSERT INTO tags VALUES ('v','1'),('vlang','1'),('draft','0');")!

active_tags := sqliteutils.query_column(mut db, 'SELECT name FROM tags WHERE active = ?', ['1'])!
println('Active tags: ${active_tags}') // ['v', 'vlang']
```

---

### `with_transaction(mut db sqlite.DB, work fn () !) !`

Runs a closure inside a `BEGIN / COMMIT` transaction. If the closure returns an error the transaction is automatically rolled back. A clean, closure-style alternative to `execute_batch`.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.create_kv_table(mut db, 'state')!

sqliteutils.with_transaction(mut db, fn [mut db] () ! {
    sqliteutils.set_kv(mut db, 'state', 'step', '1')!
    sqliteutils.set_kv(mut db, 'state', 'status', 'ok')!
})!

println(sqliteutils.get_kv(mut db, 'state', 'status')!) // ok
```

---

## Column Management Helpers

> **SQLite version requirements**
> - `add_column` / `add_columns` — SQLite 3.1+ (always available)
> - `rename_column` — SQLite 3.25+ (September 2018)
> - `drop_column` / `drop_columns` — SQLite 3.35+ (March 2021)

### `ColumnDef`

A struct used with `add_column` and `add_columns` to describe a new column.

```v
pub struct ColumnDef {
pub:
    name     string // column identifier — validated by sanitize_identifier
    sql_type string // SQLite type expression, e.g. "TEXT", "INTEGER NOT NULL DEFAULT 0"
}
```

---

### `add_column(mut db sqlite.DB, table_name string, col ColumnDef) !`

Adds a single new column to an existing table using `ALTER TABLE … ADD COLUMN`.
The column name and type expression are both validated before the query runs.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);')!

// Add a plain text column
sqliteutils.add_column(mut db, 'users', sqliteutils.ColumnDef{
    name:     'email'
    sql_type: 'TEXT'
})!

// Add a column with constraints and a default value
sqliteutils.add_column(mut db, 'users', sqliteutils.ColumnDef{
    name:     'score'
    sql_type: 'INTEGER NOT NULL DEFAULT 0'
})!

cols := sqliteutils.get_column_names(mut db, 'users')!
println(cols) // ['id', 'name', 'email', 'score']
```

---

### `add_columns(mut db sqlite.DB, table_name string, cols []ColumnDef) !`

Adds multiple columns inside a single transaction. If any column name or type is invalid, or if SQLite rejects any of the `ALTER TABLE` statements, the entire batch is rolled back — either all columns are added or none are.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT);')!

sqliteutils.add_columns(mut db, 'products', [
    sqliteutils.ColumnDef{ name: 'price', sql_type: 'REAL' },
    sqliteutils.ColumnDef{ name: 'stock', sql_type: 'INTEGER NOT NULL DEFAULT 0' },
    sqliteutils.ColumnDef{ name: 'sku',   sql_type: 'TEXT' },
])!

println(sqliteutils.get_column_names(mut db, 'products')!)
// ['id', 'name', 'price', 'stock', 'sku']
```

---

### `rename_column(mut db sqlite.DB, table_name string, old_col string, new_col string) !`

Renames a column using `ALTER TABLE … RENAME COLUMN`. Existing data is preserved under the new column name. Both old and new names must pass identifier validation.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE users (id INT, fname TEXT, age INT);')!
sqliteutils.exec_sql(mut db, "INSERT INTO users VALUES (1, 'Alice', 30);")!

sqliteutils.rename_column(mut db, 'users', 'fname', 'first_name')!

cols := sqliteutils.get_column_names(mut db, 'users')!
println(cols) // ['id', 'first_name', 'age']

// Data is preserved
rows := sqliteutils.query_maps(mut db, 'SELECT first_name FROM users;')!
println(rows[0]['first_name']) // Alice
```

---

### `drop_column(mut db sqlite.DB, table_name string, col_name string) !`

Drops a single column from a table using `ALTER TABLE … DROP COLUMN`. The column name must pass identifier validation. Note: SQLite prevents dropping a column that is a primary key, part of an index, or referenced by a UNIQUE/CHECK constraint.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE events (id INT, msg TEXT, legacy TEXT, ts TEXT);')!
sqliteutils.exec_sql(mut db, "INSERT INTO events VALUES (1, 'boot', 'old_data', '2024-01-01');")!

sqliteutils.drop_column(mut db, 'events', 'legacy')!

cols := sqliteutils.get_column_names(mut db, 'events')!
println(cols) // ['id', 'msg', 'ts']
```

---

### `drop_columns(mut db sqlite.DB, table_name string, col_names []string) !`

Drops multiple columns inside a single transaction. If any column name is invalid or SQLite rejects any drop, the entire batch is rolled back — either all columns are dropped or none are.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db, 'CREATE TABLE logs (id INT, msg TEXT, level TEXT, host TEXT, pid INT);')!

// Remove infrastructure columns that are no longer needed
sqliteutils.drop_columns(mut db, 'logs', ['host', 'pid'])!

cols := sqliteutils.get_column_names(mut db, 'logs')!
println(cols) // ['id', 'msg', 'level']
```

---

### `get_table_schema(mut db sqlite.DB, table_name string) ![]map[string]string`

Returns full `PRAGMA table_info` schema for a table as a slice of maps. Each map contains the keys `"cid"`, `"name"`, `"type"`, `"notnull"`, `"dflt_value"`, and `"pk"`. Useful for schema introspection and migration tools.

```v
mut db := sqliteutils.open_db(':memory:')!
sqliteutils.exec_sql(mut db,
    'CREATE TABLE orders (id INTEGER PRIMARY KEY, user TEXT NOT NULL, amount REAL);')!

schema := sqliteutils.get_table_schema(mut db, 'orders')!
for col in schema {
    println('${col['name']} (${col['type']}) pk=${col['pk']} notnull=${col['notnull']}')
}
// id (INTEGER) pk=1 notnull=0
// user (TEXT) pk=0 notnull=1
// amount (REAL) pk=0 notnull=0
```

---

# strutils API

Import statement:
```v
import strutils
```

### `to_snake_case(s string) string`
Converts camelCase, PascalCase, kebab-case, or spaced strings into snake_case.
```v
assert strutils.to_snake_case('helloWorld') == 'hello_world'
```

---

### `to_kebab_case(s string) string`
Converts a string into kebab-case.
```v
assert strutils.to_kebab_case('hello_world') == 'hello-world'
```

---

### `to_camel_case(s string) string`
Converts snake_case or kebab-case into camelCase.
```v
assert strutils.to_camel_case('hello_world') == 'helloWorld'
```

---

### `to_pascal_case(s string) string`
Converts snake_case or kebab-case into PascalCase.
```v
assert strutils.to_pascal_case('hello_world') == 'HelloWorld'
```

---

### `to_title_case(s string) string`
Capitalizes the first letter of each word in a string.
```v
assert strutils.to_title_case('hello world_again') == 'Hello World Again'
```

---

### `slugify(s string) string`
Converts arbitrary text into a URL-friendly slug.
```v
assert strutils.slugify('Hello World! 2026') == 'hello-world-2026'
```

---

### `truncate(s string, max_len int, suffix string) string`
Truncates a string to a given rune length, appending suffix if truncated.
```v
assert strutils.truncate('Hello, world!', 8, '...') == 'Hello...'
```

---

### `truncate_words(s string, max_words int, suffix string) string`
Shortens a string to the specified number of words.
```v
assert strutils.truncate_words('The quick brown fox jumps', 3, '...') == 'The quick brown...'
```

---

### `pad_left(s string, width int, pad_char string) string`
Pads the beginning of a string until it reaches the specified width.
```v
assert strutils.pad_left('42', 5, '0') == '00042'
```

---

### `pad_right(s string, width int, pad_char string) string`
Pads the end of a string until it reaches the specified width.
```v
assert strutils.pad_right('hi', 5, ' ') == 'hi   '
```

---

### `pad_center(s string, width int, pad_char string) string`
Centers a string with symmetric padding.
```v
assert strutils.pad_center('v', 5, '=') == '==v=='
```

---

### `mask(s string, unmasked_start int, unmasked_end int, mask_char string) string`
Masks characters between unmasked start and end counts.
```v
assert strutils.mask('1234567890', 2, 2, '*') == '12******90'
```

---

### `mask_email(email string) string`
Redacts user portion of an email address for privacy.
```v
assert strutils.mask_email('john.doe@example.com') == 'j******e@example.com'
```

---

### `random_alphanumeric(len int) string`
Generates a random string containing letters (A-Z, a-z) and digits (0-9).
```v
token := strutils.random_alphanumeric(16)
```

---

### `strip_html_tags(s string) string`
Strips HTML/XML tags from a string.
```v
assert strutils.strip_html_tags('<p>Hello <b>World</b>!</p>') == 'Hello World!'
```

---

### `collapse_whitespace(s string) string`
Replaces multiple consecutive whitespace characters with a single space.
```v
assert strutils.collapse_whitespace('  hello   world  ') == 'hello world'
```

---

### `word_wrap(s string, width int) string`
Wraps a string so that lines do not exceed the specified width.
```v
wrapped := strutils.word_wrap('one two three four five', 10)
```

---

### `levenshtein_distance(a string, b string) int`
Calculates the minimum edit operations (insertions, deletions, substitutions) between two strings.
```v
assert strutils.levenshtein_distance('kitten', 'sitting') == 3
```

---

### `similarity(a string, b string) f64`
Returns similarity score between 0.0 (completely different) and 1.0 (identical).
```v
score := strutils.similarity('hello', 'hallo') // ~0.8
```

---

# sliceutils API

Import statement:
```v
import sliceutils
```

### `unique[T](arr []T) []T`
Returns a new slice with duplicate items removed, preserving order of first appearance.
```v
assert sliceutils.unique([1, 2, 2, 3, 1]) == [1, 2, 3]
```

---

### `intersection[T](a []T, b []T) []T`
Returns elements present in both slices.
```v
assert sliceutils.intersection([1, 2, 3], [2, 3, 4]) == [2, 3]
```

---

### `difference[T](a []T, b []T) []T`
Returns elements in `a` that are not present in `b`.
```v
assert sliceutils.difference([1, 2, 3], [2, 3, 4]) == [1]
```

---

### `union_slices[T](a []T, b []T) []T`
Combines two slices and returns only unique elements.
```v
assert sliceutils.union_slices([1, 2], [2, 3]) == [1, 2, 3]
```

---

### `chunk[T](arr []T, size int) [][]T`
Splits a slice into smaller chunks of given size.
```v
chunks := sliceutils.chunk([1, 2, 3, 4, 5], 2) // [[1, 2], [3, 4], [5]]
```

---

### `flatten[T](matrix [][]T) []T`
Flattens a 2D slice into a 1D slice.
```v
assert sliceutils.flatten([[1, 2], [3, 4]]) == [1, 2, 3, 4]
```

---

### `find_index[T](arr []T, pred fn (item T) bool) ?int`
Finds the index of the first item matching the predicate, or `none`.
```v
idx := sliceutils.find_index([10, 20, 30], fn (x int) bool { return x > 15 }) // 1
```

---

### `partition[T](arr []T, pred fn (item T) bool) ([]T, []T)`
Partitions elements into two slices: those matching the predicate and those that do not.
```v
evens, odds := sliceutils.partition([1, 2, 3, 4], fn (x int) bool { return x % 2 == 0 })
```

---

### `count[T](arr []T, target T) int`
Counts how many times `target` appears in the slice.
```v
assert sliceutils.count(['a', 'b', 'a'], 'a') == 2
```

---

### `sample[T](arr []T, n int) []T`
Randomly selects `n` items without replacement.
```v
picks := sliceutils.sample([1, 2, 3, 4, 5], 3)
```

---

### `shuffle[T](mut arr []T)`
Randomly shuffles slice elements in-place using Fisher-Yates.
```v
mut items := [1, 2, 3, 4, 5]
sliceutils.shuffle(mut items)
```

---

### `sum_int(arr []int) int` and `average_int(arr []int) f64`
Numeric aggregations for integer slices.
```v
assert sliceutils.sum_int([1, 2, 3, 4]) == 10
assert sliceutils.average_int([1, 2, 3, 4]) == 2.5
```

---

# envutils API

Import statement:
```v
import envutils
```

### `get_str(key string, default_val string) string`
Gets environment variable string, or fallback if unset/empty.
```v
host := envutils.get_str('APP_HOST', 'localhost')
```

---

### `get_int(key string, default_val int) int`
Gets environment variable parsed as integer, or fallback.
```v
port := envutils.get_int('PORT', 8080)
```

---

### `get_bool(key string, default_val bool) bool`
Interprets `'true'`, `'1'`, `'yes'`, `'on'` as `true`, and `'false'`, `'0'`, `'no'`, `'off'` as `false`.
```v
debug := envutils.get_bool('DEBUG', false)
```

---

### `get_required(key string) !string`
Returns the environment variable value or errors if missing/empty.
```v
secret := envutils.get_required('JWT_SECRET')!
```

---

### `load_dotenv(path string) !map[string]string`
Loads a `.env` file into the OS environment and returns the key-value map.
```v
envutils.load_dotenv('.env')!
```

---

### `expand_env(input string) string`
Substitutes `$VAR` and `${VAR}` in strings with current environment values.
```v
path := envutils.expand_env('/home/${USER}/config')
```

---

# cryptoutils API

Import statement:
```v
import cryptoutils
```

### `sha256(s string) string`
Returns the hexadecimal SHA-256 hash.
```v
hash := cryptoutils.sha256('hello')
```

---

### `sha512(s string) string`
Returns the hexadecimal SHA-512 hash.
```v
hash := cryptoutils.sha512('hello')
```

---

### `md5(s string) string`
Returns the hexadecimal MD5 hash.
```v
hash := cryptoutils.md5('hello')
```

---

### `hmac_sha256(key string, data string) string`
Computes HMAC-SHA256 digest in hex.
```v
mac := cryptoutils.hmac_sha256('my-secret-key', 'message payload')
```

---

### `base64_encode(s string) string` & `base64_decode(s string) !string`
Standard Base64 encoding and decoding.
```v
encoded := cryptoutils.base64_encode('Hello V')
decoded := cryptoutils.base64_decode(encoded)!
```

---

### `base64_url_encode(s string) string` & `base64_url_decode(s string) !string`
URL-safe Base64 encoding and decoding without padding.
```v
url_safe := cryptoutils.base64_url_encode('Hello V')
```

---

### `uuid_v4() string` & `is_valid_uuid(s string) bool`
Generates RFC 4122 v4 UUIDs and validates UUID format strings.
```v
id := cryptoutils.uuid_v4()
assert cryptoutils.is_valid_uuid(id)
```

---

### `secure_token(byte_count int) string`
Generates a cryptographically random hexadecimal string of given byte length.
```v
token := cryptoutils.secure_token(32) // 64 hex characters
```

---

# timeutils API

Import statement:
```v
import timeutils
import time
```

### `time_ago(t time.Time) string`
Returns a human-friendly relative time string.
```v
println(timeutils.time_ago(time.now().add(-120 * time.second))) // "2 minutes ago"
```

---

### `time_until(t time.Time) string`
Returns a human-friendly relative time string for future timestamps.
```v
println(timeutils.time_until(time.now().add(7200 * time.second))) // "in 2 hours"
```

---

### `format_duration(d time.Duration) string`
Formats duration into readable units (e.g. `'250ms'`, `'2m 5s'`, `'1h 10m'`).
```v
println(timeutils.format_duration(125 * time.second)) // "2m 5s"
```

---

### `to_iso8601(t time.Time) string` & `from_iso8601(s string) !time.Time`
Serializes and parses ISO 8601 / RFC 3339 timestamps.
```v
iso := timeutils.to_iso8601(time.now())
parsed := timeutils.from_iso8601(iso)!
```

---

### `start_of_day(t time.Time) time.Time` & `end_of_day(t time.Time) time.Time`
Returns 00:00:00.000 or 23:59:59.999 for the given date.
```v
today_start := timeutils.start_of_day(time.now())
```

---

### `is_weekend(t time.Time) bool`
Checks if `t` falls on Saturday or Sunday.
```v
if timeutils.is_weekend(time.now()) {
    println('Weekend!')
}
```

---

### `Stopwatch`
High-resolution timer for benchmarks.
```v
mut sw := timeutils.new_stopwatch()
// perform work...
sw.stop()
println('Elapsed: ${sw.elapsed_ms():.2f} ms')
```

---

# httputils API

Import statement:
```v
import httputils
```

### `build_query_string(params map[string]string) string`
Encodes parameter map into URL query string.
```v
qs := httputils.build_query_string({ 'page': '1', 'search': 'vlang' }) // "page=1&search=vlang"
```

---

### `parse_query_string(query string) map[string]string`
Parses query string into key-value map.
```v
params := httputils.parse_query_string('?page=1&search=vlang')
```

---

### `get_text(url string, headers map[string]string) !string`
Fetches a URL and returns text body.
```v
body := httputils.get_text('https://httpbin.org/get', {})!
```

---

### `get_json[T](url string, headers map[string]string) !T`
Fetches JSON endpoint and parses directly into struct `T`.
```v
struct UserInfo {
    id   int
    name string
}
user := httputils.get_json[UserInfo]('https://api.example.com/user/1', {})!
```

---

### `download_file(url string, dest_path string) !`
Downloads a file directly to disk, creating parent folders automatically.
```v
httputils.download_file('https://example.com/archive.zip', 'downloads/archive.zip')!
```

---

# cliutils API

Import statement:
```v
import cliutils
```

### ANSI Colors & Styles
Zero external dependencies, terminal styling helpers:
```v
println(cliutils.bold('Bold text'))
println(cliutils.green('Success message'))
println(cliutils.red('Error message'))
println(cliutils.yellow('Warning message'))
println(cliutils.cyan('Info message'))
```

---

### `strip_ansi(s string) string`
Strips ANSI formatting codes from a string for plain-text logging.
```v
plain := cliutils.strip_ansi(cliutils.bold(cliutils.red('Error'))) // "Error"
```

---

### `ProgressBar`
Interactive terminal ASCII progress bar.
```v
mut pb := cliutils.new_progress_bar(100, 25)
pb.update(50)
println(pb.render()) // "[============>            ]  50% (50/100)"
```

---

### `sparkline(values []f64) string`
Renders an in-line sparkline chart using UTF-8 block characters (` ▂▃▄▅▆▇█`).
```v
spark := cliutils.sparkline([1.0, 3.0, 5.0, 8.0, 4.0, 2.0, 9.0, 7.0, 10.0])
println('Activity: ${spark}')
```

---

### `bar_chart(title string, items map[string]f64, max_width int) string`
Generates a horizontal ASCII/Unicode bar chart.
```v
chart := cliutils.bar_chart('Server Load', {
    'Web': 45.0
    'DB': 85.0
    'Cache': 20.0
}, 25)
println(chart)
```

---

### `gauge(label string, current f64, max f64, unit string) string`
Generates a single-metric meter gauge with percentage and threshold status ([OK], [WARN], [CRITICAL]).
```v
println(cliutils.gauge('RAM', 7.5, 16.0, 'GB'))
```

---

### `render_tree(root TreeNode) string`
Renders a hierarchical directory-like tree structure using Unicode branch lines.
```v
tree := cliutils.TreeNode{
    label: 'Root'
    children: [
        cliutils.TreeNode{ label: 'File 1.txt' },
        cliutils.TreeNode{
            label: 'Folder'
            children: [
                cliutils.TreeNode{ label: 'Subfile.v' }
            ]
        }
    ]
}
println(cliutils.render_tree(tree))
```

---

### `diff(old_lines []string, new_lines []string) []DiffLine` & `diff_text(old_text string, new_text string) string`
Computes and formats a color-coded unified diff between two texts.
```v
diff_output := cliutils.diff_text("line 1\nold line", "line 1\nnew line")
println(diff_output)
```

---

### Table Formatting: `table_to_markdown`, `table_to_csv`, `table_to_json`
Formats tabular data into markdown tables, CSV format, or JSON structures.
```v
headers := ['ID', 'Name', 'Role']
rows := [
    ['1', 'Alice', 'Admin'],
    ['2', 'Bob', 'Member'],
]
md_table := cliutils.table_to_markdown(headers, rows)
csv_table := cliutils.table_to_csv(headers, rows)
json_table := cliutils.table_to_json(headers, rows)
```

---

### `FlagParser`
Lightweight, ergonomic CLI argument and option parser.
```v
mut fp := cliutils.new_flag_parser(['--port', '8080', '-v', 'run', 'main.v'])
port := fp.get_int('port', 3000)      // 8080
verbose := fp.get_bool('v', false)    // true
cmd := fp.args[0]                     // "run"
```

---

### `Pipeline` & `Logger`
Functional step pipeline and structured console logging.
```v
mut pipe := cliutils.new_pipeline('Build Pipeline')
pipe.step('Check Env', fn () ! { /* verify */ })
pipe.step('Compile', fn () ! { /* build */ })
res := pipe.run()

mut logger := cliutils.new_logger(cliutils.LogLevel.info)
logger.info('Application starting')
logger.warn('High memory usage detected')
```

---

# sysutils API

Import statement:
```v
import sysutils
```

### System Telemetry

#### `get_cpu_count() int`
Returns the count of logical CPU cores on the host.
```v
cores := sysutils.get_cpu_count()
```

#### `get_cpu_usage() f64`
Returns the current total CPU usage percentage (0.0 to 100.0).
```v
usage := sysutils.get_cpu_usage()
```

#### `get_load_averages() (f64, f64, f64)`
Returns the 1-minute, 5-minute, and 15-minute system load averages.
```v
l1, l5, l15 := sysutils.get_load_averages()
```

#### `get_memory_stats() (u64, u64, f64)`
Returns `(total_bytes, used_bytes, used_percent)` for physical RAM.
```v
total, used, pct := sysutils.get_memory_stats()
```

#### `get_swap_stats() (u64, u64, f64)`
Returns `(total_bytes, used_bytes, used_percent)` for swap memory.
```v
total, used, pct := sysutils.get_swap_stats()
```

#### `get_disk_stats(path string) (u64, u64, f64)`
Returns `(total_bytes, used_bytes, used_percent)` for the filesystem containing `path`.
```v
total, used, pct := sysutils.get_disk_stats('/')
```

#### `get_uptime() i64`
Returns the system uptime in seconds.
```v
secs := sysutils.get_uptime()
```

#### `get_system_locale() string` & `get_os_theme() string`
Detects user language/locale (e.g. `en_US.UTF-8`) and dark/light OS theme (`"dark"` or `"light"`).
```v
locale := sysutils.get_system_locale()
theme := sysutils.get_os_theme()
```

---

### Process Security & Safe Execution

#### `exec_safe(cmd string, args []string) (string, int)`
Safely executes an external command with arguments, avoiding shell injection risks.
```v
out, code := sysutils.exec_safe('git', ['status', '--short'])
```

#### `quote_arg(arg string) string` & `sanitize_filename(name string) string`
Quotes command-line arguments to prevent shell expansion, and cleans filename inputs from traversal attempts.
```v
clean_path := sysutils.sanitize_filename('../../etc/secret.txt') // "secret.txt"
```

#### `has_command(name string) bool` & `is_process_running(pid int) bool`
Checks if an executable exists on the system `$PATH`, and whether a PID is alive.
```v
has_git := sysutils.has_command('git')
is_alive := sysutils.is_process_running(1234)
```

---

### Standard Paths & Clipboard

#### `get_app_config_dir(app_name string) string` & `get_app_data_dir(app_name string) string`
Returns standard cross-platform directories for configuration, persistent data, cache, and logs.
```v
cfg_dir := sysutils.get_app_config_dir('my_app')
data_dir := sysutils.get_app_data_dir('my_app')
```

#### `copy_to_clipboard(text string) !` & `get_clipboard_text() !string`
Cross-platform system clipboard read and write.
```v
sysutils.copy_to_clipboard('Copied payload')!
text := sysutils.get_clipboard_text()!
```

---

# netutils API

Import statement:
```v
import netutils
```

### `is_online() bool`
Checks whether active Internet connectivity is present.
```v
if netutils.is_online() {
    println('Connected!')
}
```

### `get_local_ip() string` & `get_public_ip() !string`
Returns the machine's local subnet IP (e.g. `192.168.1.100`) and queries external public IP.
```v
local := netutils.get_local_ip()
public := netutils.get_public_ip()!
```

### `get_dns_servers() []string`
Returns configured DNS nameserver IP addresses.
```v
dns := netutils.get_dns_servers()
```

### `ping_tcp_port(host string, port int, timeout_ms int) bool`
Checks if a TCP service is listening and reachable on the given host and port.
```v
is_up := netutils.ping_tcp_port('google.com', 443, 1000)
```

### `get_listening_ports() []int`
Discovers open TCP listening ports on the local machine.
```v
ports := netutils.get_listening_ports()
```

---

# validutils API

Import statement:
```v
import validutils
```

### `validate_email(email string) bool`
Validates email address syntax according to RFC mailbox standards.
```v
valid := validutils.validate_email('developer@example.com') // true
```

### `validate_url(url string) bool`
Checks whether a string is a valid HTTP/HTTPS URL.
```v
valid := validutils.validate_url('https://vlang.io') // true
```

### `validate_ip(ip string) bool`
Validates IPv4 or IPv6 address strings.
```v
v4 := validutils.validate_ip('192.168.0.1') // true
v6 := validutils.validate_ip('::1')          // true
```

### `validate_uuid(uuid_str string) bool`
Validates RFC 4122 standard UUID strings.
```v
valid := validutils.validate_uuid('123e4567-e89b-12d3-a456-426614174000') // true
```

### `validate_json(s string) bool`
Validates whether a string is syntactically valid JSON.
```v
valid := validutils.validate_json('{"key": "value"}') // true
```

### `validate_alphanumeric(s string) bool` & `validate_numeric_range(n f64, min f64, max f64) bool`
Validates character sets and numeric constraints.
```v
alpha := validutils.validate_alphanumeric('Username123') // true
in_range := validutils.validate_numeric_range(25.0, 10.0, 50.0) // true
```

---

# structutils API

Import statement:
```v
import structutils
```

### Generic Stack (LIFO): `SimpleStack[T]`
```v
mut stack := structutils.new_stack[string]()
stack.push('alpha')
stack.push('beta')
top := stack.pop() // 'beta'
len := stack.len() // 1
```

### Generic Queue (FIFO): `SimpleQueue[T]`
```v
mut queue := structutils.new_queue[int]()
queue.push(10)
queue.push(20)
first := queue.pop() // 10
```

### Circular Ring Buffer: `SimpleRingBuffer[T]`
Fixed-capacity buffer that automatically overwrites oldest items when full.
```v
mut ring := structutils.new_ring_buffer[string](3)
ring.push('a')
ring.push('b')
ring.push('c')
ring.push('d') // 'a' is discarded
items := ring.to_array() // ['b', 'c', 'd']
```

### Min-Heap Priority Queue: `SimpleMinHeap`
Binary min-heap where lowest values are popped first.
```v
mut heap := structutils.new_min_heap()
heap.push(50.0)
heap.push(10.0)
heap.push(30.0)
smallest := heap.pop() // 10.0
```

---

# statutils API

Import statement:
```v
import statutils
```

### `stats_mean(arr []f64) f64` & `stats_median(arr []f64) f64`
Calculates arithmetic mean and median.
```v
data := [10.0, 20.0, 30.0, 40.0, 50.0]
avg := statutils.stats_mean(data)     // 30.0
med := statutils.stats_median(data)   // 30.0
```

### `stats_mode(arr []f64) ?f64`
Finds the most frequent value.
```v
mode := statutils.stats_mode([1.0, 2.0, 2.0, 3.0]) // 2.0
```

### `stats_variance(arr []f64) f64` & `stats_std_dev(arr []f64) f64`
Computes population variance and standard deviation.
```v
sd := statutils.stats_std_dev(data)
```

### `stats_percentile(arr []f64, p f64) f64`
Calculates any percentile (0.0 to 100.0) using linear interpolation.
```v
p95 := statutils.stats_percentile(data, 95.0)
```

### `stats_geometric_mean(arr []f64) f64` & `stats_rms(arr []f64) f64`
Computes geometric mean, harmonic mean, and root-mean-square (RMS).
```v
geom := statutils.stats_geometric_mean([2.0, 8.0]) // 4.0
rms := statutils.stats_rms([3.0, 4.0])             // 3.535
```

---

# stateutils API

Import statement:
```v
import stateutils
```

### OS-Recommended Path Resolution

#### `get_app_dir(app_name string, loc StateLocation) string`
Returns the OS-recommended directory for an application:
- **macOS**: `~/Library/Application Support/<app_name>`
- **Windows**: `%APPDATA%/<app_name>`
- **Linux**: `$XDG_DATA_HOME/<app_name>` or `~/.local/share/<app_name>`
Automatically creates the directory if it does not already exist.

```v
data_dir := stateutils.get_app_dir('my_app', .data)
config_dir := stateutils.get_app_dir('my_app', .config)
```

#### `get_state_path(app_name string, filename string, loc StateLocation) string`
Resolves the complete absolute path for a state file in the recommended directory.

```v
path := stateutils.get_state_path('my_app', 'state.json', .data)
```

---

### Direct State Functions

#### `save_app_state[T](app_name string, filename string, state T) !`
Atomically serializes and persists a struct to disk without corrupting existing data if interrupted.

```v
struct UserPrefs {
    theme string
    sound bool
}

stateutils.save_app_state('my_app', 'prefs.json', UserPrefs{ theme: 'dark', sound: true })!
```

#### `load_app_state[T](app_name string, filename string) !T`
Loads and deserializes a struct from the recommended app data path.

```v
prefs := stateutils.load_app_state[UserPrefs]('my_app', 'prefs.json')!
```

#### `load_app_state_or[T](app_name string, filename string, default_val T) T`
Loads state if available, or gracefully falls back to `default_val`.

```v
prefs := stateutils.load_app_state_or('my_app', 'prefs.json', UserPrefs{ theme: 'system', sound: false })
```

#### `app_state_exists(app_name string, filename string) bool` & `delete_app_state(app_name string, filename string) !`
Checks for the presence of a state file or deletes it.

```v
if stateutils.app_state_exists('my_app', 'prefs.json') {
    stateutils.delete_app_state('my_app', 'prefs.json')!
}
```

---

### `AppStateStore[T]` - Managed Generic Store

Manages memory state, atomic disk persistence, auto-saving, backups, and rollback.

```v
struct Settings {
pub mut:
    window_w int
    window_h int
    theme    string
}

mut store := stateutils.new_app_state[Settings]('my_app', Settings{
    window_w: 1280
    window_h: 720
    theme:    'dark'
})

// Access current state
w := store.get().window_w

// Modify state via updater callback
store.update(fn (mut s Settings) {
    s.window_w = 1920
    s.theme = 'nord'
})!
store.save()! // persists atomically

// Backup & Rollback
bak_file := store.backup()! // saves .bak
store.set(Settings{ window_w: 800, window_h: 600, theme: 'light' })!
store.rollback()! // reverts from .bak

// Auto-save mode
store.auto_save = true
store.update(fn (mut s Settings) {
    s.theme = 'dracula'
})! // automatically saved to disk
```

---

### `KeyValueState` - Dynamic App State

For apps that need schema-free configuration and preferences.

```v
mut kv := stateutils.new_kv_state('my_app')
kv.auto_save = true

// Typed setters & getters with fallbacks
kv.set_str('current_profile', 'guest')!
kv.set_int('volume', 85)!
kv.set_bool('notifications', true)!
kv.set_f64('scale', 1.5)!

profile := kv.get_str('current_profile', 'default')
volume  := kv.get_int('volume', 100)
notify  := kv.get_bool('notifications', false)

// Management
kv.has('volume') // true
kv.delete('scale')!
kv.clear()!
kv.reset()! // clears memory and removes file from disk
```



