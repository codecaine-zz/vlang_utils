# vlang_utils

A comprehensive suite of ergonomic, production-grade V utility modules designed for rapid application development (RAD). Never write common boilerplate from scratch again.

> **v2.0** — every module hardened (security fixes, real bug fixes, standards compliance) and extended with hundreds of new, tested utilities, plus three new modules (`jsonutils`, `markdownutils`, `webutils`). Fully backward compatible. See [CHANGELOG.md](CHANGELOG.md).

**Engineering principles:** standards first (RFCs and specs are cited in code and verified with their published test vectors), secure by default (CSPRNG, constant-time comparisons, escaping, `alg` pinning), predictable complexity (documented and tested), and zero third-party dependencies.

## Included Modules

| Module | Description |
| :--- | :--- |
| [`archiveutils`](#1-archiveutils) | Ergonomic Zip archive creation, extraction, recursive directory compression, and in-memory inspection via V's native `compress.szip`. |
| [`asyncutils`](#2-asyncutils) | Order-preserving `parallel_map`/`filter`/`each`, fallible `parallel_try_map`, `parallel_reduce`, `with_timeout`, `Semaphore`, `Once`, `WaitGroup`, `WorkerPool`. |
| [`bitutils`](#3-bitutils) | Dynamic bitsets (`BitSet`), bitwise operations, popcount, binary string conversions, and bitmask flag manipulation. |
| [`cacheutils`](#4-cacheutils) | True O(1) `LRUCache[T]` (index-linked slab) with `peek` and hit-ratio stats, and `TTLCache[T]` with auto-cleanup and `get_or_set`. |
| [`cliutils`](#5-cliutils) | Terminal ANSI styling, FlagParser, interactive prompts, progress bar, sparkline, bar chart, gauge, tree, diff, tables. |
| [`colorutils`](#6-colorutils) | HEX/RGB/HSL/HSV/CMYK/Lab/OKLab/OKLCH, perceptual `mix_oklab` & gradients, ΔE, palettes, WCAG contrast with `ensure_contrast`, CSS color parsing, truecolor/ansi256. |
| [`compressutils`](#7-compressutils) | Fast compression & decompression for Gzip, Zlib, Deflate, and Zstandard strings and byte buffers. |
| [`cronutils`](#8-cronutils) | POSIX cron (lists, `a-b/n` steps, `MON-FRI`/`JAN` names, `@daily` macros, DOM/DOW OR rule), fast `next_after`/`next_n`, `is_valid_cron`, English summaries. |
| [`cryptoutils`](#9-cryptoutils) | CSPRNG tokens/UUID v4/v7/NanoID, authenticated encryption (`seal`/`open`), RFC 4226/6238 HOTP/TOTP, Argon2id, PBKDF2, SHA-1/2/3, BLAKE3, HMAC, Base32, constant-time compare. |
| [`diffutils`](#10-diffutils) | Myers O(ND) diff, word/char diffs, git-compatible unified hunks, verified `apply_patch`, similarity ratio, ANSI rendering. |
| [`envutils`](#11-envutils) | Type-safe getters, `.env` loader with quotes/escapes/multiline/`export`, `${VAR:-default}` expansion, `dotenv-expand`, `get_duration`, `get_enum`, `require_all`, `with_env`. |
| [`eventutils`](#12-eventutils) | Pub-sub `EventEmitter` with handle-based `subscribe`/`unsubscribe`, wildcard `on_any`, once-listeners, and generic `TypedEmitter[T]`. |
| [`fileutils`](#13-fileutils) | JSON/NDJSON, RFC 4180 CSV, atomic writes, streaming hash/`tail`/`head`, `safe_join` (path-traversal guard), glob `find_files`, MIME sniffing, byte-size parse/format. |
| [`flowutils`](#14-flowutils) | Monotonic-clock token bucket and sliding-window limiters (`retry_after`, `remaining`), `CircuitBreaker`, exponential backoff `retry[T]`, `Debouncer`. |
| [`graphutils`](#15-graphutils) | Directed `Graph[T]` (topo sort, BFS/DFS, shortest path, SCC, cycle finding) and `WeightedGraph[T]` (Dijkstra, A*, Kruskal MST, components), `UnionFind`. |
| [`htmlutils`](#16-htmlutils) | HTML parsing & DOM queries, single-pass entity decoding (named/numeric), allowlist `sanitize_html` (XSS-safe), `html_to_text`. |
| [`httputils`](#17-httputils) | Reusable `Client` (base URL, headers, timeouts), typed JSON helpers, retry with jittered backoff + `Retry-After`/429, Link/Content-Type parsing, form encoding. |
| [`jsonutils`](#18-jsonutils) | **New.** RFC 6901 JSON Pointer get/set, RFC 7386 Merge Patch, canonical (sorted-key) encoding, deep equality, structural diff, flatten, pretty/minify. |
| [`jwtutils`](#19-jwtutils) | HS256/384/512 JWT signing & verification with `alg` pinning, issuer/audience/leeway/max-age policies, `refresh_jwt`, unverified decoding for routing. |
| [`logutils`](#20-logutils) | Leveled logging with color, logfmt & JSON structured records, automatic secret redaction, `parse_level`, size-based `rotate_file`. |
| [`markdownutils`](#21-markdownutils) | **New.** Safe Markdown → HTML (GFM tables, task lists, fenced code, nested lists), heading anchors, TOC generation, plain-text previews. |
| [`mathutils`](#22-mathutils) | Geometry (`Vec2`, polygons, convex hull, haversine), overflow-checked ints, Miller-Rabin primes, modular arithmetic, factorial/binomial, Kahan sum, approx equality. |
| [`mockutils`](#23-mockutils) | Synthetic testing & prototyping data generation: `lorem_text`, `lorem_words`, `mock_user`, `mock_email`, `mock_phone`, `mock_ipv4`, `mock_url`. |
| [`netutils`](#24-netutils) | Network discovery (local/public IP, MAC, Wi-Fi SSID, DNS servers, gateway, listening ports), connectivity check & TCP ping. |
| [`regexutils`](#25-regexutils) | High-level regular expression helpers: `is_match`, `find_first`, `find_all`, `replace`, `split`, and `find_matches`. |
| [`semverutils`](#26-semverutils) | Strict SemVer 2.0.0 parsing, precedence, full npm range syntax (` |
| [`sliceutils`](#27-sliceutils) | O(n) hashed set ops, `fold`/`scan`/`flat_map`/`filter_map`, stable sort, binary search bounds, `group/count/index_by`, windows, transpose, combinations & permutations. |
| [`sqliteutils`](#28-sqliteutils) | Ergonomic SQLite persistence, KV store, JSON document store, SQL injection defense, parameterized CRUD, secure PRAGMAs, DDL migrations. |
| [`stateutils`](#29-stateutils) | Managed app state persistence (`AppStateStore[T]`, `KeyValueState`) in OS-recommended paths with JSON and SQLite database backends, atomic writes, auto-save, and rollback. |
| [`statutils`](#30-statutils) | Descriptive stats, regression, correlation, outliers, plus streaming `RunningStats` (Welford), histograms, normal quantile, Student-t CDF, Welch t-test, confidence intervals. |
| [`structutils`](#31-structutils) | Stack, Queue, RingBuffer, MinHeap, Set, BST, linked lists, generic `PriorityQueue[T]`, `Deque[T]`, `Trie` autocomplete, optimally-sized Bloom filter, HyperLogLog. |
| [`strutils`](#32-strutils) | Case conversions, Unicode-aware slugify/transliteration, masking, Levenshtein, Jaro-Winkler, fuzzy match & "did you mean", natural sort, Soundex, pluralize/singularize, dedent, display width. |
| [`sysutils`](#33-sysutils) | System telemetry (CPU usage/cores, RAM, swap, disk, uptime, load averages), safe exec (`exec_safe`, `quote_arg`), paths, clipboard. |
| [`tarutils`](#34-tarutils) | In-memory and on-disk TAR archive creation, unpacking, directory archiving, and tarball inspection. |
| [`templateutils`](#35-templateutils) | `{{key |
| [`timeutils`](#36-timeutils) | Relative time, ISO 8601, flexible `parse_any`, `parse_duration`, calendar math (`add_months`, ISO week, quarters, business days, age), boundaries, `Stopwatch`. |
| [`tomlutils`](#37-tomlutils) | TOML configuration file and string parsing with typed accessors (`get_string`, `get_int`, `get_bool`, `get_strings`). |
| [`urlutils`](#38-urlutils) | URL parsing (IPv6, encoded credentials, port validation), RFC 3986 `resolve_reference` & dot-segment removal, `normalize_url`, origins, multi-value queries. |
| [`validutils`](#39-validutils) | Email, URL, hostname, IPv4/IPv6/CIDR, MAC, port, E.164, Luhn/credit cards, IBAN, ISBN, ULID, hex colors, password strength, and a fluent `Validator`. |
| [`webutils`](#40-webutils) | **New.** Express-style web framework with a secure EJS-style template engine and batteries included (sessions, CSRF, CORS, rate limiting, security headers, static files, multipart, gzip, signed cookies, in-process testing). Zero third-party deps. |

---

## Quick Start Examples

### 1. `archiveutils`
```v
import archiveutils

// Create zip archives
archiveutils.zip_file('data/report.pdf', 'backup/report.zip')!
archiveutils.zip_dir('assets/images', 'dist/images.zip')!

// Inspect and read without disk extraction
entries := archiveutils.list_entries('dist/images.zip')!
readme_content := archiveutils.read_entry_string('dist/images.zip', 'README.md')!
println('Entries: ${entries.len}, Readme: ${readme_content}')

// Extract archive
archiveutils.unzip_to_dir('dist/images.zip', 'extracted/')!
```

### 2. `asyncutils`
```v
import asyncutils

// Bounded parallel mapping (preserves index order)
squares := asyncutils.parallel_map[int, int]([1, 2, 3, 4], 2, fn (n int) int {
    return n * n
})
println('Squares: ${squares}')

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

### 3. `bitutils`
```v
import bitutils

mut bs := bitutils.new_bitset(64)
bs.set(0)
bs.set(5)
is_set := bs.get(5) // true
count := bs.count_set() // 2
println('is_set: ${is_set}, count: ${count}')

// Flag helpers
mut flags := u32(0)
flags = bitutils.set_flag(flags, 1 << 2)
has_flag := bitutils.has_flag(flags, 1 << 2) // true
println('has_flag: ${has_flag}')
```

### 4. `cacheutils`
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
println('Rate: ${val}')
```

### 5. `cliutils`
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

### 6. `colorutils`
```v
import colorutils

// HEX / RGB / HSL conversions & adjustments
hex_color := colorutils.hex_to_rgb('#007acc')!
lighter   := colorutils.lighten(hex_color, 0.2)
println('Lighter: ${lighter}')

// WCAG 2.1 accessibility auditing
white := colorutils.RGB{255, 255, 255}
ratio := colorutils.contrast_ratio(hex_color, white)
is_aa := colorutils.is_accessible(hex_color, white, 'AA')
println('Ratio: ${ratio}, AA: ${is_aa}')

// 24-bit Truecolor terminal output
println(colorutils.fg_rgb('Truecolor Text', hex_color))
```

### 7. `compressutils`
```v
import compressutils

data := 'V is simple, fast, safe, and compiled.'
compressed := compressutils.gzip_compress_string(data)!
restored := compressutils.gzip_decompress_string(compressed)!
println('Restored: ${restored}')

ratio := compressutils.compression_ratio(data.len, compressed.len)
println('Compression ratio: ${ratio:.1f}%')
```

### 8. `cronutils`
```v
import cronutils
import time

// Parse standard 5-field cron
sched := cronutils.parse_cron('*/15 9-17 * * 1-5')!
next := sched.next_after(time.now())!
println('Next run: ${next}')

// Human description
human := cronutils.cron_to_human('0 0 * * *')
println(human) // "Every day at midnight"
```

### 9. `cryptoutils`
```v
import cryptoutils

hash := cryptoutils.sha256('secret')
hmac := cryptoutils.hmac_sha256('key', 'data')
uuid := cryptoutils.uuid_v4()                     // "b17c05dd-362c-46c2-b588-6df3f3300697"
println('hash: ${hash}, hmac: ${hmac}, uuid: ${uuid}')

b64 := cryptoutils.base64_encode('Hello V')
orig := cryptoutils.base64_decode(b64)!
println(orig)
```

### 10. `diffutils`
```v
import diffutils

diff := diffutils.unified_diff('hello\nworld', 'hello\nvlang', 'greeting.txt')
print(diff)
```

### 11. `envutils`
```v
import envutils

// Type-safe getters with defaults, optional handling & lists
port := envutils.get_int('PORT', 8080)
origins := envutils.get_list('ALLOWED_ORIGINS', ',', ['*'])
println('Port: ${port}, Origins: ${origins}')
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
println('Path: ${path}')
```

### 12. `eventutils`
```v
import eventutils

mut em := eventutils.new_emitter()
em.on('user_login', fn (user string) {
    println('Welcome ${user}!')
})
em.emit('user_login', 'Alice')
```

### 13. `fileutils`
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
println('Loaded ${loaded.len} people')

// 2. Read and write CSV files
fileutils.write_csv('data/users.csv', [
    ['id', 'name', 'role'],
    ['1', 'Alice', 'admin'],
], `,`)!
rows := fileutils.read_csv('data/users.csv', `,`)!
println('CSV rows: ${rows.len}')

// 3. File helpers
fileutils.copy_file('data/users.csv', 'backup/users.csv')!
size_str := fileutils.file_size_human('data/users.csv')!
println('Size: ${size_str}') // e.g. "45 B"
```

### 14. `flowutils`
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
println('Data: ${data}')
```

### 15. `graphutils`
```v
import graphutils

mut dag := graphutils.new_graph[string]()
dag.add_edge('build', 'test')
dag.add_edge('test', 'deploy')

order := dag.topological_sort()!
println(order) // ["build", "test", "deploy"]

mut roads := graphutils.new_weighted_graph[string](false)
roads.add_edge('A', 'B', 4)!
roads.add_edge('A', 'C', 1)!
roads.add_edge('C', 'B', 2)!
path := roads.dijkstra('A', 'B') or { panic('unreachable') }
println('${path.nodes} cost=${path.cost}') // ['A', 'C', 'B'] cost=3.0
```

### 16. `htmlutils`
```v
import htmlutils

doc := htmlutils.parse('<div id="main" class="container"><a href="/docs">Docs</a></div>')!
if link := doc.get_element_by_id('main') {
    println(link.text)
}
escaped := htmlutils.escape_html('<script>alert("xss")</script>')
println(escaped)
```

### 17. `httputils`
```v
import httputils

// Build and parse query strings
qs := httputils.build_query_string({ 'search': 'vlang', 'page': '1' })
params := httputils.parse_query_string('?search=vlang&page=1')
println('Query: ${qs}, params: ${params}')

// REST Helpers
struct Post {
    id    int
    title string
}
post := httputils.get_json[Post]('https://jsonplaceholder.typicode.com/posts/1', {})!
println(post.title)
```

### 18. `jsonutils`
```v
import jsonutils
import json2

doc := jsonutils.parse('{"users":[{"name":"Ann"}]}')!
name := jsonutils.pointer_get(doc, '/users/0/name')!            // "Ann"
patched := jsonutils.merge_patch_str('{"a":1,"b":2}', '{"b":null,"c":3}')! // {"a":1,"c":3}
changes := jsonutils.diff(doc, jsonutils.pointer_set(doc, '/users/-', json2.Any('Bob'))!)
println(changes[0].op) // add
```

### 19. `jwtutils`
```v
import jwtutils

// Sign and verify HS256 JWT
token := jwtutils.sign_simple_token('user_123', 'secret_key', 3600)!
claims := jwtutils.verify_jwt(token, 'secret_key')!
println('Subject: ${claims.sub}')
```

### 20. `logutils`
```v
import logutils

mut logger := logutils.new_logger(.info, .stdout)
logger.info('Application started successfully')
logger.warn('High memory usage detected')
```

### 21. `markdownutils`
```v
import markdownutils

html := markdownutils.to_html('# Hello\n\n- [x] **safe** by default\n\n[x](javascript:alert(1))')
// <h1 id="hello">Hello</h1> ... javascript: links are neutralized to "#"
println(markdownutils.toc('# A\n## B', 3))
```

### 22. `mathutils`
```v
import mathutils

// Interpolation & mapping
val := mathutils.remap(50.0, 0.0, 100.0, 0.0, 1.0) // 0.5
clamped := mathutils.clamp(120.0, 0.0, 100.0)       // 100.0
snapped := mathutils.round_to_step(4.78, 0.25)      // 4.75

// Geometry & Number Theory
p1 := mathutils.Point2D[f64]{ x: 0.0, y: 0.0 }
p2 := mathutils.Point2D[f64]{ x: 3.0, y: 4.0 }
dist := mathutils.distance(p1, p2)                  // 5.0
gcd_val := mathutils.gcd(84, 18)                    // 6
```

### 23. `mockutils`
```v
import mockutils

// Synthetic user profiles
user := mockutils.mock_user()
println('${user.name} <${user.email}> (${user.role})')

// Quick test datasets
users := mockutils.mock_users(10)
println('Users: ${users.len}')

// Fast lorem placeholder text
paragraph := mockutils.lorem_text(1, 3, 8)
words := mockutils.lorem_words(6)
println('${paragraph}\nWords: ${words}')
```

### 24. `netutils`
```v
import netutils

if netutils.is_online() {
    ip := netutils.get_local_ip()
    println('Connected via IP: ${ip}')
    dns := netutils.get_dns_servers()
    println('DNS: ${dns}')
}
```

### 25. `regexutils`
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
println('${first_num}, ${all_nums}, ${masked}')
```

### 26. `semverutils`
```v
import semverutils

v1 := semverutils.parse('v1.2.3-beta.1+build.42')!
v_bumped := semverutils.bump_minor(v1) // 1.3.0

// Range requirement checks
is_match := semverutils.satisfies(v_bumped, '^1.2.0')!
println('Matches: ${is_match}') // true
```

### 27. `sliceutils`
```v
import sliceutils

nums := [1, 2, 2, 3, 4, 4, 5]
unique_nums := sliceutils.unique(nums)                 // [1, 2, 3, 4, 5]
chunks := sliceutils.chunk(nums, 3)                     // [[1, 2, 2], [3, 4, 4], [5]]
evens, odds := sliceutils.partition(nums, fn (n int) bool { return n % 2 == 0 })
sum := sliceutils.sum_int(nums)                         // 21
avg := sliceutils.average_int(nums)                     // 3.0
println('unique: ${unique_nums}, chunks: ${chunks}, evens: ${evens}, odds: ${odds}, sum: ${sum}, avg: ${avg}')
```

### 28. `sqliteutils`
```v
import sqliteutils

mut db := sqliteutils.open_db('data/app.db')!
defer { sqliteutils.close_db(mut db) or {} }

// Key-Value Store
sqliteutils.create_kv_table(mut db, 'settings')!
sqliteutils.set_kv(mut db, 'settings', 'theme', 'dark')!
theme := sqliteutils.get_kv_or(mut db, 'settings', 'theme', 'light')
println('Theme: ${theme}')

// Document Store (persist structs without manual SQL)
sqliteutils.create_json_store(mut db, 'users')!
sqliteutils.save_struct(mut db, 'users', 'user_1', Person{ name: 'Alice', age: 30 })!
user := sqliteutils.load_struct[Person](mut db, 'users', 'user_1')!
println('User: ${user.name}')

// Injection-Free Parameterized CRUD
sqliteutils.exec_sql(mut db, 'CREATE TABLE IF NOT EXISTS accounts (id INTEGER PRIMARY KEY, name TEXT);')!
new_id := sqliteutils.insert_row(mut db, 'accounts', { 'name': 'Alice' })!
rows := sqliteutils.select_rows(mut db, 'accounts', ['name'], 'name = ?', ['Alice'])!
println('New ID: ${new_id}, rows: ${rows.len}')
```

### 29. `stateutils`
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

// SQLite Database Option: store state in a SQLite database file
mut sqlite_store := stateutils.new_sqlite_app_state[AppConfig]('my_app', AppConfig{
    theme: 'nord'
    window_width: 1440
})
sqlite_store.save()!

// Dynamic Key-Value state (JSON or SQLite)
mut kv := stateutils.new_kv_state('my_app')
kv.auto_save = true
kv.set_str('user', 'alex')!
kv.set_int('launches', 5)!

// SQLite Key-Value state
mut sqlite_kv := stateutils.new_sqlite_kv_state('my_app')
sqlite_kv.auto_save = true
sqlite_kv.set_str('db_mode', 'wal')!
```

### 30. `statutils`
```v
import statutils

data := [10.0, 20.0, 30.0, 40.0, 50.0]

// 17-field descriptive statistical summary
summary := statutils.stats_summary(data)
println('Mean: ${summary.mean}, Median: ${summary.median}')
// Mean: 30.0, Median: 30.0, Sample StdDev: 15.81, IQR: 20.0, Skew: 0.0

// OLS Linear Regression
x := [1.0, 2.0, 3.0, 4.0, 5.0]
y := [2.0, 4.1, 6.0, 7.9, 10.1]
reg := statutils.stats_linear_regression(x, y)!
println('Slope: ${reg.slope}, R²: ${reg.r_squared}')
// Slope: 2.01, Intercept: 0.01, R²: 0.9997

// Moving Average & Outliers
ma := statutils.stats_moving_average(data, 3)!
outliers := statutils.stats_outliers_iqr([10.0, 11.0, 12.0, 100.0], 1.5)
println('MA: ${ma}, Outliers: ${outliers}')
```

### 31. `structutils`
```v
import structutils

// Generic Stack (LIFO)
mut stack := structutils.new_stack[string]()
stack.push('first')
item := stack.pop()
println('Popped: ${item}') // 'first'

// Circular Ring Buffer
mut ring := structutils.new_ring_buffer[int](3)
ring.push(1)
ring.push(2)
ring.push(3)
ring.push(4) // drops 1, holds [2, 3, 4]
items := ring.to_array()
println('Ring items: ${items}')

// MinHeap
mut heap := structutils.new_min_heap()
heap.push(20.0)
heap.push(5.0)
min_item := heap.pop()
println('Min item: ${min_item}') // 5.0
```

### 32. `strutils`
```v
import strutils

slug := strutils.slugify('Hello World 2026: The Future!') // "hello-world-2026-the-future"
snake := strutils.to_snake_case('camelCaseText')          // "camel_case_text"
kebab := strutils.to_kebab_case('camelCaseText')          // "camel-case-text"
pascal := strutils.to_pascal_case('hello_world')          // "HelloWorld"
println('${slug}, ${snake}, ${kebab}, ${pascal}')

masked_email := strutils.mask_email('john.doe@example.com') // "j******e@example.com"
token := strutils.random_alphanumeric(32)                   // 32-char secure random string
dist := strutils.levenshtein_distance('kitten', 'sitting')  // 3
println('${masked_email}, token len=${token.len}, dist=${dist}')
```

### 33. `sysutils`
```v
import sysutils

// Telemetry
cores := sysutils.get_cpu_count()
total_ram, used_ram, ram_pct := sysutils.get_memory_stats()
uptime := sysutils.get_uptime()
println('Cores: ${cores}, RAM: ${used_ram}/${total_ram} (${ram_pct:.1f}%), uptime: ${uptime}')

// Safe execution preventing command injection
safe_out, code := sysutils.exec_safe('echo', ['hello', 'world'])
println('Output: ${safe_out}, code: ${code}')

// Standard app directories
config_dir := sysutils.get_app_config_dir('my_app')
println('Config dir: ${config_dir}')
```

### 34. `tarutils`
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

### 35. `templateutils`
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

### 36. `timeutils`
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

### 37. `tomlutils`
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

### 38. `urlutils`
```v
import urlutils

// Parse RFC 3986 URL
u := urlutils.parse_url('https://admin:secret@api.io:8443/v1/users?page=1#top')!
println('Host: ${u.host_with_port()}') // "api.io:8443"
println('Path: ${u.path_segments()}')  // ["v1", "users"]

// Redact credentials for logs
redacted := urlutils.redact_credentials('postgres://user:pass@db:5432/main')
println(redacted) // "postgres://user:***@db:5432/main"
```

### 39. `validutils`
```v
import validutils

is_valid_email := validutils.validate_email('dev@example.com')
is_valid_url := validutils.validate_url('https://vlang.io')
is_valid_ip := validutils.validate_ip('192.168.1.1')
is_valid_json := validutils.validate_json('{"active": true}')
println('valid: email=${is_valid_email}, url=${is_valid_url}, ip=${is_valid_ip}, json=${is_valid_json}')
```

### 40. `webutils`
An Express-style framework. It replaces the usual stack of npm packages (helmet, cors, express-rate-limit, csurf, express-session, connect-flash, morgan, compression, serve-static, multer, body-parser, cookie-parser, supertest, ejs) with built-in, tested equivalents.

```v
import webutils
import json2

fn main() {
	mut app := webutils.new_app(secret: 'change-me') // security headers are on by default
	app.views.add('layout', '<title><%= title %></title><%- body %>') or { panic(err) }
	app.views.add('home', "<% layout 'layout' %><% for u in users %><p><%= u | title %></p><% end %>") or {
		panic(err)
	}

	app.use(webutils.logger())
	app.use(webutils.sessions())
	app.use(webutils.csrf())
	app.use(webutils.rate_limit(max: 100, window_ms: 60_000))
	app.static('/assets', 'public')

	app.get('/', fn (mut c webutils.Context) ! {
		c.render('home', {
			'title': json2.Any('Users')
			'users': webutils.to_any(['ann', '<script>bob</script>']) // auto-escaped
		})!
	})
	app.get('/api/users/:id', fn (mut c webutils.Context) ! {
		if c.param('id').int() <= 0 {
			return webutils.http_error(400, 'bad id')
		}
		c.json({
			'id': c.param('id')
		})
	})

	assert app.request(path: '/api/users/7').body == '{"id":"7"}' // built-in supertest
	app.listen(3000)
}
```

**Template cheatsheet** (EJS-compatible):

| Syntax | Meaning |
| :--- | :--- |
| `<%= expr %>` / `<%- expr %>` | HTML-escaped output / raw output |
| `<%# note %>` / `<%%` | comment / literal `<%` |
| `<% if x %>…<% elif y %>…<% else %>…<% end %>` | conditionals (`<% } else { %>` also works) |
| `<% for i, item in items %>…<% else %>…<% end %>` | loops with `loop.index`, `loop.first`, `loop.last` |
| `<% set total = a + b %>` | variables |
| `<%- include('partials/nav') %>` / `<% layout 'main' %>` + `<%- body %>` | partials and layouts |
| `<%= name \| upper \| truncate(10) %>` | 45+ filters (date, json, url, fixed, plural, default, join, …) |
| `-%>` / `<%_ _%>` | whitespace trimming |

**Security model.** Templates cannot run code: expressions use a sandboxed evaluator, so server-side template injection (SSTI) is impossible. Other protections:

- Output is auto-escaped, and `json` output is safe to embed in `<script>`.
- Includes, layouts and static files cannot escape their root directories, and dotfiles are hidden.
- A per-request CSP nonce is available to templates.
- Cookies are signed with HMAC, and CSRF uses signed double-submit tokens.
- Header values are stripped of CR/LF, which blocks header injection; `safe_redirect` blocks open redirects.
- Body size is limited; internal error messages are never sent to clients unless `debug: true`.

> [!TIP]
> V 0.5.2 compiler caveat: inside handler closures, return errors with `return webutils.http_error(status, msg)` or `return error(msg)`. Returning a custom `IError` value from a closure (for example `return webutils.new_http_error(...)`) makes the compiler run out of memory.

---

## Running Demos

You can run individual standalone demos for any utility module or execute all 40 demos sequentially:

```bash
# Run all 40 module demos sequentially with execution timing
v run demos/run_all_demos.v

# Or run any specific module demo directly
v run demos/demo_archiveutils.v
v run demos/demo_fileutils.v
v run demos/demo_jwtutils.v
v run demos/demo_mathutils.v
v run demos/demo_sqliteutils.v
# ... (see demos/ folder for all 40 demo scripts)

# Run the complete showcase console dashboard
v run main.v
```

## Running Tests

To run all automated test suites across every module:

```bash
v test .
```

## API Documentation

For the complete API reference with comprehensive, runnable examples for all public functions and structs, see [API.md](API.md).


