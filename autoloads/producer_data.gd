extends Node
## ProducerData — Data-driven definitions for all drones, upgrades, and shop items.
## Add new content here without touching game logic.

# --- Drone Definitions ---
# Key = drone_id, used to look up stats at runtime.

var drones: Dictionary = {
	"scout_drone": {
		"name": "Scout Drone",
		"description": "Tiny hovering mining bot. Slow but cheap.",
		"cost": 1,  # TODO: restore to 25 after testing
		"speed": 60.0,        # px/sec
		"carry_capacity": 3,
		"mine_time": 3.0,     # seconds to mine one charge
		"scene": "res://scenes/drones/scout_drone.tscn",
	},
	"heavy_drone": {
		"name": "Heavy Drone",
		"description": "Industrial armoured unit. Slow but hauls big loads.",
		"cost": 2,  # TODO: restore to 150 after testing
		"speed": 40.0,
		"carry_capacity": 10,
		"mine_time": 2.0,
		"scene": "res://scenes/drones/scout_drone.tscn",  # TODO: separate scene
	},
}

# --- Upgrade Definitions ---

var upgrades: Dictionary = {
	"drill_bit_mk2": {
		"name": "Drill Bit Mk.II",
		"description": "+50% manual mine speed",
		"cost": 1,  # TODO: restore to 50 after testing
		"category": "player",
		"max_purchases": 1,
	},
	"cargo_pockets": {
		"name": "Cargo Pockets",
		"description": "+5 ore inventory capacity",
		"cost": 1,  # TODO: restore to 75 after testing
		"category": "player",
		"max_purchases": 3,
	},
	"thruster_boots": {
		"name": "Thruster Boots",
		"description": "+20% movement speed",
		"cost": 1,  # TODO: restore to 60 after testing
		"category": "player",
		"max_purchases": 1,
	},
	"storage_expansion": {
		"name": "Storage Expansion",
		"description": "+25 pool capacity",
		"cost": 1,  # TODO: restore to 100 after testing
		"category": "outpost",
		"max_purchases": 5,
		"scales": true,
	},
	"drone_drill_1": {
		"name": "Drone Drill I",
		"description": "-20% drone mine time",
		"cost": 1,  # TODO: restore to 50 after testing
		"category": "drones",
		"max_purchases": 3,
		"bay_only": true,
	},
	"drone_cargo_rack": {
		"name": "Drone Cargo Rack",
		"description": "+2 drone carry capacity",
		"cost": 1,  # TODO: restore to 75 after testing
		"category": "drones",
		"max_purchases": 3,
		"bay_only": true,
	},
	"fleet_license": {
		"name": "Fleet License",
		"description": "+1 active drone slot",
		"cost": 1,  # TODO: restore to 100 after testing
		"category": "drones",
		"max_purchases": 10,
		"scales": true,
		"bay_only": true,  # Purchasable only at the Drone Bay
	},
	"auto_sell": {
		"name": "Auto-Sell",
		"description": "Pool auto-sells at 80% capacity",
		"cost": 2,  # TODO: restore to 500 after testing
		"category": "automation",
		"max_purchases": 1,
	},
}

# --- Shop Items (what appears in the shop terminal) ---
# Combines drones and upgrades into purchase categories

func get_shop_drones() -> Array:
	var result: Array = []
	for drone_id in drones:
		var d = drones[drone_id].duplicate()
		d["id"] = drone_id
		result.append(d)
	return result


func get_shop_upgrades() -> Array:
	var result: Array = []
	for upgrade_id in upgrades:
		var u = upgrades[upgrade_id].duplicate()
		u["id"] = upgrade_id
		# Calculate actual cost with scaling
		if u.has("scales") and u["scales"]:
			var times_bought = GameState.get_upgrade_count(upgrade_id)
			u["actual_cost"] = u["cost"] * int(pow(2, times_bought))
		else:
			u["actual_cost"] = u["cost"]
		# Check if maxed out
		u["can_purchase"] = GameState.get_upgrade_count(upgrade_id) < u.get("max_purchases", 1)
		result.append(u)
	return result


var ship_parts: Dictionary = {
	"hull_plating": {
		"name": "Hull Plating",
		"description": "Salvaged metal panels welded to the frame.",
		"requires_ore": 10,   # TODO: restore to 80 after testing
		"requires_rare": 0,
		"credits_cost": 0,
	},
	"ion_drive": {
		"name": "Engine Core",
		"description": "Krysite-powered plasma thruster for deep space.",
		"requires_ore": 0,
		"requires_rare": 5,   # TODO: restore to 30 after testing
		"credits_cost": 50,   # TODO: restore to 300 after testing
	},
	"navigation_core": {
		"name": "Nav Module",
		"description": "Star chart processor and gravitational scanner.",
		"requires_ore": 8,    # TODO: restore to 50 after testing
		"requires_rare": 3,   # TODO: restore to 20 after testing
		"credits_cost": 100,  # TODO: restore to 500 after testing
	},
	"fuel_cell": {
		"name": "Fuel Cell",
		"description": "Compressed krysite energy matrix for one jump.",
		"requires_ore": 12,   # TODO: restore to 60 after testing
		"requires_rare": 2,   # TODO: restore to 15 after testing
		"credits_cost": 0,
		"optional": true,  # Not required for first launch — shown dimmed in SHIP BAY
	},
}


func get_ship_part(part_id: String) -> Dictionary:
	if ship_parts.has(part_id):
		return ship_parts[part_id]
	return {}


func get_drone(drone_id: String) -> Dictionary:
	if drones.has(drone_id):
		return drones[drone_id]
	return {}


func get_upgrade(upgrade_id: String) -> Dictionary:
	if upgrades.has(upgrade_id):
		return upgrades[upgrade_id]
	return {}


# --- Drone stat modifiers (affected by upgrades) ---

func get_drone_mine_time(base_time: float) -> float:
	var drill_level = GameState.get_upgrade_count("drone_drill_1")
	return base_time * pow(0.8, drill_level)  # -20% per level


func get_drone_carry_capacity(base_carry: int) -> int:
	var rack_level = GameState.get_upgrade_count("drone_cargo_rack")
	return base_carry + (rack_level * 2)
