class_name ColonyTiers
extends RefCounted
## Manages colony tier progression and associated needs.

const TIER_PROGRESSION = ["pioneer", "colonist", "technician", "engineer", "director"]

const TIER_NEEDS = {
	"pioneer": {
		"basic": {"gas": 2, "water": 1},
		"luxury": {"food": 1},
	},
	"colonist": {
		"basic": {"rations": 1, "gas": 2, "water": 1},
		"luxury": {"power_cell": 1},
	},
	"technician": {
		"basic": {"power_cell": 2, "rations": 1, "gas": 2},
		"luxury": {"bio_circuit": 1},
	},
	"engineer": {
		"basic": {"bio_circuit": 1, "power_cell": 2, "rations": 1},
		"luxury": {"warp_component": 1},
	},
	"director": {
		"basic": {"warp_component": 1, "bio_circuit": 1, "power_cell": 2},
		"luxury": {},
	},
}

var current_tier: String = "pioneer"
var current_tier_index: int = 0

signal tier_advanced(from_tier: String, to_tier: String)


func get_tier_needs(tier: String) -> Dictionary:
	if tier in TIER_NEEDS:
		return TIER_NEEDS[tier].duplicate(true)
	return {}


func get_all_tiers() -> Array:
	return TIER_PROGRESSION.duplicate()


func advance_tier() -> bool:
	if current_tier_index >= TIER_PROGRESSION.size() - 1:
		return false  # Already at max tier
	
	var from_tier = current_tier
	current_tier_index += 1
	current_tier = TIER_PROGRESSION[current_tier_index]
	
	tier_advanced.emit(from_tier, current_tier)
	return true


func can_advance_tier() -> bool:
	return current_tier_index < TIER_PROGRESSION.size() - 1
