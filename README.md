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
- Automatic parent directory creation when opening SQLite database files
- Simple Key-Value store table management (`create_kv_table`, `set_kv`, `get_kv`, `delete_kv`, `get_all_kv`)
- JSON Document Store for structs (`create_json_store`, `save_struct`, `load_struct`, `load_all_structs`, `delete_struct`)
- Dynamic SELECT queries mapped directly to `[]map[string]string` (`query_maps`, `query_one_map`)
- Batch SQL execution inside managed transactions with automatic rollback (`execute_batch`)
- Table inspection & helper utilities (`table_exists`, `get_table_names`, `count_rows`)

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

Store key-value settings, persist structs, and run dynamic queries with SQLite:

```v
module main

import sqliteutils

// Define your data structure
struct User {
    name  string
    email string
}

fn main() {
    // 1. Open SQLite database (creates 'data/' folder automatically if missing)
    mut db := sqliteutils.open_db('data/app.db')!
    println('Connected to SQLite database!')

    // 2. Key-Value Store Example: Save app configuration settings
    sqliteutils.create_kv_table(mut db, 'settings')!
    sqliteutils.set_kv(mut db, 'settings', 'theme', 'dark')!
    sqliteutils.set_kv(mut db, 'settings', 'notifications', 'enabled')!

    // Read back a setting with fallback default value
    theme := sqliteutils.get_kv(mut db, 'settings', 'theme') or { 'light' }
    println('Current theme: ${theme}')

    // 3. JSON Struct Store Example: Store struct objects directly in SQLite
    sqliteutils.create_json_store(mut db, 'users')!
    alice := User{ name: 'Alice', email: 'alice@example.com' }
    sqliteutils.save_struct(mut db, 'users', 'user_101', alice)!

    // Load struct by ID
    loaded_user := sqliteutils.load_struct[User](mut db, 'users', 'user_101')!
    println('Loaded user from SQLite: ${loaded_user.name} (${loaded_user.email})')

    // 4. Dynamic Query Example: Query rows as a list of column-value maps
    rows := sqliteutils.query_maps(mut db, "SELECT key, val FROM settings;")!
    for row in rows {
        println('Setting: ${row['key']} = ${row['val']}')
    }
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
