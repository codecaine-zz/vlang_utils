module fileutils

import json
import os

// Saves a slice of structs to disk as JSON.
pub fn save_struct_array_to_file[T](path string, data []T) ! {
	ensure_dir_exists(path) or { return err }
	encoded := json.encode(data)
	os.write_file(path, encoded) or { return err }
}

// Loads a slice of structs from a JSON file back into memory.
pub fn load_struct_array_from_file[T](path string) ![]T {
	content := os.read_file(path) or { return err }
	return json.decode([]T, content)
}

// Saves a single struct to disk as JSON.
pub fn save_struct_to_file[T](path string, data T) ! {
	ensure_dir_exists(path) or { return err }
	encoded := json.encode(data)
	os.write_file(path, encoded) or { return err }
}

// Loads a single struct from a JSON file.
pub fn load_struct_from_file[T](path string) !T {
	content := os.read_file(path) or { return err }
	return json.decode(T, content)
}

// Appends a single line to a text file, creating the file if needed.
pub fn append_line_to_file(path string, line string) ! {
	ensure_dir_exists(path) or { return err }
	mut content := ''
	if os.exists(path) {
		content = os.read_file(path) or { return err }
	}
	if content.len > 0 {
		content += '\n'
	}
	content += line
	os.write_file(path, content) or { return err }
}

// Writes a text file, creating parent directories automatically.
pub fn write_text_file(path string, content string) ! {
	ensure_dir_exists(path) or { return err }
	os.write_file(path, content) or { return err }
}

// Reads a text file into memory.
pub fn read_text_file(path string) !string {
	return os.read_file(path)
}

// Saves a map to disk as JSON for simple configuration or lookup data.
pub fn save_map_to_file[K, V](path string, data map[K]V) ! {
	ensure_dir_exists(path) or { return err }
	encoded := json.encode(data)
	os.write_file(path, encoded) or { return err }
}

// Loads a map from a JSON file into memory.
pub fn load_map_from_file[K, V](path string) !map[K]V {
	content := os.read_file(path) or { return err }
	return json.decode(map[K]V, content)
}

// Creates the parent directory for a file path when it does not exist.
pub fn ensure_dir_exists(path string) ! {
	dir := os.dir(path)
	if dir.len > 0 {
		os.mkdir_all(dir) or { return err }
	}
}

// Reads a file into a slice of lines for simple text processing.
pub fn read_lines_from_file(path string) ![]string {
	content := os.read_file(path) or { return err }
	return content.split_into_lines()
}

// Loads a simple key=value config file, overlaying values onto provided defaults.
pub fn load_config_from_file(path string, defaults map[string]string) !map[string]string {
	mut config := defaults.clone()
	if !os.exists(path) {
		return config
	}
	lines := read_lines_from_file(path) or { return err }
	for line in lines {
		trimmed_line := line.trim_space()
		if trimmed_line == '' || trimmed_line.starts_with('#') {
			continue
		}
		eq_index := trimmed_line.index('=')
		if eq_index == none {
			continue
		}
		index := eq_index or { 0 }
		key := trimmed_line[..index].trim_space()
		if key.len == 0 {
			continue
		}
		mut value := trimmed_line[index + 1..].trim_space()
		if value.contains('#') {
			comment_index := value.index('#')
			if comment_index != none {
				value = value[..comment_index].trim_space()
			}
		}
		config[key] = value
	}
	return config
}

// Writes any JSON-serializable value to a file.
pub fn write_json_file[T](path string, data T) ! {
	ensure_dir_exists(path) or { return err }
	encoded := json.encode(data)
	os.write_file(path, encoded) or { return err }
}

// Reads a JSON file into a value of the requested type.
pub fn read_json_file[T](path string) !T {
	content := os.read_file(path) or { return err }
	return json.decode(T, content)
}

// Appends one JSON object as a new line in a newline-delimited JSON file.
pub fn append_json_line[T](path string, data T) ! {
	ensure_dir_exists(path) or { return err }
	encoded := json.encode(data)
	append_line_to_file(path, encoded) or { return err }
}
