module sliceutils

import rand

// contains checks whether a target item exists in the slice.
pub fn contains[T](arr []T, target T) bool {
	for item in arr {
		if item == target {
			return true
		}
	}
	return false
}

// unique returns a new slice containing only distinct elements, preserving order of first appearance.
pub fn unique[T](arr []T) []T {
	mut res := []T{cap: arr.len}
	for item in arr {
		if !contains(res, item) {
			res << item
		}
	}
	return res
}

// intersection returns elements present in both a and b, with duplicates removed.
pub fn intersection[T](a []T, b []T) []T {
	mut res := []T{}
	for item in a {
		if contains(b, item) && !contains(res, item) {
			res << item
		}
	}
	return res
}

// difference returns elements present in a that are not in b.
pub fn difference[T](a []T, b []T) []T {
	mut res := []T{}
	for item in a {
		if !contains(b, item) && !contains(res, item) {
			res << item
		}
	}
	return res
}

// union_slices returns all unique elements from both slices combined.
pub fn union_slices[T](a []T, b []T) []T {
	mut res := []T{cap: a.len + b.len}
	for item in a {
		if !contains(res, item) {
			res << item
		}
	}
	for item in b {
		if !contains(res, item) {
			res << item
		}
	}
	return res
}

// chunk splits a slice into smaller slices of specified size.
pub fn chunk[T](arr []T, size int) [][]T {
	if size <= 0 || arr.len == 0 {
		return [][]T{}
	}
	mut chunks := [][]T{}
	mut current := []T{cap: size}
	for item in arr {
		current << item
		if current.len == size {
			chunks << current
			current = []T{cap: size}
		}
	}
	if current.len > 0 {
		chunks << current
	}
	return chunks
}

// flatten converts a 2D slice into a 1D slice.
pub fn flatten[T](matrix [][]T) []T {
	mut total_len := 0
	for row in matrix {
		total_len += row.len
	}
	mut res := []T{cap: total_len}
	for row in matrix {
		for item in row {
			res << item
		}
	}
	return res
}

// find_index returns the index of the first element satisfying the predicate, or none.
pub fn find_index[T](arr []T, pred fn (item T) bool) ?int {
	for i, item in arr {
		if pred(item) {
			return i
		}
	}
	return none
}

// partition splits a slice into two slices: those satisfying the predicate and those that do not.
pub fn partition[T](arr []T, pred fn (item T) bool) ([]T, []T) {
	mut passed := []T{}
	mut failed := []T{}
	for item in arr {
		if pred(item) {
			passed << item
		} else {
			failed << item
		}
	}
	return passed, failed
}

// count returns the number of times target appears in the slice.
pub fn count[T](arr []T, target T) int {
	mut c := 0
	for item in arr {
		if item == target {
			c++
		}
	}
	return c
}

// sample randomly selects n items from the slice without replacement.
pub fn sample[T](arr []T, n int) []T {
	if n <= 0 || arr.len == 0 {
		return []T{}
	}
	if n >= arr.len {
		mut copy := arr.clone()
		shuffle(mut copy)
		return copy
	}
	mut indices := []int{cap: arr.len}
	for i in 0 .. arr.len {
		indices << i
	}
	rand.shuffle(mut indices) or {}
	mut res := []T{cap: n}
	for i in 0 .. n {
		res << arr[indices[i]]
	}
	return res
}

// shuffle randomly reorders elements in place using Fisher-Yates shuffle.
pub fn shuffle[T](mut arr []T) {
	if arr.len <= 1 {
		return
	}
	for i := arr.len - 1; i > 0; i-- {
		j := rand.int_in_range(0, i + 1) or { 0 }
		temp := arr[i]
		arr[i] = arr[j]
		arr[j] = temp
	}
}

// sum_int returns the sum of all elements in an integer slice.
pub fn sum_int(arr []int) int {
	mut total := 0
	for item in arr {
		total += item
	}
	return total
}

// average_int returns the arithmetic mean of an integer slice, or 0.0 if empty.
pub fn average_int(arr []int) f64 {
	if arr.len == 0 {
		return 0.0
	}
	return f64(sum_int(arr)) / f64(arr.len)
}

// min_int returns the smallest integer in the slice, or none if empty.
pub fn min_int(arr []int) ?int {
	if arr.len == 0 {
		return none
	}
	mut m := arr[0]
	for item in arr[1..] {
		if item < m {
			m = item
		}
	}
	return m
}

// max_int returns the largest integer in the slice, or none if empty.
pub fn max_int(arr []int) ?int {
	if arr.len == 0 {
		return none
	}
	mut m := arr[0]
	for item in arr[1..] {
		if item > m {
			m = item
		}
	}
	return m
}

// sum_f64 returns the sum of all elements in a float slice.
pub fn sum_f64(arr []f64) f64 {
	mut total := 0.0
	for item in arr {
		total += item
	}
	return total
}

// average_f64 returns the arithmetic mean of a float slice, or 0.0 if empty.
pub fn average_f64(arr []f64) f64 {
	if arr.len == 0 {
		return 0.0
	}
	return sum_f64(arr) / f64(arr.len)
}

// min_f64 returns the minimum float in the slice, or none if empty.
pub fn min_f64(arr []f64) ?f64 {
	if arr.len == 0 {
		return none
	}
	mut m := arr[0]
	for item in arr[1..] {
		if item < m {
			m = item
		}
	}
	return m
}

// max_f64 returns the maximum float in the slice, or none if empty.
pub fn max_f64(arr []f64) ?f64 {
	if arr.len == 0 {
		return none
	}
	mut m := arr[0]
	for item in arr[1..] {
		if item > m {
			m = item
		}
	}
	return m
}
