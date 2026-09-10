module cryptoutils

import crypto.hmac
import crypto.md5 as vmd5
import crypto.sha256 as vsha256
import crypto.sha512 as vsha512
import encoding.base64
import encoding.hex
import rand

// sha256 returns the hexadecimal SHA-256 hash of a string.
pub fn sha256(s string) string {
	return vsha256.hexhash(s)
}

// sha256_hex is an alias for sha256.
pub fn sha256_hex(s string) string {
	return vsha256.hexhash(s)
}

// sha512 returns the hexadecimal SHA-512 hash of a string.
pub fn sha512(s string) string {
	return vsha512.hexhash(s)
}

// sha512_hex is an alias for sha512.
pub fn sha512_hex(s string) string {
	return vsha512.hexhash(s)
}

// md5 returns the hexadecimal MD5 hash of a string.
pub fn md5(s string) string {
	return vmd5.hexhash(s)
}

// md5_hex is an alias for md5.
pub fn md5_hex(s string) string {
	return vmd5.hexhash(s)
}

// hmac_sha256 computes the HMAC-SHA256 digest of data with the given key, returned as hex.
pub fn hmac_sha256(key string, data string) string {
	digest := hmac.new(key.bytes(), data.bytes(), vsha256.sum, vsha256.block_size)
	return hex.encode(digest)
}

// base64_encode encodes a string to standard Base64.
pub fn base64_encode(s string) string {
	return base64.encode_str(s)
}

// base64_decode decodes a standard Base64 string into its original representation.
pub fn base64_decode(s string) !string {
	return base64.decode_str(s)
}

// base64_url_encode encodes a string to URL-safe Base64 without padding.
pub fn base64_url_encode(s string) string {
	return base64.url_encode_str(s)
}

// base64_url_decode decodes a URL-safe Base64 string.
pub fn base64_url_decode(s string) !string {
	return base64.url_decode_str(s)
}

// to_hex encodes a byte slice into a hexadecimal string.
pub fn to_hex(b []u8) string {
	return hex.encode(b)
}

// from_hex decodes a hexadecimal string into a byte slice.
pub fn from_hex(s string) ![]u8 {
	return hex.decode(s)
}

// secure_token generates a cryptographically random hexadecimal token of the specified byte length.
pub fn secure_token(byte_count int) string {
	if byte_count <= 0 {
		return ''
	}
	mut b := []u8{len: byte_count}
	rand.read(mut b)
	return hex.encode(b)
}

// uuid_v4 generates a cryptographically random RFC 4122 version 4 UUID.
pub fn uuid_v4() string {
	mut b := []u8{len: 16}
	rand.read(mut b)
	// Set version to 4 (0100) in the most significant 4 bits of the 7th byte
	b[6] = (b[6] & 0x0f) | 0x40
	// Set variant to RFC 4122 (10) in the most significant 2 bits of the 9th byte
	b[8] = (b[8] & 0x3f) | 0x80

	h := hex.encode(b)
	return '${h[0..8]}-${h[8..12]}-${h[12..16]}-${h[16..20]}-${h[20..32]}'
}

// is_valid_uuid verifies if a string matches canonical UUID format (8-4-4-4-12 hex digits).
pub fn is_valid_uuid(s string) bool {
	if s.len != 36 {
		return false
	}
	for i, c in s {
		if i == 8 || i == 13 || i == 18 || i == 23 {
			if c != `-` {
				return false
			}
		} else {
			is_hex := (c >= `0` && c <= `9`) || (c >= `a` && c <= `f`) || (c >= `A` && c <= `F`)
			if !is_hex {
				return false
			}
		}
	}
	return true
}
