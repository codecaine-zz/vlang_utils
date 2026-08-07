# vlang_utils

A suite of ergonomic V utility modules (`fileutils` and `sqliteutils`) for common file system operations and SQLite data persistence used in rapid application development (RAD).

## Features

### `fileutils`
- Save and load arrays of structs from JSON files
- Save and load single structs from JSON files
- Append lines to text files
- Write and read plain text files
- Save and load maps to JSON files
- Create parent directories for file paths automatically
- Read line-based text files
- Load simple key/value config files with defaults
- Write and read JSON files for arbitrary values
- Append JSON objects as newline-delimited JSON (NDJSON)

### `sqliteutils`

**Connection & Inspection**
- Automatic parent directory creation when opening SQLite database files
- Table inspection: `table_exists`, `get_table_names`, `count_rows`

**Schema / DDL**
- `drop_table` (with optional `IF EXISTS` via `force` flag)
- `rename_table`, `clear_table` (truncate equivalent)
- `get_column_names`, `column_exists`, `table_row_counts`

**Key-Value Store**
- Full KV CRUD: `create_kv_table`, `set_kv`, `get_kv`, `delete_kv`, `get_all_kv`
- Extended KV: `kv_exists`, `get_kv_or` (never-error fallback), `increment_kv`, `clear_kv`

**JSON Document Store (struct persistence)**
- Full doc CRUD: `create_json_store`, `save_struct`, `load_struct`, `load_all_structs`, `delete_struct`
- Extended doc store: `struct_exists`, `count_structs`, `list_struct_ids`, `delete_all_structs`

**Queries (all parameterized — SQL-injection safe)**
- `query_maps`, `query_maps_params` — rows as `[]map[string]string`
- `query_one_map`, `query_one_map_params` — first row as `map[string]string`
- `query_scalar` — single aggregate value (COUNT, SUM, MAX…)
- `query_column` — first column of all rows as `[]string`

**Transactions**
- `execute_batch` — static SQL statements in a single atomic transaction
- `execute_batch_params` — parameterized statements via `[]ParamStatement`
- `with_transaction` — closure-style transaction with automatic rollback on error

**Security**
- All user-supplied *values* use `?` parameter binding via `exec_param` / `exec_param_many`
- All table/column *identifiers* are validated through `sanitize_identifier` (allowlist: letters, digits, `_`, `-`)

## Quick Start Examples

Below are complete, standalone examples that beginners can copy and run directly.

### 1. File Utilities (`fileutils`)

Save and load data structures to disk without boilerplate:

```v
module main

import fileutils

// Define your data structure
struct Person {
    name string
    age  int
}

fn main() {
    // 1. Save a list of structs to a JSON file
    people := [
        Person{ name: 'Alice', age: 30 },
        Person{ name: 'Bob', age: 25 }
    ]
    fileutils.save_struct_array_to_file('data/people.json', people)!
    println('Saved people array to JSON file!')

    // 2. Load the list back from disk into memory
    loaded_people := fileutils.load_struct_array_from_file[Person]('data/people.json')!
    for p in loaded_people {
        println('Found person: ${p.name}, age ${p.age}')
    }

    // 3. Write a text file (automatically creates nested folders like "logs/")
    fileutils.write_text_file('logs/app.log', 'Application started successfully\n')!

    // 4. Append a new log line
    fileutils.append_line_to_file('logs/app.log', 'User logged in')!
}
```

### 2. SQLite Utilities (`sqliteutils`)

Store key-value settings, persist structs, run safe parameterized queries, and manage schema with SQLite:

```v
module main

import sqliteutils

struct User {
    name  string
    email string
}

fn main() {
    // 1. Open SQLite database (creates 'data/' folder automatically if missing)
    mut db := sqliteutils.open_db('data/app.db')!
    println('Connected to SQLite database!')

    // 2. Schema helpers
    sqliteutils.exec_sql(mut db, 'CREATE TABLE IF NOT EXISTS logs (msg TEXT, level TEXT);')!
    cols := sqliteutils.get_column_names(mut db, 'logs')!
    println('logs columns: ${cols}') // ['msg', 'level']

    // 3. Key-Value Store — save app settings
    sqliteutils.create_kv_table(mut db, 'settings')!
    sqliteutils.set_kv(mut db, 'settings', 'theme', 'dark')!
    sqliteutils.set_kv(mut db, 'settings', 'notifications', 'enabled')!

    // get_kv_or never errors — returns default when key is absent
    theme := sqliteutils.get_kv_or(mut db, 'settings', 'theme', 'light')
    println('Current theme: ${theme}')

    // Increment a counter (creates key automatically)
    views := sqliteutils.increment_kv(mut db, 'settings', 'page_views', 1)!
    println('Page views: ${views}')

    // 4. JSON Struct Store — persist structs directly in SQLite
    sqliteutils.create_json_store(mut db, 'users')!
    alice := User{ name: 'Alice', email: 'alice@example.com' }
    sqliteutils.save_struct(mut db, 'users', 'user_101', alice)!

    // Check existence before loading
    if sqliteutils.struct_exists(mut db, 'users', 'user_101')! {
        loaded := sqliteutils.load_struct[User](mut db, 'users', 'user_101')!
        println('Loaded: ${loaded.name} (${loaded.email})')
    }

    // 5. Parameterized queries — safe from SQL injection
    sqliteutils.exec_sql(mut db, 'CREATE TABLE orders (user TEXT, amount INT);')!
    sqliteutils.exec_param_many(mut db, 'INSERT INTO orders VALUES (?, ?)', ['alice', '50'])
    sqliteutils.exec_param_many(mut db, 'INSERT INTO orders VALUES (?, ?)', ['alice', '30'])

    total := sqliteutils.query_scalar(mut db, 'SELECT SUM(amount) FROM orders WHERE user = ?', ['alice'])!
    println('Alice total: ${total}')

    // 6. Closure-style transaction — auto-rollback on error
    sqliteutils.with_transaction(mut db, fn [mut db] () ! {
        sqliteutils.set_kv(mut db, 'settings', 'step', '1')!
        sqliteutils.set_kv(mut db, 'settings', 'status', 'ok')!
    })!
    println('Transaction committed!')
}
```

## Running the Included Demo

To see a complete live demonstration of all features running together:

```bash
v run .
```

The demo program ([main.v](main.v)) creates output files in `.fileutils_demo/` and `.sqliteutils_demo/` and prints output to your console.

## API Documentation

For full details on every available function and parameter, see [API.md](API.md).

