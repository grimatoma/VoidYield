extends Node
## ProducerData — Loads all game data from JSON config files at startup.
## Public API is identical to the old hardcoded version; callers don't change.
##
## Data files:
##   res://data/drones.json      — drone catalogue
##   res://data/upgrades.json    — upgrade catalogue
##   res://data/ship_parts.json  — ship part recipes

var drones:     Dictionary = {}
var upgrades:   Dictionary = {}
var ship_parts: Dictionary = {}


func _ready() -> void:
	drones     = _load_json("res://data/drones.json")
	upgrades   = _load_json("res://data/upgrades.json")
	ship_parts = _load_json("res://data/ship_parts.json")

	if drones.is_empty() or upgrades.is_empty() or ship_parts.is_empty():
		push_error("[ProducerData] One or more data files failed to load — game data incomplete.")
	else:
		print("[ProducerData] Loaded %d drones, %d upgrades, %d ship parts." % [
			drones.size(), upgrades.size(), ship_parts.size()
		])


# --- Public API (unchanged from old version) ---------------------------------

func get_drone(drone_id: String) -> Dictionary:
	if drones.has(drone_id):
		return drones[drone_id].duplicate()
	return {}


func get_upgrade(upgrade_id: String) -> Dictionary:
	if upgrades.has(upgrade_id):
		return upgrades[upgrade_id].duplicate()
	return {}


func get_ship_part(part_id: String) -> Dictionary:
	if ship_parts.has(part_id):
		return ship_parts[part_id].duplicate()
	return {}


func get_shop_drones() -> Array:
	var result: Array = []
	for drone_id in drones:
		var d: Dictionary = drones[drone_id].duplicate()
		d["id"] = drone_id
		result.append(d)
	return result


func get_shop_upgrades() -> Array:
	var result: Array = []
	for upgrade_id in upgrades:
		var u: Dictionary = upgrades[upgrade_id].duplicate()
		u["id"] = upgrade_id
		# Calculate actual cost with scaling
		if u.get("scales", false):
			var times_bought: int = GameState.get_upgrade_count(upgrade_id)
			u["actual_cost"] = u["cost"] * int(pow(2, times_bought))
		else:
			u["actual_cost"] = u["cost"]
		# Check if maxed out
		u["can_purchase"] = GameState.get_upgrade_count(upgrade_id) < u.get("max_purchases", 1)
		result.append(u)
	return result


# --- Drone stat modifiers (affected by upgrades) ---

func get_drone_mine_time(base_time: float) -> float:
	var drill_level: int = GameState.get_upgrade_count("drone_drill_1")
	return base_time * pow(0.8, drill_level)  # -20% per level


func get_drone_carry_capacity(base_carry: int) -> int:
	var rack_level: int = GameState.get_upgrade_count("drone_cargo_rack")
	return base_carry + (rack_level * 2)


# --- Internal ----------------------------------------------------------------

func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("[ProducerData] Cannot open %s (error %s)" % [path, str(FileAccess.get_open_error())])
		return {}
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(text) != OK:
		push_error("[ProducerData] JSON parse error in %s at line %d: %s" % [
			path, json.get_error_line(), json.get_error_message()
		])
		return {}
	var data = json.data
	if not data is Dictionary:
		push_error("[ProducerData] %s root must be a JSON object." % path)
		return {}
	return data as Dictionary
