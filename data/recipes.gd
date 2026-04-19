extends Node
## All crafting recipes keyed by recipe_id.

const ALL: Dictionary = {
	# Tier 1 — Processing Plant (slot_cost=1)
	"smelt_vorax": {
		"name": "Smelt Vorax",
		"factory_tier": 1,
		"slot_cost": 1,
		"inputs": {"common": 5},
		"outputs": {"steel_bar": 1},
		"time": 8.0,
	},
	"smelt_krysite": {
		"name": "Smelt Krysite",
		"factory_tier": 1,
		"slot_cost": 1,
		"inputs": {"rare": 3},
		"outputs": {"krysite_ingot": 1},
		"time": 12.0,
	},
	"fuel_synthesis": {
		"name": "Synthesize Rocket Fuel",
		"factory_tier": 1,
		"slot_cost": 1,
		"inputs": {"compressed_gas": 20},
		"outputs": {"rocket_fuel": 10},
		"time": 5.0,
	},
	# Tier 2 — Fabricator (slot_cost=2)
	"craft_surveyor": {
		"name": "Craft Surveyor Unit",
		"factory_tier": 2,
		"slot_cost": 2,
		"inputs": {"steel_bar": 3, "krysite_ingot": 1},
		"outputs": {"surveyor_unit": 1},
		"time": 24.0,
	},
	"craft_fuel_cell": {
		"name": "Craft Fuel Cell",
		"factory_tier": 2,
		"slot_cost": 2,
		"inputs": {"krysite_ingot": 2, "steel_bar": 1},
		"outputs": {"fuel_cell": 1},
		"time": 18.0,
	},
	"craft_drone_frame": {
		"name": "Craft Drone Frame",
		"factory_tier": 2,
		"slot_cost": 2,
		"inputs": {"steel_bar": 5, "krysite_ingot": 1},
		"outputs": {"drone_frame": 1},
		"time": 30.0,
	},
	"craft_drill": {
		"name": "Craft Basic Drill",
		"factory_tier": 2,
		"slot_cost": 2,
		"inputs": {"steel_bar": 4, "common": 2},
		"outputs": {"basic_drill": 1},
		"time": 20.0,
	},
	# Tier 3 — Assembly Complex (slot_cost=3)
	"craft_harvester": {
		"name": "Assemble Harvester",
		"factory_tier": 3,
		"slot_cost": 3,
		"inputs": {"steel_bar": 8, "krysite_ingot": 2},
		"outputs": {"harvester_unit": 1},
		"time": 60.0,
	},
}
