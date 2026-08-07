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
