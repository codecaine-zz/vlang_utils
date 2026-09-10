# vlang_utils

A comprehensive suite of ergonomic, production-grade V utility modules designed for rapid application development (RAD). Never write common boilerplate from scratch again.

## Included Modules

| Module | Description |
| :--- | :--- |
| [`fileutils`](#1-fileutils) | JSON serialization, text operations, CSV parsing, copy/move, recursive listing, human-readable file sizes. |
| [`sqliteutils`](#2-sqliteutils) | Ergonomic SQLite persistence, KV store, JSON document store, SQL injection defense, parameterized CRUD, secure PRAGMAs, DDL migrations. |
| [`strutils`](#3-strutils) | Case conversions (snake, kebab, camel, pascal, title), slugify, masking, padding, Levenshtein distance, word wrap. |
| [`sliceutils`](#4-sliceutils) | Generic collection operations: unique, chunk, flatten, partition, intersection, difference, shuffle, sampling, stats. |
| [`envutils`](#5-envutils) | Type-safe environment variable retrieval (`get_str`, `get_int`, `get_bool`), setters (`set`, `set_int`, `set_bool`), `.env` file loader, variable expansion. |
| [`cryptoutils`](#6-cryptoutils) | SHA-256, SHA-512, MD5, HMAC-SHA256, Base64 / Base64URL encode/decode, UUID v4, secure tokens. |
| [`timeutils`](#7-timeutils) | Human relative time ("2 hours ago", "in 3 days"), ISO 8601 formatting/parsing, calendar boundaries, `Stopwatch`. |
| [`httputils`](#8-httputils) | Ergonomic HTTP client (`get_json[T]`, `post_json[T, R]`, `get_text`), query string builder/parser, retry with backoff. |
| [`cliutils`](#9-cliutils) | Terminal ANSI styling, FlagParser, interactive prompts, progress bar, sparkline, bar chart, gauge, tree, diff, tables. |
| [`sysutils`](#10-sysutils) | System telemetry (CPU usage/cores, RAM, swap, disk, uptime, load averages), safe exec (`exec_safe`, `quote_arg`), paths, clipboard. |
| [`netutils`](#11-netutils) | Network discovery (local/public IP, MAC, Wi-Fi SSID, DNS servers, gateway, listening ports), connectivity check & TCP ping. |
| [`validutils`](#12-validutils) | High-speed validation for email, URL, IPv4/IPv6, phone numbers, alphanumeric strings, numeric ranges, UUID, JSON. |
| [`structutils`](#13-structutils) | Generic RAD data structures: `SimpleStack[T]`, `SimpleQueue[T]`, circular `SimpleRingBuffer[T]`, and `SimpleMinHeap`. |
| [`statutils`](#14-statutils) | Statistical analysis, regression & modeling: mean, median, mode, sample/pop variance & std dev, SEM, quartiles, IQR, skewness, kurtosis, covariance, Pearson/Spearman correlation, OLS linear regression, normal PDF/CDF, Z-scores, outlier detection, moving averages, and summary profiles. |
| [`stateutils`](#15-stateutils) | Managed app state persistence (`AppStateStore[T]`, `KeyValueState`) in OS-recommended paths with atomic writes, auto-save, and rollback. |
| [`cacheutils`](#16-cacheutils) | In-memory caching: fixed-capacity `LRUCache[T]` with O(1) recency eviction and entry-level `TTLCache[T]` with auto-cleanup and `get_or_set`. |
| [`semverutils`](#17-semverutils) | Semantic Versioning 2.0.0 parsing, precedence comparison, range matching (`^`, `~`, `>=`, `<=`), and version bumping. |
| [`flowutils`](#18-flowutils) | Traffic control & resilience: Token Bucket `RateLimiter`, 3-state `CircuitBreaker`, exponential backoff `retry[T]`, and event `Debouncer`. |
| [`templateutils`](#19-templateutils) | Fast string templating with fallback defaults (`{{key | default}}`), dynamic resolvers, and styled ANSI markdown terminal rendering. |
| [`colorutils`](#20-colorutils) | HEX/RGB/HSL color conversions, color theory transforms, WCAG 2.1 accessibility & contrast auditing, and 24-bit Truecolor terminal formatting. |
| [`archiveutils`](#21-archiveutils) | Ergonomic Zip archive creation, extraction, recursive directory compression, and in-memory inspection via V's native `compress.szip`. |
| [`asyncutils`](#22-asyncutils) | Bounded concurrency primitives: order-preserving `parallel_map[T, R]`, `parallel_filter[T]`, `parallel_each[T]`, `WaitGroup`, and `WorkerPool`. |
| [`regexutils`](#23-regexutils) | High-level regular expression helpers: `is_match`, `find_first`, `find_all`, `replace`, `split`, and `find_matches`. |
| [`mockutils`](#24-mockutils) | Synthetic testing & prototyping data generation: `lorem_text`, `lorem_words`, `mock_user`, `mock_email`, `mock_phone`, `mock_ipv4`, `mock_url`. |
| [`logutils`](#25-logutils) | Leveled structured logging (`LogLevel`, `Logger`, file/stdout targets, ANSI color highlighting). |
| [`tomlutils`](#26-tomlutils) | TOML configuration file and string parsing with typed accessors (`get_string`, `get_int`, `get_bool`, `get_strings`). |
| [`htmlutils`](#27-htmlutils) | HTML parsing, DOM navigation (`get_element_by_id`, `get_elements_by_tag`), entity escaping, and tag stripping. |
| [`bitutils`](#28-bitutils) | Dynamic bitsets (`BitSet`), bitwise operations, popcount, binary string conversions, and bitmask flag manipulation. |
| [`compressutils`](#29-compressutils) | Fast compression & decompression for Gzip, Zlib, Deflate, and Zstandard strings and byte buffers. |
| [`tarutils`](#30-tarutils) | In-memory and on-disk TAR archive creation, unpacking, directory archiving, and tarball inspection. |

---

## Quick Start Examples

### 1. `fileutils`
```v
import fileutils

struct Person {
    name string
    age  int
}

// 1. Save and load arrays of structs to/from JSON files
people := [Person{ name: 'Alice', age: 30 }, Person{ name: 'Bob', age: 25 }]
fileutils.save_struct_array_to_file('data/people.json', people)!
loaded := fileutils.load_struct_array_from_file[Person]('data/people.json')!

// 2. Read and write CSV files
fileutils.write_csv('data/users.csv', [
    ['id', 'name', 'role'],
    ['1', 'Alice', 'admin'],
], `,`)!
rows := fileutils.read_csv('data/users.csv', `,`)!

// 3. File helpers
fileutils.copy_file('data/users.csv', 'backup/users.csv')!
size_str := fileutils.file_size_human('data/users.csv')! // e.g. "45 B"
```

### 2. `sqliteutils`
```v
import sqliteutils

mut db := sqliteutils.open_db('data/app.db')!
defer { sqliteutils.close_db(mut db) or {} }

// Key-Value Store
sqliteutils.create_kv_table(mut db, 'settings')!
sqliteutils.set_kv(mut db, 'settings', 'theme', 'dark')!
theme := sqliteutils.get_kv_or(mut db, 'settings', 'theme', 'light')

// Document Store (persist structs without manual SQL)
sqliteutils.create_json_store(mut db, 'users')!
sqliteutils.save_struct(mut db, 'users', 'user_1', Person{ name: 'Alice', age: 30 })!
user := sqliteutils.load_struct[Person](mut db, 'users', 'user_1')!

// Injection-Free Parameterized CRUD
sqliteutils.exec_sql(mut db, 'CREATE TABLE IF NOT EXISTS accounts (id INTEGER PRIMARY KEY, name TEXT);')!
new_id := sqliteutils.insert_row(mut db, 'accounts', { 'name': 'Alice' })!
rows := sqliteutils.select_rows(mut db, 'accounts', ['name'], 'name = ?', ['Alice'])!
```

### 3. `strutils`
```v
import strutils

slug := strutils.slugify('Hello World 2026: The Future!') // "hello-world-2026-the-future"
snake := strutils.to_snake_case('camelCaseText')          // "camel_case_text"
kebab := strutils.to_kebab_case('camelCaseText')          // "camel-case-text"
pascal := strutils.to_pascal_case('hello_world')          // "HelloWorld"

masked_email := strutils.mask_email('john.doe@example.com') // "j******e@example.com"
token := strutils.random_alphanumeric(32)                   // 32-char secure random string
dist := strutils.levenshtein_distance('kitten', 'sitting')  // 3
```

### 4. `sliceutils`
```v
import sliceutils

nums := [1, 2, 2, 3, 4, 4, 5]
unique_nums := sliceutils.unique(nums)                 // [1, 2, 3, 4, 5]
chunks := sliceutils.chunk(nums, 3)                     // [[1, 2, 2], [3, 4, 4], [5]]
evens, odds := sliceutils.partition(nums, fn (n int) bool { return n % 2 == 0 })
sum := sliceutils.sum_int(nums)                         // 21
avg := sliceutils.average_int(nums)                     // 3.0
```

### 5. `envutils`
```v
import envutils

// Type-safe getters with defaults, optional handling & lists
port := envutils.get_int('PORT', 8080)
origins := envutils.get_list('ALLOWED_ORIGINS', ',', ['*'])
if token := envutils.get_opt('GITHUB_TOKEN') {
    println('Found token: ${token}')
}

// Set, set_default & unset programmatically
envutils.set_default('APP_ENV', 'production')
envutils.set_int('PORT', 3000)
envutils.unset('TEMP_FLAG')

// Dotenv file persistence & string expansion
envutils.save_dotenv('.env', { 'APP_ENV': 'production', 'PORT': '3000' })!
path := envutils.expand_env('/var/${APP_ENV}/logs')
```

### 6. `cryptoutils`
```v
import cryptoutils

hash := cryptoutils.sha256('secret')
hmac := cryptoutils.hmac_sha256('key', 'data')
uuid := cryptoutils.uuid_v4()                     // "b17c05dd-362c-46c2-b588-6df3f3300697"
b64 := cryptoutils.base64_encode('Hello V')
orig := cryptoutils.base64_decode(b64)!
```

### 7. `timeutils`
```v
import timeutils
import time

// Human relative time
println(timeutils.time_ago(time.now().add(-3600 * time.second))) // "1 hour ago"
println(timeutils.time_until(time.now().add(86400 * time.second))) // "tomorrow"

// Benchmark Stopwatch
mut sw := timeutils.new_stopwatch()
time.sleep(20 * time.millisecond)
sw.stop()
println('Completed in ${sw.elapsed_ms():.2f} ms')
```

### 8. `httputils`
```v
import httputils

// Build and parse query strings
qs := httputils.build_query_string({ 'search': 'vlang', 'page': '1' })
params := httputils.parse_query_string('?search=vlang&page=1')

// REST Helpers
struct Post {
    id    int
    title string
}
post := httputils.get_json[Post]('https://jsonplaceholder.typicode.com/posts/1', {})!
```

### 9. `cliutils`
```v
import cliutils

// Terminal ANSI Styling & Visualization
println(cliutils.bold(cliutils.green('Success: Service is running')))
println('Sparkline: ' + cliutils.sparkline([1.0, 3.0, 5.0, 8.0, 4.0, 2.0, 9.0]))
println(cliutils.gauge('RAM', 7.2, 10.0, 'GB'))
println(cliutils.bar_chart('Stats', { 'CPU': 45.0, 'MEM': 80.0 }, 20))

// Tree rendering
tree := cliutils.TreeNode{
    label: 'Root'
    children: [
        cliutils.TreeNode{ label: 'Child A' },
        cliutils.TreeNode{ label: 'Child B' },
    ]
}
println(cliutils.render_tree(tree))
```

### 10. `sysutils`
```v
import sysutils

// Telemetry
cores := sysutils.get_cpu_count()
total_ram, used_ram, ram_pct := sysutils.get_memory_stats()
uptime := sysutils.get_uptime()

// Safe execution preventing command injection
safe_out, code := sysutils.exec_safe('echo', ['hello', 'world'])

// Standard app directories
config_dir := sysutils.get_app_config_dir('my_app')
```

### 11. `netutils`
```v
import netutils

if netutils.is_online() {
    ip := netutils.get_local_ip()
    println('Connected via IP: ${ip}')
    dns := netutils.get_dns_servers()
    println('DNS: ${dns}')
}
```

### 12. `validutils`
```v
import validutils

is_valid_email := validutils.validate_email('dev@example.com')
is_valid_url := validutils.validate_url('https://vlang.io')
is_valid_ip := validutils.validate_ip('192.168.1.1')
is_valid_json := validutils.validate_json('{"active": true}')
```

### 13. `structutils`
```v
import structutils

// Generic Stack (LIFO)
mut stack := structutils.new_stack[string]()
stack.push('first')
item := stack.pop() // 'first'

// Circular Ring Buffer
mut ring := structutils.new_ring_buffer[int](3)
ring.push(1)
ring.push(2)
ring.push(3)
ring.push(4) // drops 1, holds [2, 3, 4]
items := ring.to_array()

// MinHeap
mut heap := structutils.new_min_heap()
heap.push(20.0)
heap.push(5.0)
min_item := heap.pop() // 5.0
```

### 14. `statutils`
```v
import statutils

data := [10.0, 20.0, 30.0, 40.0, 50.0]

// 17-field descriptive statistical summary
summary := statutils.stats_summary(data)
// Mean: 30.0, Median: 30.0, Sample StdDev: 15.81, IQR: 20.0, Skew: 0.0

// OLS Linear Regression
x := [1.0, 2.0, 3.0, 4.0, 5.0]
y := [2.0, 4.1, 6.0, 7.9, 10.1]
reg := statutils.stats_linear_regression(x, y)!
// Slope: 2.01, Intercept: 0.01, R²: 0.9997

// Moving Average & Outliers
ma := statutils.stats_moving_average(data, 3)! // [20.0, 30.0, 40.0]
outliers := statutils.stats_outliers_iqr([10.0, 11.0, 12.0, 100.0], 1.5) // [100.0]
```

### 15. `stateutils`
```v
import stateutils

struct AppConfig {
pub mut:
    theme        string
    window_width int
    recent_files []string
}

// Automatically resolves OS recommended save path:
// - macOS: ~/Library/Application Support/my_app/state.json
// - Windows: %APPDATA%/my_app/state.json
// - Linux: ~/.local/share/my_app/state.json
mut store := stateutils.new_app_state[AppConfig]('my_app', AppConfig{
    theme: 'dark'
    window_width: 1280
})

// Modify and save with atomic write (zero corruption risk)
store.update(fn (mut cfg AppConfig) {
    cfg.window_width = 1920
})!
store.save()!

// Dynamic Key-Value state
mut kv := stateutils.new_kv_state('my_app')
kv.auto_save = true
kv.set_str('user', 'alex')!
kv.set_int('launches', 5)!
```

### 16. `cacheutils`
```v
import cacheutils
import time

// Fixed-capacity LRU cache
mut lru := cacheutils.new_lru[string](2)!
lru.set('session:1', 'Alice')
lru.set('session:2', 'Bob')
lru.set('session:3', 'Charlie') // Automatically evicts session:1

// Time-To-Live cache
mut ttl := cacheutils.new_ttl[string](60 * time.second)
val := cacheutils.get_or_set_ttl[string](mut ttl, 'rates', fn () !string {
    return '{"USD": 1.0}'
})!
```

### 17. `semverutils`
```v
import semverutils

v1 := semverutils.parse('v1.2.3-beta.1+build.42')!
v_bumped := semverutils.bump_minor(v1) // 1.3.0

// Range requirement checks
is_match := semverutils.satisfies(v_bumped, '^1.2.0')! // true
```

### 18. `flowutils`
```v
import flowutils
import time

// Token bucket rate limiter: 10 capacity, 2 tokens/sec
mut limiter := flowutils.new_rate_limiter(10, 2.0)!
if limiter.allow_n(2) {
    // Process request
}

// 3-state circuit breaker
mut cb := flowutils.new_circuit_breaker(3, 5 * time.second)!
if cb.can_execute() {
    // Attempt remote dependency
}

// Exponential backoff retry
data := flowutils.retry[string](3, 100 * time.millisecond, 2.0, 1 * time.second, fn () !string {
    return 'payload'
})!
```

### 19. `templateutils`
```v
import templateutils

tpl := 'Welcome {{name}}! Platform: {{os | Linux}}'
rendered := templateutils.render_template(tpl, {
    'name': 'Developer'
})
println(rendered) // "Welcome Developer! Platform: Linux"

// Terminal ANSI markdown
println(templateutils.render_markdown_ansi('# Header\n**bold** and `code`'))
```

### 20. `colorutils`
```v
import colorutils

// HEX / RGB / HSL conversions & adjustments
hex_color := colorutils.hex_to_rgb('#007acc')!
lighter   := colorutils.lighten(hex_color, 0.2)

// WCAG 2.1 accessibility auditing
white := colorutils.RGB{255, 255, 255}
ratio := colorutils.contrast_ratio(hex_color, white)
is_aa := colorutils.is_accessible(hex_color, white, 'AA')

// 24-bit Truecolor terminal output
println(colorutils.fg_rgb('Truecolor Text', hex_color))
```

### 21. `archiveutils`
```v
import archiveutils

// Create zip archives
archiveutils.zip_file('data/report.pdf', 'backup/report.zip')!
archiveutils.zip_dir('assets/images', 'dist/images.zip')!

// Inspect and read without disk extraction
entries := archiveutils.list_entries('dist/images.zip')!
readme_content := archiveutils.read_entry_string('dist/images.zip', 'README.md')!

// Extract archive
archiveutils.unzip_to_dir('dist/images.zip', 'extracted/')!
```

### 22. `asyncutils`
```v
import asyncutils

// Bounded parallel mapping (preserves index order)
squares := asyncutils.parallel_map[int, int]([1, 2, 3, 4], 2, fn (n int) int {
    return n * n
})

// WaitGroup synchronization
mut wg := asyncutils.new_waitgroup()
wg.add(1)
spawn fn (mut wg asyncutils.WaitGroup) {
    defer { wg.done() }
    // background work
}(mut wg)
wg.wait()

// Bounded WorkerPool
mut pool := asyncutils.new_worker_pool(4, 16)!
defer { pool.stop() }
pool.submit(fn () { /* job */ })!
pool.wait_all()
```

### 23. `regexutils`
```v
import regexutils

// High-level pattern matching
if regexutils.is_match(r'^\d{4}-\d{2}-\d{2}$', '2026-09-10') {
    println('Valid date format')
}

// Find first & all matches
first_num := regexutils.find_first(r'\d+', 'item 42 price 100') // "42"
all_nums  := regexutils.find_all(r'\d+', 'item 42 price 100')   // ['42', '100']

// Simple replacement
masked := regexutils.replace(r'\d', 'Pass: 1234', '*') // "Pass: ****"
```

### 24. `mockutils`
```v
import mockutils

// Synthetic user profiles
user := mockutils.mock_user()
println('${user.name} <${user.email}> (${user.role})')

// Quick test datasets
users := mockutils.mock_users(10)

// Fast lorem placeholder text
paragraph := mockutils.lorem_text(1, 3, 8)
words := mockutils.lorem_words(6)
```

### 25. `logutils`
```v
import logutils

mut logger := logutils.new_logger(.info, .stdout)
logger.info('Application started successfully')
logger.warn('High memory usage detected')
```

### 26. `tomlutils`
```v
import tomlutils

doc := tomlutils.parse('
[server]
port = 8080
debug = true
tags = ["api", "vlang"]
')!

port := doc.get_int('server.port', 3000)
tags := doc.get_strings('server.tags')
```

### 27. `htmlutils`
```v
import htmlutils

doc := htmlutils.parse('<div id="main" class="container"><a href="/docs">Docs</a></div>')!
if link := doc.get_element_by_id('main') {
    println(link.text)
}
escaped := htmlutils.escape_html('<script>alert("xss")</script>')
```

### 28. `bitutils`
```v
import bitutils

mut bs := bitutils.new_bitset(64)
bs.set(0)
bs.set(5)
is_set := bs.get(5) // true
count := bs.count_set() // 2

// Flag helpers
mut flags := u32(0)
flags = bitutils.set_flag(flags, 1 << 2)
has_flag := bitutils.has_flag(flags, 1 << 2) // true
```

### 29. `compressutils`
```v
import compressutils

data := 'V is simple, fast, safe, and compiled.'
compressed := compressutils.gzip_compress_string(data)!
restored := compressutils.gzip_decompress_string(compressed)!

ratio := compressutils.compression_ratio(data.len, compressed.len)
```

### 30. `tarutils`
```v
import tarutils

// Pack in-memory entries into tarball
tar_bytes := tarutils.pack_bytes([
    tarutils.TarEntry{ name: 'hello.txt', data: 'Hello Tar!'.bytes() }
])!

// Inspect and unpack
entries := tarutils.unpack_bytes(tar_bytes)!
println(entries[0].name) // "hello.txt"
```

---

## Running Demos

You can run individual standalone demos for any utility module or execute all 30 demos sequentially:

```bash
# Run all 30 module demos sequentially with execution timing
v run demos/run_all_demos.v

# Or run any specific module demo directly
v run demos/demo_fileutils.v
v run demos/demo_sqliteutils.v
v run demos/demo_flowutils.v
v run demos/demo_cryptoutils.v
# ... (see demos/ folder for all 30 demo scripts)

# Run the interactive console dashboard
v run main.v
```

## Running Tests

To run all automated test suites across every module:

```bash
v test .
```

## API Documentation

For the complete API reference with comprehensive, runnable examples for all 686 public functions and structs, see [API.md](API.md).


