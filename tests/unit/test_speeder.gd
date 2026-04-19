extends "res://tests/framework/test_case.gd"
## TDD unit tests for Speeder vehicle (M12).

const SpeederScript = preload("res://scenes/vehicles/speeder.gd")


func test_speeder_has_correct_speed() -> void:
	var speeder = SpeederScript.new()
	assert_eq(speeder.speed, 520, "Speeder speed should be 520 px/s")


func test_speeder_has_correct_carry_bonus() -> void:
	var speeder = SpeederScript.new()
	assert_eq(speeder.carry_bonus, 10, "Speeder carry bonus should be +10")


func test_speeder_has_correct_fuel_type() -> void:
	var speeder = SpeederScript.new()
	assert_eq(speeder.fuel_type, "gas", "Speeder fuel type should be gas")


func test_speeder_has_correct_fuel_capacity() -> void:
	var speeder = SpeederScript.new()
	assert_eq(speeder.fuel_capacity, 20, "Speeder fuel capacity should be 20 gas")


func test_speeder_fuel_depletes_on_movement() -> void:
	var speeder = SpeederScript.new()
	speeder.fuel_current = 20

	# Moving 520 px/s for 1 second should deplete fuel proportionally
	speeder.move(Vector2(520, 0), 1.0)

	assert_lt(speeder.fuel_current, 20, "Fuel should deplete on movement")


func test_speeder_stops_at_zero_fuel() -> void:
	var speeder = SpeederScript.new()
	speeder.fuel_current = 0.0

	var moved = speeder.move(Vector2(520, 0), 1.0)
	assert_eq(moved, Vector2.ZERO, "Speeder should not move with 0 fuel")


func test_speeder_refuel_increases_fuel() -> void:
	var speeder = SpeederScript.new()
	speeder.fuel_current = 10

	speeder.refuel(5)
	assert_eq(speeder.fuel_current, 15, "Fuel should increase by refuel amount")


func test_speeder_refuel_caps_at_capacity() -> void:
	var speeder = SpeederScript.new()
	speeder.fuel_current = 18

	speeder.refuel(5)
	assert_eq(speeder.fuel_current, 20, "Fuel should cap at capacity")


func test_speeder_is_drivable() -> void:
	var speeder = SpeederScript.new()
	assert_true(speeder.is_drivable, "Speeder should be drivable by default")


func test_speeder_movement_returns_movement_vector() -> void:
	var speeder = SpeederScript.new()
	speeder.fuel_current = 20

	var direction = Vector2(1, 0).normalized()
	var moved = speeder.move(direction * speeder.speed, 0.1)

	assert_gt(moved.length(), 0, "Movement should return non-zero vector")
	assert_le(moved.length(), 52, "Movement should not exceed 520 px/s × 0.1 s")
