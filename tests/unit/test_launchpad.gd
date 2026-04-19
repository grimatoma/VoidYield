extends "res://tests/framework/test_case.gd"
## Unit tests for Launchpad building.

const LaunchpadScript = preload("res://scenes/world/launchpad.gd")
const RocketComponentScript = preload("res://data/rocket_component.gd")


func test_launchpad_initializes_with_empty_components() -> void:
	var launchpad = LaunchpadScript.new()
	assert_eq(launchpad.installed_components.size(), 0, "Should start with no components")


func test_launchpad_tracks_rocket_fuel() -> void:
	var launchpad = LaunchpadScript.new()
	assert_eq(launchpad.rocket_fuel_current, 0.0, "Should start with 0 fuel")


func test_launchpad_can_install_component() -> void:
	var launchpad = LaunchpadScript.new()
	var component = RocketComponentScript.new()
	component.component_type = "HULL"
	
	launchpad.install_component(component)
	assert_has(launchpad.installed_components, "HULL", "Should install HULL component")


func test_launchpad_prevents_duplicate_components() -> void:
	var launchpad = LaunchpadScript.new()
	var hull1 = RocketComponentScript.new()
	hull1.component_type = "HULL"
	var hull2 = RocketComponentScript.new()
	hull2.component_type = "HULL"
	
	launchpad.install_component(hull1)
	launchpad.install_component(hull2)
	
	assert_eq(launchpad.installed_components.size(), 1, "Should not allow duplicate component types")


func test_launchpad_can_add_fuel() -> void:
	var launchpad = LaunchpadScript.new()
	launchpad.add_fuel(50.0)
	assert_eq(launchpad.rocket_fuel_current, 50.0, "Should add fuel")


func test_launchpad_is_ready_to_launch_with_all_components_and_fuel() -> void:
	var launchpad = LaunchpadScript.new()
	
	# Install all 5 components
	for component_type in ["HULL", "ENGINE", "FUEL_TANK", "AVIONICS", "LANDING_GEAR"]:
		var component = RocketComponentScript.new()
		component.component_type = component_type
		launchpad.install_component(component)
	
	# Add fuel
	launchpad.add_fuel(100.0)
	
	assert_true(launchpad.can_launch(), "Should be ready to launch with all components and 100 RF")


func test_launchpad_not_ready_without_fuel() -> void:
	var launchpad = LaunchpadScript.new()
	
	# Install all 5 components
	for component_type in ["HULL", "ENGINE", "FUEL_TANK", "AVIONICS", "LANDING_GEAR"]:
		var component = RocketComponentScript.new()
		component.component_type = component_type
		launchpad.install_component(component)
	
	# No fuel
	assert_false(launchpad.can_launch(), "Should not launch without 100 RF")


func test_launchpad_not_ready_missing_component() -> void:
	var launchpad = LaunchpadScript.new()
	
	# Install only 4 components
	for component_type in ["HULL", "ENGINE", "FUEL_TANK", "AVIONICS"]:
		var component = RocketComponentScript.new()
		component.component_type = component_type
		launchpad.install_component(component)
	
	launchpad.add_fuel(100.0)
	
	assert_false(launchpad.can_launch(), "Should not launch missing LANDING_GEAR")
