# fileutils API

## Struct helpers

### save_struct_array_to_file[T](path string, data []T) !

Saves a slice of structs to disk as JSON.

```v
struct Person {
    name string
    age  int
}

people := [Person{ name: 'Alice', age: 30 }, Person{ name: 'Bob', age: 25 }]
fileutils.save_struct_array_to_file('people.json', people)!
```

### load_struct_array_from_file[T](path string) ![]T

Loads a slice of structs from a JSON file back into memory.

```v
struct Person {
    name string
    age  int
}

people := fileutils.load_struct_array_from_file[Person]('people.json')!
println(people[0].name)
```

### save_struct_to_file[T](path string, data T) !

Saves a single struct to disk as JSON.

```v
struct Person {
    name string
    age  int
}

person := Person{ name: 'Charlie', age: 40 }
fileutils.save_struct_to_file('person.json', person)!
```

### load_struct_from_file[T](path string) !T

Loads a single struct from a JSON file.

```v
struct Person {
    name string
    age  int
}

person := fileutils.load_struct_from_file[Person]('person.json')!
println(person.name)
```

## Text file helpers

### append_line_to_file(path string, line string) !

Appends a single line to a text file, creating the file if needed.

```v
fileutils.append_line_to_file('notes.log', 'First log entry')!
fileutils.append_line_to_file('notes.log', 'Second log entry')!
```

### write_text_file(path string, content string) !

Writes a text file, creating parent directories automatically.

```v
fileutils.write_text_file('notes.txt', 'hello world')!
```

### read_text_file(path string) !string

Reads a text file into memory.

```v
content := fileutils.read_text_file('notes.txt')!
println(content)
```

### read_lines_from_file(path string) ![]string

Reads a file into a slice of lines for simple text processing.

```v
lines := fileutils.read_lines_from_file('notes.log')!
for line in lines {
    println(line)
}
```

## Map and config helpers

### save_map_to_file[K, V](path string, data map[K]V) !

Saves a map to disk as JSON for simple configuration or lookup data.

```v
mut settings := map[string]int{}
settings['alpha'] = 1
settings['beta'] = 2
fileutils.save_map_to_file('settings.json', settings)!
```

### load_map_from_file[K, V](path string) !map[K]V

Loads a map from a JSON file into memory.

```v
settings := fileutils.load_map_from_file[string, int]('settings.json')!
println(settings['alpha'])
```

### load_config_from_file(path string, defaults map[string]string) !map[string]string

Loads a simple key=value config file, overlaying values onto provided defaults.

```v
defaults := {
    'host': 'localhost'
    'port': '3000'
}
config := fileutils.load_config_from_file('app.conf', defaults)!
println(config['host'])
```

## Directory helpers

### ensure_dir_exists(path string) !

Creates the parent directory for a file path when it does not exist.

```v
fileutils.ensure_dir_exists('nested/deep/output.txt')!
```

## JSON helpers

### write_json_file[T](path string, data T) !

Writes any JSON-serializable value to a file.

```v
struct Person {
    name string
    age  int
}

person := Person{ name: 'Dana', age: 35 }
fileutils.write_json_file('profile.json', person)!
```

### read_json_file[T](path string) !T

Reads a JSON file into a value of the requested type.

```v
struct Person {
    name string
    age  int
}

person := fileutils.read_json_file[Person]('profile.json')!
println(person.name)
```

### append_json_line[T](path string, data T) !

Appends one JSON object as a new line in a newline-delimited JSON file.

```v
struct Person {
    name string
    age  int
}

fileutils.append_json_line('people.ndjson', Person{ name: 'Eli', age: 28 })!
fileutils.append_json_line('people.ndjson', Person{ name: 'Fay', age: 32 })!
```
