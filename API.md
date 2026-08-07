# fileutils & sqliteutils API Reference

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
