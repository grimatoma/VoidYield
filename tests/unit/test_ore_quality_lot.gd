extends "res://tests/framework/test_case.gd"
## TDD unit tests for OreQualityLot resource class.
## Covers: grade computation, BER formula, lot generation, serialisation.


func _load_lot_class():
	return load("res://data/ore_quality_lot.gd")


func test_grade_A_when_er_gte_800() -> void:
	var OreQualityLot = _load_lot_class()
	var lot = OreQualityLot.new()
	lot.er = 800
	assert_eq(lot.grade, "A")


func test_grade_F_when_er_lt_200() -> void:
	var OreQualityLot = _load_lot_class()
	var lot = OreQualityLot.new()
	lot.er = 199
	assert_eq(lot.grade, "F")


func test_grade_boundaries() -> void:
	var OreQualityLot = _load_lot_class()
	var test_cases = [
		[800, "A"],
		[799, "B"],
		[600, "B"],
		[599, "C"],
		[400, "C"],
		[399, "D"],
		[200, "D"],
		[199, "F"],
	]
	for case in test_cases:
		var lot = OreQualityLot.new()
		lot.er = case[0]
		assert_eq(lot.grade, case[1], "ER %d should be grade %s" % [case[0], case[1]])


func test_ber_output_formula() -> void:
	var OreQualityLot = _load_lot_class()
	var lot = OreQualityLot.new()
	lot.er = 800
	lot.fl = 200

	# base_ber=10, concentration=80, er=800, fl=200, upgrade_mult=1.0
	# expected = 10*(80/100)*(800/1000)*1.0 + (200/1000*10*0.5) = 6.4 + 1.0 = 7.4
	var result = lot.ber_output(10.0, 80.0, 1.0)
	assert_near(result, 7.4, 0.001)


func test_ber_output_zero_concentration() -> void:
	var OreQualityLot = _load_lot_class()
	var lot = OreQualityLot.new()
	lot.er = 800
	lot.fl = 200

	# With concentration = 0, the multiplier term is 0
	# Only the FL bonus remains: (200/1000 * 10 * 0.5) = 1.0
	var result = lot.ber_output(10.0, 0.0, 1.0)
	assert_near(result, 1.0, 0.001)


func test_generate_rich_tier_mean_in_range() -> void:
	var OreQualityLot = _load_lot_class()
	# Generate 100 lots with "rich" tier, check mean ER is in expected range
	var er_values = []
	for i in 100:
		var lot = OreQualityLot.generate("rich")
		er_values.append(lot.er)

	var sum = 0.0
	for val in er_values:
		sum += val
	var mean = sum / er_values.size()

	# "rich" tier: mean ~750, sd 100
	# With 100 samples, should be roughly between 600 and 900
	assert_gt(mean, 600, "rich tier mean ER too low: %f" % mean)
	assert_lt(mean, 900, "rich tier mean ER too high: %f" % mean)


func test_generate_clamps_to_1000_max() -> void:
	var OreQualityLot = _load_lot_class()
	# Generate 50 lots, ensure no attribute exceeds 1000
	for i in 50:
		var lot = OreQualityLot.generate("motherlode")
		assert_ge(1000, lot.er, "ER exceeds 1000")
		assert_ge(1000, lot.cr, "CR exceeds 1000")
		assert_ge(1000, lot.cd, "CD exceeds 1000")
		assert_ge(1000, lot.dr, "DR exceeds 1000")
		assert_ge(1000, lot.fl, "FL exceeds 1000")
		assert_ge(1000, lot.hr, "HR exceeds 1000")
		assert_ge(1000, lot.ma, "MA exceeds 1000")
		assert_ge(1000, lot.pe, "PE exceeds 1000")
		assert_ge(1000, lot.sr, "SR exceeds 1000")
		assert_ge(1000, lot.ut, "UT exceeds 1000")


func test_generate_clamps_to_1_min() -> void:
	var OreQualityLot = _load_lot_class()
	# Generate 50 lots, ensure no attribute is below 1
	for i in 50:
		var lot = OreQualityLot.generate("poor")
		assert_ge(lot.er, 1, "ER below 1")
		assert_ge(lot.cr, 1, "CR below 1")
		assert_ge(lot.cd, 1, "CD below 1")
		assert_ge(lot.dr, 1, "DR below 1")
		assert_ge(lot.fl, 1, "FL below 1")
		assert_ge(lot.hr, 1, "HR below 1")
		assert_ge(lot.ma, 1, "MA below 1")
		assert_ge(lot.pe, 1, "PE below 1")
		assert_ge(lot.sr, 1, "SR below 1")
		assert_ge(lot.ut, 1, "UT below 1")


func test_roundtrip_serialisation() -> void:
	var OreQualityLot = _load_lot_class()
	var original = OreQualityLot.new()
	original.er = 850
	original.cr = 750
	original.cd = 650
	original.dr = 550
	original.fl = 450
	original.hr = 350
	original.ma = 250
	original.pe = 150
	original.sr = 100
	original.ut = 200

	var dict = original.to_dict()
	var restored = OreQualityLot.from_dict(dict)

	assert_eq(restored.er, 850)
	assert_eq(restored.cr, 750)
	assert_eq(restored.cd, 650)
	assert_eq(restored.dr, 550)
	assert_eq(restored.fl, 450)
	assert_eq(restored.hr, 350)
	assert_eq(restored.ma, 250)
	assert_eq(restored.pe, 150)
	assert_eq(restored.sr, 100)
	assert_eq(restored.ut, 200)
