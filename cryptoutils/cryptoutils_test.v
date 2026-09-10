module cryptoutils

fn test_hashing() {
	// Standard test vectors
	// MD5("hello") = 5d41402abc4b2a76b9719d911017c592
	assert md5('hello') == '5d41402abc4b2a76b9719d911017c592'

	// SHA256("hello") = 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
	assert sha256('hello') == '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824'

	// SHA512("hello") length is 128 hex chars
	h512 := sha512('hello')
	assert h512.len == 128

	// HMAC-SHA256
	hm := hmac_sha256('secret', 'message')
	assert hm.len == 64
}

fn test_base64() {
	orig := 'Hello, V developer!'
	encoded := base64_encode(orig)
	assert encoded == 'SGVsbG8sIFYgZGV2ZWxvcGVyIQ=='

	decoded := base64_decode(encoded) or { '' }
	assert decoded == orig

	url_enc := base64_url_encode(orig)
	url_dec := base64_url_decode(url_enc) or { '' }
	assert url_dec == orig
}

fn test_hex_conversion() {
	bytes := [u8(0xde), u8(0xad), u8(0xbe), u8(0xef)]
	h := to_hex(bytes)
	assert h.to_lower() == 'deadbeef'

	decoded := from_hex('deadbeef') or { []u8{} }
	assert decoded == bytes
}

fn test_uuid_v4() {
	uuid := uuid_v4()
	assert uuid.len == 36
	assert is_valid_uuid(uuid)
	assert is_valid_uuid('123e4567-e89b-12d3-a456-426614174000')
	assert !is_valid_uuid('invalid-uuid-string')
	assert !is_valid_uuid('123e4567-e89b-12d3-a456-42661417400Z')

	// Test secure token
	token := secure_token(16)
	assert token.len == 32
}
