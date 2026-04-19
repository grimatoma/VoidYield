class_name RocketComponent
extends Resource
## Data class for rocket components (HULL, ENGINE, FUEL_TANK, AVIONICS, LANDING_GEAR).

var component_type: String = ""  # HULL, ENGINE, FUEL_TANK, AVIONICS, LANDING_GEAR
var quality_attributes: Dictionary = {}
var carry_slots_required: int = 1
