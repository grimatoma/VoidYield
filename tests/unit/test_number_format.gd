extends "res://tests/framework/test_case.gd"
## Unit tests for NumberFormat (HUD formatting helpers).

const NumberFormat = preload("res://scripts/utils/number_format.gd")

func test_format_number_adds_commas() -> void:
	assert_eq(NumberFormat.format_number(0), "0")
	assert_eq(NumberFormat.format_number(999), "999")
	assert_eq(NumberFormat.format_number(1234), "1,234")
	assert_eq(NumberFormat.format_number(1234567), "1,234,567")


func test_format_number_handles_negatives() -> void:
	assert_eq(NumberFormat.format_number(-1234), "-1,234")


func test_format_with_unit_below_threshold() -> void:
	assert_eq(NumberFormat.format_with_unit(9999), "9,999")


func test_format_with_unit_thousands() -> void:
	assert_eq(NumberFormat.format_with_unit(10000), "10.0K")
	assert_eq(NumberFormat.format_with_unit(1500), "1,500",
		"under 10k stays as plain commas")


func test_format_with_unit_millions_and_billions() -> void:
	assert_eq(NumberFormat.format_with_unit(2_500_000), "2.5M")
	assert_eq(NumberFormat.format_with_unit(3_200_000_000), "3.2B")


func test_format_storage_uses_slash() -> void:
	assert_eq(NumberFormat.format_storage(42, 50), "42/50")
	assert_eq(NumberFormat.format_storage(1234, 5000), "1,234/5,000")


func test_format_time() -> void:
	assert_eq(NumberFormat.format_time(30.0), "30s")
	assert_eq(NumberFormat.format_time(90.0), "1:30")
	assert_eq(NumberFormat.format_time(3599.0), "59:59")
