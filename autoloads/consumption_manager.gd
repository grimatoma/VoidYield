extends Node
## ConsumptionManager — Population tier tracking, needs satisfaction, and productivity multiplier.
##
## Tracks per-planet:
## - Current population tier (Pioneers → Colonists → Technicians → Engineers → Directors)
## - Population count per tier
## - Supply percentage for each consumable resource
## - Productivity multiplier based on basic need satisfaction
## - Tier advancement conditions (luxury needs 100% for 10 consecutive minutes)

signal tier_advanced(planet_id: String, old_tier: String, new_tier: String)
signal productivity_changed(planet_id: String, new_multiplier: float)

## Tier progression sequence
const TIER_SEQUENCE = ["pioneers", "colonists", "technicians", "engineers", "directors"]

## Population count per tier per planet — initialized with 4 Pioneers
var population_data: Dictionary = {
	# "a1": {
	#   "tier": "pioneers",
	#   "population": {
	#     "pioneers": 4,
	#     "colonists": 0,
	#     "technicians": 0,
	#     "engineers": 0,
	#     "directors": 0,
	#   },
	#   "supply": {
	#     "compressed_gas": 100.0,
	#     "water": 100.0,
	#     "processed_rations": 100.0,
	#     ...
	#   }
	# }
}

## Consumption rates: tier → resource → per-person-per-day
const CONSUMPTION_RATES = {
	"pioneers": {
		"compressed_gas": 2,
		"water": 1,
	},
	"colonists": {
		"processed_rations": 5,
		"compressed_gas": 3,
		"water": 1.5,
	},
	"technicians": {
		"power_cells": 3,
		"processed_rations": 5,
		"compressed_gas": 4,
	},
	"engineers": {
		"bio_circuit_boards": 2,
		"power_cells": 4,
		"processed_rations": 6,
	},
	"directors": {
		"warp_components": 1,
		"bio_circuit_boards": 3,
		"power_cells": 5,
	},
}

## Basic needs per tier (must be 100% for standard operation)
const BASIC_NEEDS = {
	"pioneers": ["compressed_gas", "water"],
	"colonists": ["processed_rations", "compressed_gas", "water"],
	"technicians": ["power_cells", "processed_rations", "compressed_gas"],
	"engineers": ["bio_circuit_boards", "power_cells", "processed_rations"],
	"directors": ["warp_components", "bio_circuit_boards", "power_cells"],
}

## Luxury needs per tier (must be 100% for tier advancement)
const LUXURY_NEEDS = {
	"pioneers": ["processed_rations"],
	"colonists": ["power_cells"],
	"technicians": ["bio_circuit_boards"],
	"engineers": ["warp_components"],
	"directors": [],
}

## Productivity multiplier lookup table: supply_pct → multiplier
const PRODUCTIVITY_MULTIPLIERS = {
	100: 1.00,
	75: 0.85,
	50: 0.65,
	25: 0.40,
	0: 0.15,
}


func _ready() -> void:
	# Initialize all planets with Pioneers tier
	for planet_id in ["a1", "planet_b", "planet_c"]:
		_init_planet(planet_id)


func _init_planet(planet_id: String) -> void:
	"""Initialize a planet with default Pioneers tier and 4 population."""
	population_data[planet_id] = {
		"tier": "pioneers",
		"population": {
			"pioneers": 4,
			"colonists": 0,
			"technicians": 0,
			"engineers": 0,
			"directors": 0,
		},
		"supply": {
			"compressed_gas": 100.0,
			"water": 100.0,
			"processed_rations": 100.0,
			"power_cells": 100.0,
			"bio_circuit_boards": 100.0,
			"warp_components": 100.0,
		},
		"tier_advance_timer": 0.0,  # Time spent with all luxury needs met
	}


# --- Tier Access ---

func get_tier(planet_id: String) -> String:
	"""Get current tier for a planet."""
	return population_data.get(planet_id, {}).get("tier", "pioneers")


func get_population_count(planet_id: String, tier: String) -> int:
	"""Get population count for a specific tier."""
	return population_data.get(planet_id, {}).get("population", {}).get(tier, 0)


func get_total_population(planet_id: String) -> int:
	"""Get total population across all tiers."""
	var total = 0
	for tier in TIER_SEQUENCE:
		total += get_population_count(planet_id, tier)
	return total


# --- Consumption & Supply ---

