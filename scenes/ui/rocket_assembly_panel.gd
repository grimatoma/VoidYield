class_name RocketAssemblyPanel
extends Control
## UI panel for rocket assembly. Shows components, fuel, and launch readiness.

const REQUIRED_COMPONENTS = ["HULL", "ENGINE", "FUEL_TANK", "AVIONICS", "LANDING_GEAR"]
const MIN_LAUNCH_FUEL = 100.0

var installed_components: Dictionary = {}
var rocket_fuel_current: float = 0.0


func install_component(component: RocketComponent) -> void:
	if component.component_type not in installed_components:
		installed_components[component.component_type] = component


func add_fuel(amount: float) -> void:
	rocket_fuel_current += amount


func get_completion_percentage() -> int:
	var completed = 0
	for required in REQUIRED_COMPONENTS:
		if required in installed_components:
			completed += 1
	return int((float(completed) / float(REQUIRED_COMPONENTS.size())) * 100.0)


func is_ready_to_launch() -> bool:
	if rocket_fuel_current < MIN_LAUNCH_FUEL:
		return false
	
	for required in REQUIRED_COMPONENTS:
		if not required in installed_components:
			return false
	
	return true


func get_component_status(component_type: String) -> String:
	if component_type in installed_components:
		var component = installed_components[component_type]
		var grade = "?"
		if component.quality_attributes.size() > 0:
			# Grade would be computed from attributes; simplified for now
			grade = "C"
		return "✓ %s (Grade %s)" % [component_type, grade]
	return "❌ %s" % component_type


func get_fuel_status() -> String:
	return "%.0f / %.0f RF" % [rocket_fuel_current, MIN_LAUNCH_FUEL]
