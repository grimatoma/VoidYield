class_name Speeder
extends VehicleBase
## Speeder vehicle — high-speed exploration vehicle with Vehicle Survey Mount support.
##
## Specs:
## - Speed: 520 px/sec
## - Carry bonus: +10 units
## - Fuel: 20 gas units
## - Unlock: Phase 2 (after any research lab, via tech progression)
## - Craft: 20 Steel Plates + 15 Alloy Rods + 5 Crystal Lattices at Fabricator
## - Cost (if purchasable): 1,200 CR
##
## Special Feature: Vehicle Survey Mount
## - Unlocked by tech node 3.S (Survey Tool Mk.II)
## - Cost: 600 CR + 5 Alloy Rods
## - Effect: Enables Full Scan while moving at ≤50 px/sec

func _ready() -> void:
	vehicle_id = "speeder"
	speed_px_per_sec = 520.0
	carry_bonus = 10
	fuel_type = "gas"
	fuel_tank_capacity = 20.0
	fuel_consumption_rate = 0.05  # Conservative consumption rate

	super._ready()


# --- Survey Mount Feature ---

func supports_survey_mount() -> bool:
	"""Speeder is the only vehicle that supports Vehicle Survey Mount."""
	return true


func install_survey_mount_from_tech() -> bool:
	"""Auto-install survey mount when tech node 3.S is unlocked."""
	if GameState.get_survey_tool_tier() >= 2:
		return install_survey_mount()
	return false


# --- Save/Load (inherits from VehicleBase) ---
# No additional properties to save beyond base class