func get_consumption_rate(tier: String, resource: String) -> float:
	"""Get per-person-per-day consumption for a tier/resource pair."""
	return CONSUMPTION_RATES.get(tier, {}).get(resource, 0)


func get_daily_demand(planet_id: String, resource: String) -> float:
	"""Calculate total daily demand for a resource across all tiers."""
	var total = 0.0
	for tier in TIER_SEQUENCE:
		var pop_count = get_population_count(planet_id, tier)
		var per_person = get_consumption_rate(tier, resource)
		total += pop_count * per_person
	return total


func set_supply_percentage(planet_id: String, resource: String, pct: float) -> void:
	"""Set supply satisfaction % for a resource (0–100)."""
	if planet_id not in population_data:
		_init_planet(planet_id)
	population_data[planet_id]["supply"][resource] = clampf(pct, 0.0, 100.0)


func get_supply_percentage(planet_id: String, resource: String) -> float:
	"""Get supply satisfaction % for a resource."""
	return population_data.get(planet_id, {}).get("supply", {}).get(resource, 0.0)


func set_all_needs(planet_id: String, pct: float) -> void:
	"""Convenience: set all needs to a percentage (for testing)."""
	for resource in population_data[planet_id]["supply"].keys():
		population_data[planet_id]["supply"][resource] = pct


# --- Needs Lists ---

func get_basic_needs(tier: String) -> Array:
	"""Get list of basic needs for a tier."""
	return BASIC_NEEDS.get(tier, [])


func get_luxury_needs(tier: String) -> Array:
	"""Get list of luxury needs for a tier."""
	return LUXURY_NEEDS.get(tier, [])


# --- Productivity Multiplier ---

func get_productivity_multiplier(planet_id: String) -> float:
	"""Calculate productivity multiplier based on basic needs satisfaction.
	Uses the LOWEST basic need % to determine multiplier."""
	if planet_id not in population_data:
		return 1.0  # Uninitialised planet has no population → no unmet needs → full productivity
	var tier = get_tier(planet_id)
	var basic_needs = get_basic_needs(tier)

	if basic_needs.is_empty():
		return 1.0  # No basic needs = full productivity

	# Find lowest supply %
	var lowest_supply = 100.0
	for need in basic_needs:
		var supply = get_supply_percentage(planet_id, need)
		lowest_supply = minf(lowest_supply, supply)

	# Round to nearest 25% for lookup
	var rounded = roundi(lowest_supply / 25.0) * 25
	rounded = clampi(rounded, 0, 100)

	return PRODUCTIVITY_MULTIPLIERS.get(rounded, 0.15)


# --- Tier Advancement ---

func can_tier_advance(planet_id: String) -> bool:
	"""Check if a planet can tier advance (all luxury needs 100%)."""
	var tier = get_tier(planet_id)
	if tier == "directors":
		return false  # Max tier reached

	var luxury_needs = get_luxury_needs(tier)
	for need in luxury_needs:
		var supply = get_supply_percentage(planet_id, need)
		if supply < 100.0:
			return false

	return true


func advance_tier(planet_id: String) -> void:
	"""Advance a planet's tier to the next one."""
	var current_tier = get_tier(planet_id)
	var current_idx = TIER_SEQUENCE.find(current_tier)

	if current_idx < 0 or current_idx >= TIER_SEQUENCE.size() - 1:
		return  # Already at max tier

	var new_tier = TIER_SEQUENCE[current_idx + 1]
	population_data[planet_id]["tier"] = new_tier

	# Move all population to new tier (simplified: they all upgrade together)
	var old_pop = population_data[planet_id]["population"][current_tier]
	population_data[planet_id]["population"][current_tier] = 0
	population_data[planet_id]["population"][new_tier] = old_pop

	tier_advanced.emit(planet_id, current_tier, new_tier)


# --- Persistence ---

func get_save_data() -> Dictionary:
	"""Serialize consumption state for save file."""
	return {"population_data": population_data.duplicate(true)}


func load_save_data(data: Dictionary) -> void:
	"""Deserialize consumption state from save file."""
	if "population_data" in data:
		population_data = data["population_data"].duplicate(true)


func reset() -> void:
	"""Reset all planets to initial state (for testing)."""
	population_data.clear()
	for planet_id in ["a1", "planet_b", "planet_c"]:
		_init_planet(planet_id)
