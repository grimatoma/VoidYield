class_name SectorManager
extends RefCounted
## Sector Manager — tracks completion conditions and prestige progression (M14).

const SECTOR_COMPLETE_CONDITIONS = {
	"warp_gate_built": false,
	"galactic_hub_complete": false,
	"all_planets_automated": false,
}

const PRESTIGE_BONUSES = [
	"Veteran Miner",      # +20% ore yields
	"Fleet Commander",    # 2 starter drones
	"Survey Expert",      # 50% survey time
	"Trade Connections",  # +10% sell prices
	"Refined Tastes",     # -20% building costs
	"Research Heritage",  # +50% RP generation
	"Harvester Legacy",   # +15% harvester speed
	"Fuel Surplus",       # Start with 500 RF
	"Pioneer Spirit",     # +2 starting population
	"Void Walker",        # +5% void ore quality
]

var sector_number: int = 1
var is_sector_complete: bool = false
var selected_prestige_bonus: String = ""
var prestige_bonuses: Array[String] = []

signal sector_complete
signal prestige_selected(bonus_name: String)


func check_sector_complete() -> bool:
	var all_conditions_met = (
		SECTOR_COMPLETE_CONDITIONS.get("warp_gate_built", false) and
		SECTOR_COMPLETE_CONDITIONS.get("galactic_hub_complete", false) and
		SECTOR_COMPLETE_CONDITIONS.get("all_planets_automated", false)
	)

	if all_conditions_met and not is_sector_complete:
		is_sector_complete = true
		sector_complete.emit()
		return true

	return false


func mark_warp_gate_built() -> void:
	SECTOR_COMPLETE_CONDITIONS["warp_gate_built"] = true
	check_sector_complete()


func mark_galactic_hub_complete() -> void:
	SECTOR_COMPLETE_CONDITIONS["galactic_hub_complete"] = true
	check_sector_complete()


func mark_planets_automated() -> void:
	SECTOR_COMPLETE_CONDITIONS["all_planets_automated"] = true
	check_sector_complete()


func select_prestige_bonus(bonus_name: String) -> bool:
	if bonus_name in PRESTIGE_BONUSES:
		selected_prestige_bonus = bonus_name
		prestige_bonuses.append(bonus_name)
		prestige_selected.emit(bonus_name)
		return true
	return false


func get_prestige_bonus_effect(bonus_name: String) -> Dictionary:
	match bonus_name:
		"Veteran Miner":
			return {"ore_yield": 1.2}
		"Fleet Commander":
			return {"starting_drones": 2}
		"Survey Expert":
			return {"survey_time": 0.5}
		"Trade Connections":
			return {"sell_price": 1.1}
		"Refined Tastes":
			return {"build_cost": 0.8}
		"Research Heritage":
			return {"rp_generation": 1.5}
		"Harvester Legacy":
			return {"harvester_speed": 1.15}
		"Fuel Surplus":
			return {"starting_rf": 500}
		"Pioneer Spirit":
			return {"starting_population": 2}
		"Void Walker":
			return {"void_ore_quality": 1.05}
		_:
			return {}


func reset_for_next_sector() -> void:
	sector_number += 1
	is_sector_complete = false
	SECTOR_COMPLETE_CONDITIONS["warp_gate_built"] = false
	SECTOR_COMPLETE_CONDITIONS["galactic_hub_complete"] = false
	SECTOR_COMPLETE_CONDITIONS["all_planets_automated"] = false


func get_save_data() -> Dictionary:
	return {
		"sector_number": sector_number,
		"prestige_bonuses": prestige_bonuses.duplicate(),
	}


func load_save_data(data: Dictionary) -> void:
	sector_number = data.get("sector_number", 1)
	var raw_bonuses = data.get("prestige_bonuses", [])
	prestige_bonuses.clear()
	for bonus in raw_bonuses:
		prestige_bonuses.append(str(bonus))
