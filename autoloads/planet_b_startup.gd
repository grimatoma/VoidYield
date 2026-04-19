class_name PlanetBStartup
extends RefCounted
## Provides starting supplies for Planet B arrival (as per spec 09).

func get_starting_supplies() -> Dictionary:
	return {
		"survey_tool": 1,
		"gas_canisters": 5,
		"gas_collector_deed": 1,
		"mineral_harvester_deed": 1,
		"crafting_station_deed": 1,
		"steel_plates": 50,
		"alloy_rods": 10,
		"credits": 200,
	}


func apply_starting_supplies() -> void:
	# This would integrate with GameState, Inventory, etc. when full game wiring is done
	pass
