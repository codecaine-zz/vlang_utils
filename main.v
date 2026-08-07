module main

import os
import fileutils

struct Person {
	name string
	age  int
}

fn main() {
	// Create the output folder used by the demo examples.
	demo_dir := '.fileutils_demo'
	os.mkdir_all(demo_dir) or { panic(err) }

	println('Starting fileutils demo...')
	println('Demo output directory: ${demo_dir}')

	// Demonstrate saving and loading a list of structs as JSON.
	people := [Person{
		name: 'Alice'
		age:  30
	}, Person{
		name: 'Bob'
		age:  25
	}]

	// Save and reload a slice of structs from disk.
	people_path := '${demo_dir}/people.json'
	fileutils.save_struct_array_to_file(people_path, people) or { panic(err) }
	loaded_people := fileutils.load_struct_array_from_file[Person](people_path) or { panic(err) }
	println('Loaded ${loaded_people.len} people from ${people_path}')
	for person in loaded_people {
		println(' - ${person.name} (${person.age})')
	}

	// Demonstrate saving and loading a single struct.
	person_path := '${demo_dir}/person.json'
	fileutils.save_struct_to_file(person_path, Person{
		name: 'Charlie'
		age:  40
	}) or { panic(err) }
	person := fileutils.load_struct_from_file[Person](person_path) or { panic(err) }
	println('Single struct loaded: ${person.name} (${person.age})')

	// Show how appending a line works for simple text logs.
	log_path := '${demo_dir}/notes.log'
	fileutils.append_line_to_file(log_path, 'First log entry') or { panic(err) }
	fileutils.append_line_to_file(log_path, 'Second log entry') or { panic(err) }
	log_lines := fileutils.read_lines_from_file(log_path) or { panic(err) }
	println('Log entries: ${log_lines.len}')
	for line in log_lines {
		println(' - ${line}')
	}

	// Demonstrate config loading with defaults and comments.
	config_path := '${demo_dir}/app.conf'
	os.write_file(config_path, 'host=localhost\nport=8080\n# comment\n') or { panic(err) }
	defaults := {
		'mode': 'prod'
		'port': '3000'
	}
	config := fileutils.load_config_from_file(config_path, defaults) or { panic(err) }
	println('Config values: host=${config['host']}, port=${config['port']}, mode=${config['mode']}')

	// Show how maps can be persisted to JSON.
	map_path := '${demo_dir}/settings.json'
	mut map_data := map[string]int{}
	map_data['alpha'] = 1
	map_data['beta'] = 2
	fileutils.save_map_to_file(map_path, map_data) or { panic(err) }
	loaded_map := fileutils.load_map_from_file[string, int](map_path) or { panic(err) }
	println('Loaded map values: alpha=${loaded_map['alpha']}, beta=${loaded_map['beta']}')

	// Demonstrate automatic directory creation for nested output paths.
	nested_path := '${demo_dir}/nested/deep/output.txt'
	fileutils.ensure_dir_exists(nested_path) or { panic(err) }
	println('Ensured directory exists for ${nested_path}')

	// Show arbitrary JSON values being written and read back.
	json_path := '${demo_dir}/profile.json'
	fileutils.write_json_file(json_path, Person{
		name: 'Dana'
		age:  35
	}) or { panic(err) }

	json_person := fileutils.read_json_file[Person](json_path) or { panic(err) }
	println('JSON profile: ${json_person.name} (${json_person.age})')

	// Demonstrate appending JSON objects as newline-delimited JSON.
	ndjson_path := '${demo_dir}/people.ndjson'
	fileutils.append_json_line(ndjson_path, Person{
		name: 'Eli'
		age:  28
	}) or { panic(err) }

	fileutils.append_json_line(ndjson_path, Person{
		name: 'Fay'
		age:  32
	}) or { panic(err) }

	ndjson_lines := fileutils.read_lines_from_file(ndjson_path) or { panic(err) }
	println('NDJSON rows: ${ndjson_lines.len}')

	for line in ndjson_lines {
		println(' - ${line}')
	}

	// Finish the demo with a summary message.
	println('Demo complete.')
}
