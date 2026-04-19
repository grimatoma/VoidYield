extends Node
## All crafting recipes keyed by recipe_id.

const ALL: Dictionary = {
	# === Tier 1 Processing Plant (slot_cost=1) ===
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
		"outputs": {"alloy_rod": 1},
		"time": 12.0,
	},
	"compress_gas": {
		"name": "Compress Gas",
		"factory_tier": 1,
		"slot_cost": 1,
		"inputs": {"raw_gas": 10},
		"outputs": {"compressed_gas": 1},
		"time": 10.0,
	},
	"fuel_synthesis": {
		"name": "Synthesize Fuel",
		"factory_tier": 1,
		"slot_cost": 1,
		"inputs": {"compressed_gas": 20},
		"outputs": {"rocket_fuel": 10},
		"time": 5.0,
	},
	"bio_extract": {
		"name": "Extract Bio-Resin",
		"factory_tier": 1,
		"slot_cost": 1,
		"inputs": {"bio_matter": 8},
		"outputs": {"processed_resin": 2},
		"time": 6.0,
	},
	"synthesize_rations": {
		"name": "Synthesize Rations",
		"factory_tier": 1,
		"slot_cost": 1,
		"inputs": {"processed_resin": 5},
		"outputs": {"processed_rations": 3},
		"time": 4.0,
	},

	# === Tier 2 Fabricator (slot_cost=2) ===
	"craft_surveyor": {
		"name": "Craft Surveyor Unit",
		"factory_tier": 2,
		"slot_cost": 2,
		"inputs": {"steel_bar": 4, "crystal_lattice": 2},
		"outputs": {"surveyor_unit": 1},
		"time": 20.0,
	},
	"craft_fuel_cell": {
		"name": "Craft Fuel Cell",
		"factory_tier": 2,
		"slot_cost": 2,
		"inputs": {"alloy_rod": 3, "crystal_lattice": 1},
		"outputs": {"fuel_cell": 2},
		"time": 15.0,
	},
	"craft_drone_frame": {
		"name": "Craft Drone Frame",
		"factory_tier": 2,
		"slot_cost": 2,
		"inputs": {"steel_bar": 8, "alloy_rod": 4},
		"outputs": {"drone_frame": 1},
		"time": 25.0,
	},
	"craft_bio_circuit": {
		"name": "Craft Bio-Circuit Board",
		"factory_tier": 2,
		"slot_cost": 2,
		"inputs": {"alloy_rod": 3, "processed_resin": 4},
		"outputs": {"bio_circuit_board": 1},
		"time": 18.0,
	},

	# === Tier 3 Assembly Complex (slot_cost=3) ===
	"craft_harvester": {
		"name": "Assemble Harvester",
		"factory_tier": 3,
		"slot_cost": 3,
		"inputs": {"steel_bar": 8, "alloy_rod": 6, "crystal_lattice": 2},
		"outputs": {"harvester_unit": 1},
		"time": 60.0,
	},
}
