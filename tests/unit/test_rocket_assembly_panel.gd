extends "res://tests/framework/test_case.gd"
## Unit tests for RocketAssemblyPanel UI logic.

const RocketAssemblyPanelScript = preload("res://scenes/ui/rocket_assembly_panel.gd")
const RocketComponentScript = preload("res://data/rocket_component.gd")


func test_rocket_assembly_panel_tracks_components() -> void:
	var panel = RocketAssemblyPanelScript.new()
	var component = RocketComponentScript.new()
	component.component_type = "HULL"
	
	panel.install_component(component)
	assert_has(panel.installed_components, "HULL", "Should track installed components")


func test_rocket_assembly_panel_tracks_fuel() -> void:
	var panel = RocketAssemblyPanelScript.new()
	panel.add_fuel(50.0)
	assert_eq(panel.rocket_fuel_current, 50.0, "Should track fuel amount")


func test_rocket_assembly_panel_shows_completion_percentage() -> void:
	var panel = RocketAssemblyPanelScript.new()
	assert_eq(panel.get_completion_percentage(), 0, "Should be 0% complete with no components")
	
	var component = RocketComponentScript.new()
	component.component_type = "HULL"
	panel.install_component(component)
	
	var expected = int(1.0 / 5.0 * 100)  # 1 out of 5 components
	assert_eq(panel.get_completion_percentage(), expected, "Should show 20% after 1 component")


func test_rocket_assembly_panel_shows_launch_status() -> void:
	var panel = RocketAssemblyPanelScript.new()
	assert_false(panel.is_ready_to_launch(), "Should not be ready with no components or fuel")
	
	for component_type in ["HULL", "ENGINE", "FUEL_TANK", "AVIONICS", "LANDING_GEAR"]:
		var component = RocketComponentScript.new()
		component.component_type = component_type
		panel.install_component(component)
	
	panel.add_fuel(100.0)
	assert_true(panel.is_ready_to_launch(), "Should be ready with all components and 100 RF")
