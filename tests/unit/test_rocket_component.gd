extends "res://tests/framework/test_case.gd"
## Unit tests for RocketComponent resource.

const RocketComponentScript = preload("res://data/rocket_component.gd")


func test_rocket_component_has_component_type() -> void:
	var component = RocketComponentScript.new()
	component.component_type = "HULL"
	assert_eq(component.component_type, "HULL", "Should store component_type")


func test_rocket_component_has_quality_attributes() -> void:
	var component = RocketComponentScript.new()
	component.quality_attributes = {"sr": 440.0, "ut": 600.0}
	assert_eq(component.quality_attributes.get("sr"), 440.0, "Should store quality_attributes")


func test_rocket_component_has_carry_slots() -> void:
	var component = RocketComponentScript.new()
	component.carry_slots_required = 3
	assert_eq(component.carry_slots_required, 3, "Should store carry_slots_required")


func test_rocket_component_types_valid() -> void:
	var valid_types = ["HULL", "ENGINE", "FUEL_TANK", "AVIONICS", "LANDING_GEAR"]
	for type_name in valid_types:
		var component = RocketComponentScript.new()
		component.component_type = type_name
		assert_eq(component.component_type, type_name, "Should accept %s type" % type_name)
