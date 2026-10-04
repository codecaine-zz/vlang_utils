# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/) and the project uses
[Semantic Versioning](https://semver.org/).

## [2.0.0] — 2026-10-04

**Fully backward compatible.** No public function, struct, or field was renamed
or removed, and no signature changed. Every change ships with tests, using
published reference vectors (RFCs, SciPy) wherever they exist.

### Security

- **cryptoutils**: tokens, UUIDs, and random strings now come from the OS CSPRNG
  (`crypto.rand`) instead of a predictable PRNG.
- **cryptoutils**: `secure_compare` now runs in constant time, and TOTP counter
  arithmetic no longer overflows.
- **jwtutils**: `verify_jwt` now checks the header `alg`, which blocks `alg: none`
  and algorithm-confusion attacks.
- **htmlutils**: `unescape_html` now decodes in a single pass, so `&amp;lt;` no
  longer double-decodes into `<`. Added an allow-list `sanitize_html`.
- **templateutils**: new `render_mustache` / `render_template_html` escape
  output by default (XSS-safe).
- **logutils**: new `redact_fields` with a default list of secret keys.
- **tarutils**: `extract_tar` blocks **tar-slip** path traversal (absolute paths,
  `..`). The whole archive is validated before anything is written, and symlink and
  device entries are never materialised.
- **archiveutils**: `unzip_to_dir` rejects **zip-slip** archives. New
  `extract_safe` also bounds entry count and total/per-entry sizes (zip bombs).
- **compressutils**: new `decompress_limited` stops decompression bombs (streamed
  abort for gzip/zlib/deflate; zstd's declared frame size is checked before allocation).
- **netutils**: `read_framed_msg` no longer lets a length >= 2^31 wrap
  negative, pass the size check and panic. New `is_public_ip` covers the IANA
  special-purpose blocks for SSRF defence, and `ipv4_to_u32` rejects ambiguous
  leading-zero (octal) octets.
- **sysutils**: new shell-free `run_command` (no injection possible by construction).

### Fixed

- **fileutils**: recursive `list_files` now descends into subdirectories correctly.
- **cacheutils**: LRU get/put is now truly O(1) (it was O(n)).
- **timeutils**: `time_ago` no longer outputs "0 years".
- **cronutils**: when both are restricted, day-of-month and day-of-week now
  combine with POSIX OR semantics. Integer parsing is strict, and `next_after`
  skips whole fields and searches up to 10 years ahead.
- **urlutils**: fixed parsing of IPv6 hosts with ports, an `@` inside passwords
  (the last `@` is now the separator), port range validation, and
  userinfo escaping.
- **envutils**: `save_dotenv` output now parses back identically (escapes,
  multiline values, `export`, and inline `#` comments only after whitespace).
- **colorutils**: `hsl_to_rgb` now rounds instead of truncating (fixing lossy
  round-trips) and wraps negative hues.
- **asyncutils**: fixed a race when submitting to a `WorkerPool` after `stop()`.
- **eventutils**: `once` handlers are cleaned up reliably.
- **graphutils**: `add_node` is now O(1), BFS uses index-based O(1) queues, and DFS is
  iterative (no stack overflow on deep graphs) with the same visiting order.
- **flowutils**: the sliding-window rate limiter uses the monotonic clock and prunes
  in amortised O(1).
- **semverutils**: `parse` now rejects invalid identifiers (leading zeros, empty
  parts, bad characters).
- **markdownutils**: link destinations may contain balanced parentheses.
- **sysutils**: `exec_timeout` now kills the command's whole process group at the
  deadline (it used to run to completion and only label the result).
  `sanitize_filename` no longer returns `.`/`..` and guards Windows device names.
- **netutils**: `ping_tcp_port` honours `timeout_ms` and brackets IPv6 hosts;
  `is_online` can no longer hang.
- **tarutils**: names longer than 100 bytes are no longer truncated (ustar
  prefix and PAX). Header checksums are verified, the `size` field always
  matches the data, and PAX and GNU long names are read. `.tar.gz` is
  auto-detected.
- **compressutils**: zstd round-trips of empty input no longer fail.
- **cliutils**: `strip_ansi` no longer swallows text up to the next `m` for
  non-colour escapes, and handles OSC hyperlinks. `FlagParser` handles `--`,
  `-n5`, `-abc`, negative numbers and typed validation, and reports missing values.
- **stateutils**: state files are fsync'd before the atomic rename (durable on
  power loss), and temp files are cleaned up on failure.
- **bitutils**: `popcount` uses the hardware intrinsic.

### Added

- **New module `jsonutils`**: `parse`, `pretty`, `minify`, `canonical`,
  `deep_equal`, JSON Pointer (RFC 6901) `pointer_get` / `pointer_set`, JSON
  Merge Patch (RFC 7386), structural `diff`, `flatten`.
- **New module `markdownutils`**: CommonMark-style `to_html` with GFM tables,
  task lists, nested lists, heading IDs, safe links, plus `toc`, `headings`,
  `slug`, `to_plain_text`.
- **New module `webutils`**: an Express-style web framework that depends only on
  vlib. It includes:
  - Routing with params, optional params, wildcards and groups; automatic
    HEAD, OPTIONS and 405 handling.
  - A secure, EJS-compatible template engine with layouts, partials, loops,
    45+ filters and auto-escaping. Expressions are sandboxed, so templates
    cannot execute code.
  - Built-in middleware: security headers with a CSP nonce, CORS, rate
    limiting, CSRF, sessions and flash, logger, request ID, gzip, basic and
    bearer auth, body limits, and static files with ETag and 304 support.
  - Signed cookies, a bounded multipart parser, JSON binding, `send_file` and
    `download`, and `app.request(...)` for in-process testing.
- **strutils / sliceutils / mathutils / validutils / timeutils / httputils**:
  many new hardened helpers (see `API.md`).
- **jwtutils**: HS256/384/512 (`JWTAlgorithm`), `sign_jwt_with`,
  `verify_jwt_with` (leeway, issuer, audience, `max_age`, `require_exp`),
  `decode_jwt_unverified`, `refresh_jwt`.
- **asyncutils**: `parallel_try_map`, `parallel_reduce`, `with_timeout`,
  `Semaphore`, `Once`.
- **semverutils**: full npm-style range engine (`||`, hyphen ranges, x-ranges,
  `~`, `^`, `~>`), `coerce`, `sort_versions`, `max_satisfying`,
  `min_satisfying`, `diff`, `is_valid_range`.
- **cronutils**: `@daily`-style macros, month and day names, `a-b/n` steps,
  `next_n`, `is_valid_cron`.
- **diffutils**: Myers O(ND) engine, `diff_words`, `diff_chars`, `diff_stats`,
  `similarity`, unified hunks, verified `apply_patch`, `render_ansi`.
- **urlutils**: RFC 3986 `resolve_reference`, `remove_dot_segments`,
  `normalize_url`, `origin`, `is_same_origin`, query encoding helpers.
- **envutils**: `expand_with` (`${VAR:-default}`, `$$`), `parse_dotenv_expand`,
  `load_dotenv_no_override`, `get_duration`, `get_enum`, `require_all`,
  `with_env`.
- **colorutils**: HSV, CMYK, CIE Lab, OKLab, OKLCH; `delta_e76`, `mix_oklab`,
  `gradient`, colour harmonies, `ensure_contrast`, `parse_color`,
  `to_ansi256`.
- **graphutils**: `shortest_path`, Tarjan SCC, `find_cycle`, `UnionFind`,
  `WeightedGraph[T]` with Dijkstra, A*, Kruskal MST.
- **eventutils**: subscription IDs, `subscribe_once`, wildcard `on_any`,
  `TypedEmitter[T]`.
- **structutils**: `PriorityQueue[T]`, `Deque[T]`, `Trie`, `OptimalBloom`,
  `HyperLogLog`.
- **statutils**: `RunningStats` (Welford, mergeable), `histogram`, Student-t
  CDF, Welch's t-test (matches SciPy to 1e-9), confidence intervals.
- **logutils**: `parse_level`, logfmt and JSON records, `log_kv`, `log_json`,
  `rotate_file`.
- **htmlutils**: `html_to_text`; **templateutils**: Mustache sections,
  inverted sections, and partial-free logic-less rendering.
- **tarutils**: `create_tar_from_dir`, `.tar.gz` pack/unpack/extract,
  mode/mtime/typeflag/linkname fields, `find_entry`.
- **archiveutils**: `create_zip` (in-memory), `zip_dir_with` (real compression
  levels), `has_entry`, `total_uncompressed_size`, `read_all_entries`.
- **compressutils**: format auto-detection, zstd levels, CRC-32 / Adler-32,
  `compress_best`, file helpers.
- **netutils**: IPv4/IPv6 parsing, RFC 5952 canonical formatting, CIDR maths
  (`IPNet`: contains/overlaps/broadcast/hosts), address classification,
  `split_host_port`, `find_free_port`, `resolve_host`, `wait_for_port`.
- **sqliteutils**: versioned `migrate` (PRAGMA user_version, transactional),
  trigger-aware `split_sql_statements` / `exec_script`, `upsert_row`,
  `paginate`, `integrity_check`, `vacuum_into` backups, `enable_wal`.
- **regexutils**: compiled `Regex`, `escape`, captures and named captures,
  `replace_fn`, `count_matches`.
- **mockutils**: seeded, deterministic `Faker` (documentation-range IPs, UUIDv4,
  Luhn-valid test cards, passwords, dates, companies...).
- **bitutils**: clz/ctz, powers of two, rotations, bit reversal, Gray code,
  Morton codes, BitSet set algebra.
- **tomlutils**: `require_*`, typed array getters, `keys`, `to_json`, generic
  `decode` / `encode`.

## [1.0.0]

- Initial release with 37 utility modules.
