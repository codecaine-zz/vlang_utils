module statutils

import math

// stats_mean returns the arithmetic average of a numeric slice, or 0.0 if empty.
pub fn stats_mean(arr []f64) f64 {
	if arr.len == 0 {
		return 0.0
	}
	mut sum := 0.0
	for x in arr {
		sum += x
	}
	return sum / f64(arr.len)
}

// stats_median returns the median value of a numeric slice, or 0.0 if empty.
pub fn stats_median(arr []f64) f64 {
	if arr.len == 0 {
		return 0.0
	}
	mut sorted := arr.clone()
	sorted.sort()
	n := sorted.len
	if n % 2 != 0 {
		return sorted[n / 2]
	}
	return (sorted[(n / 2) - 1] + sorted[n / 2]) / 2.0
}

// stats_mode returns the most frequently occurring value in the slice, or none if empty.
pub fn stats_mode(arr []f64) ?f64 {
	if arr.len == 0 {
		return none
	}
	mut counts := map[string]int{}
	for x in arr {
		key := '${x}'
		counts[key] = (counts[key] or { 0 }) + 1
	}
	mut max_count := 0
	mut mode_val := arr[0]
	for x in arr {
		key := '${x}'
		c := counts[key] or { 0 }
		if c > max_count {
			max_count = c
			mode_val = x
		}
	}
	return mode_val
}

// stats_variance computes the population variance of the slice.
pub fn stats_variance(arr []f64) f64 {
	if arr.len <= 1 {
		return 0.0
	}
	mean := stats_mean(arr)
	mut sum_sq := 0.0
	for x in arr {
		diff := x - mean
		sum_sq += diff * diff
	}
	return sum_sq / f64(arr.len)
}

// stats_std_dev computes the standard deviation of the slice.
pub fn stats_std_dev(arr []f64) f64 {
	return math.sqrt(stats_variance(arr))
}

// stats_geometric_mean computes the geometric mean of positive numbers.
pub fn stats_geometric_mean(arr []f64) f64 {
	if arr.len == 0 {
		return 0.0
	}
	mut log_sum := 0.0
	for x in arr {
		if x <= 0.0 {
			return 0.0
		}
		log_sum += math.log(x)
	}
	return math.exp(log_sum / f64(arr.len))
}

// stats_harmonic_mean computes the harmonic mean of positive numbers.
pub fn stats_harmonic_mean(arr []f64) f64 {
	if arr.len == 0 {
		return 0.0
	}
	mut inv_sum := 0.0
	for x in arr {
		if x == 0.0 {
			return 0.0
		}
		inv_sum += 1.0 / x
	}
	if inv_sum == 0.0 {
		return 0.0
	}
	return f64(arr.len) / inv_sum
}

// stats_rms computes the Root Mean Square (quadratic mean).
pub fn stats_rms(arr []f64) f64 {
	if arr.len == 0 {
		return 0.0
	}
	mut sq_sum := 0.0
	for x in arr {
		sq_sum += x * x
	}
	return math.sqrt(sq_sum / f64(arr.len))
}

// stats_percentile computes the value at percentile p (0.0 to 100.0).
pub fn stats_percentile(arr []f64, p f64) f64 {
	if arr.len == 0 {
		return 0.0
	}
	if p <= 0.0 {
		return stats_min(arr) or { 0.0 }
	}
	if p >= 100.0 {
		return stats_max(arr) or { 0.0 }
	}
	mut sorted := arr.clone()
	sorted.sort()
	rank := (p / 100.0) * f64(sorted.len - 1)
	lower := int(math.floor(rank))
	upper := int(math.ceil(rank))
	weight := rank - f64(lower)
	return sorted[lower] * (1.0 - weight) + sorted[upper] * weight
}

// stats_min returns the minimum value in the slice, or none if empty.
pub fn stats_min(arr []f64) ?f64 {
	if arr.len == 0 {
		return none
	}
	mut m := arr[0]
	for x in arr[1..] {
		if x < m {
			m = x
		}
	}
	return m
}

// stats_max returns the maximum value in the slice, or none if empty.
pub fn stats_max(arr []f64) ?f64 {
	if arr.len == 0 {
		return none
	}
	mut m := arr[0]
	for x in arr[1..] {
		if x > m {
			m = x
		}
	}
	return m
}
