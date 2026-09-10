module statutils

import math

fn test_statistical_calculations() {
	data := [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]

	// Mean: (2+4+4+4+5+5+7+9)/8 = 40/8 = 5.0
	assert stats_mean(data) == 5.0

	// Median: (4+5)/2 = 4.5
	assert stats_median(data) == 4.5

	// Mode: 4.0
	assert stats_mode(data) or { 0.0 } == 4.0

	// Variance: ((2-5)^2 + 3*(4-5)^2 + 2*(5-5)^2 + (7-5)^2 + (9-5)^2)/8
	// = (9 + 3 + 0 + 4 + 16)/8 = 32/8 = 4.0
	assert stats_variance(data) == 4.0

	// Std Dev: sqrt(4) = 2.0
	assert stats_std_dev(data) == 2.0

	// Min / Max
	assert stats_min(data) or { 0.0 } == 2.0
	assert stats_max(data) or { 0.0 } == 9.0

	// Percentiles
	p50 := stats_percentile(data, 50.0)
	assert math.abs(p50 - 4.5) < 0.01

	// Geometric & Harmonic mean
	positives := [1.0, 2.0, 4.0]
	geo := stats_geometric_mean(positives)
	assert math.abs(geo - 2.0) < 0.01

	harm := stats_harmonic_mean(positives)
	assert harm > 1.0 && harm < 2.0

	// RMS
	rms := stats_rms([3.0, 4.0])
	// sqrt((9+16)/2) = sqrt(12.5) ~= 3.5355
	assert math.abs(rms - math.sqrt(12.5)) < 0.01
}
