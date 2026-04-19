class_name Launchpad
extends Node2D
## Rocket launch facility. Accepts 5 components and rocket fuel.

const REQUIRED_COMPONENTS = ["HULL", "ENGINE", "FUEL_TANK", "AVIONICS", "LANDING_GEAR"]
const MIN_LAUNCH_FUEL = 100.0

var rocket_fuel_current: float = 0.0
var installed_components: Dictionary = {}

signal component_installed(component_type: String)
signal fuel_added(amount: float, current_total: float)
signal launch_ready


func install_component(component: RocketComponent) -> bool:
	if component.component_type in installed_components:
		return false
	
	installed_components[component.component_type] = component
	component_installed.emit(component.component_type)
	
	if can_launch():
		launch_ready.emit()
	
	return true


func add_fuel(amount: float) -> void:
	rocket_fuel_current += amount
	fuel_added.emit(amount, rocket_fuel_current)
	
	if can_launch():
		launch_ready.emit()


func can_launch() -> bool:
	if rocket_fuel_current < MIN_LAUNCH_FUEL:
		return false
	
	for required in REQUIRED_COMPONENTS:
		if not required in installed_components:
			return false
	
	return true


func launch() -> void:
	if not can_launch():
		return
	
	# Launch logic will be wired in the launchpad scene
	pass
