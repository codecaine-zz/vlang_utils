# vlang_utils

A small V utility module for common file and data persistence tasks used in rapid application development.

## Features

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

## Quick start

Import the module in your project:

```v
import fileutils
```

Example: save and load a list of structs:

```v
struct Person {
    name string
    age  int
}

people := [Person{ name: 'Alice', age: 30 }]
fileutils.save_struct_array_to_file('people.json', people)!
loaded := fileutils.load_struct_array_from_file[Person]('people.json')!
```

More examples:

```v
// Write a text file and create parent folders automatically
fileutils.write_text_file('logs/app.txt', 'hello from v')!
```

```v
// Append a line to an existing text file
fileutils.append_line_to_file('logs/app.log', 'startup complete')!
```

```v
// Load a config file with sensible defaults
defaults := {
    'host': 'localhost'
    'port': '3000'
}
config := fileutils.load_config_from_file('app.conf', defaults)!
```

```v
// Save a single struct as JSON
fileutils.save_struct_to_file('person.json', Person{ name: 'Bob', age: 25 })!
```

## Demo

Run the included example program:

```bash
v run .
```

The demo writes sample output into the .fileutils_demo folder and prints the results to the console.

## API overview

See [API.md](API.md) for a function-by-function reference.

## What changed

Recent updates make the library more ergonomic for everyday use:

- Writing to nested paths now creates missing parent folders automatically.
- Plain text helpers were added for simple file reads and writes.
- Config parsing now handles comments and empty values more gracefully.
