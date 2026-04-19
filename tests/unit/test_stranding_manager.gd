extends "res://tests/framework/test_case.gd"
## Unit tests for StrandingManager autoload.

const StrandingManagerScript = preload("res://autoloads/stranding_manager.gd")


func test_stranding_manager_initializes_not_stranded() -> void:
	var manager = StrandingManagerScript.new()
	assert_false(manager.is_stranded(), "Should not be stranded on A1")


func test_stranding_manager_becomes_stranded_on_planet_b() -> void:
	var manager = StrandingManagerScript.new()
	manager.arrive_on_planet_b()
	assert_true(manager.is_stranded(), "Should be stranded on arrival to Planet B")


func test_stranding_manager_sets_fuel_on_arrival() -> void:
	var manager = StrandingManagerScript.new()
	manager.arrive_on_planet_b()
	assert_eq(manager.rocket_fuel_current, 20.0, "Should have 20 RF on arrival")


func test_stranding_manager_escape_requires_100_fuel() -> void:
	var manager = StrandingManagerScript.new()
	manager.arrive_on_planet_b()
	manager.rocket_fuel_current = 99.0
	assert_true(manager.is_stranded(), "Should be stranded with 99 RF")
	
	manager.rocket_fuel_current = 100.0
	assert_false(manager.is_stranded(), "Should escape with 100 RF")


func test_stranding_manager_can_add_fuel() -> void:
	var manager = StrandingManagerScript.new()
	manager.arrive_on_planet_b()
	manager.add_fuel(50.0)
	assert_eq(manager.rocket_fuel_current, 70.0, "Should accumulate fuel (20 + 50)")
