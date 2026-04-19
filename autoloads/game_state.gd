extends Node
## GameState — Central singleton for all game variables and signals.
## Every system reads/writes state through here. UI connects to signals, never polls.

# --- Signals ---
signal credits_changed(new_amount: int)
signal inventory_changed(carried: int, max_carry: int)
signal ore_sold(amount: int, credits_earned: int)
signal upgrade_purchased(upgrade_id: String)
signal drone_deployed(drone: Node2D)
signal drone_returned(drone: Node2D, ore_carried: int)
signal building_constructed(building_id: String)
signal interaction_target_changed(target: Node2D)
signal materials_changed(scrap: int, shards: int)
signal ship_part_crafted(part_id: String)
signal storage_changed(stored: int, capacity: int)
signal planet_unlocked(planet_id: String)

# --- Player Stats ---
var player_move_speed: float = 120.0
var player_max_carry: int = 15
var player_mine_time: float = 1.5  # seconds per mine action

# --- Inventory (player carried) — all types share player_max_carry ---
# player_carried_ore is the TOTAL across all types (used for capacity)
var player_carried_ore: int = 0
var player_rare_ore: int = 0
var player_aethite: int = 0
var player_voidstone: int = 0
var player_carried_shards: int = 0

# --- Sell Prices ---
var ore_prices: Dictionary = {
	"common": 2,
	"rare": 5,
	"aethite": 8,
	"voidstone": 15,
	"shards": 3,
}

# --- Economy ---
var credits: int = 0

# --- Storage Depot ---
var storage_ore: int = 0
var storage_capacity: int = 50
var storage_rare_ore: int = 0
var storage_aethite: int = 0
var storage_voidstone: int = 0
var storage_shards: int = 0

# --- Crafting Materials ---
var scrap_metal: int = 0

# --- Spaceship Parts ---
var spaceship_parts_crafted: Dictionary = {
	"hull_plating": false,
	"ion_drive": false,
	"navigation_core": false,
	"fuel_cell": false,
}

# --- Planet / World ---
var current_planet: String = "asteroid_a1"
var planet_a_spawn: Vector2 = Vector2(280, 420)
## Planets the player can travel to. A1 + A2 accessible from the start.
var unlocked_planets: Array[String] = ["asteroid_a1", "planet_b"]
## Planets the player has physically visited (used for unlock conditions).
var visited_planets: Array[String] = []

# --- Drones ---
var max_fleet_size: int = 1
var active_drone_count: int = 0

# --- Upgrades Purchased ---
var purchased_upgrades: Dictionary = {}

# --- Buildings Constructed ---
var constructed_buildings: Array[String] = ["sell_terminal", "shop_terminal"]

# --- Tech Tree ---
var research_points: float = 0.0
var unlocked_tech_nodes: Array[String] = []

# --- Survey Tool ---
var survey_tool_tier: int = 1  # Tier I (30px, ±15%), II (60px, ±5%), III (120px, ±1%)

# --- Debug ---
var debug_click_mode: bool = true  # Click any interactable to trigger it instantly

# --- Current interaction target ---
var current_interaction_target: Node2D = null


func _ready() -> void:
	# Wire tech tree unlocks to survey tool tier advancement
	if TechTree:
		TechTree.node_unlocked.connect(_on_tech_node_unlocked)


# --- Inventory (player carried ore) ---

func get_common_carried() -> int:
	return player_carried_ore - player_rare_ore - player_aethite - player_voidstone - player_carried_shards


func get_carried_of(resource_type: String) -> int:
	match resource_type:
		"rare":      return player_rare_ore
		"aethite":   return player_aethite
		"voidstone": return player_voidstone
		"shards":    return player_carried_shards
		_:           return get_common_carried()


func add_to_inventory(amount: int, ore_type: String = "common") -> int:
	## Adds a resource of a specific type. Returns the amount actually added.
	## All types share player_max_carry capacity.
	var space = player_max_carry - player_carried_ore
	var actually_added = mini(amount, space)
	if actually_added > 0:
		player_carried_ore += actually_added
		match ore_type:
			"rare":      player_rare_ore       += actually_added
			"aethite":   player_aethite        += actually_added
			"voidstone": player_voidstone      += actually_added
			"shards":
				player_carried_shards += actually_added
				materials_changed.emit(scrap_metal, player_carried_shards)
		inventory_changed.emit(player_carried_ore, player_max_carry)
	return actually_added


func has_inventory_space() -> bool:
	return player_carried_ore < player_max_carry


# --- Selling ---

func sell_resource(resource_type: String, amount: int) -> int:
	## Sells up to `amount` of `resource_type` from the player's inventory.
	## Returns credits earned (0 if nothing to sell).
	if amount <= 0:
		return 0
	var available = get_carried_of(resource_type)
	var to_sell = mini(amount, available)
	if to_sell <= 0:
		return 0

	var price = ore_prices.get(resource_type, 1)
	var earned = to_sell * price

	match resource_type:
		"rare":      player_rare_ore       -= to_sell
		"aethite":   player_aethite        -= to_sell
		"voidstone": player_voidstone      -= to_sell
		"shards":    player_carried_shards -= to_sell
		# "common" — no subset to subtract; only total decreases
	player_carried_ore -= to_sell
	credits += earned

	inventory_changed.emit(player_carried_ore, player_max_carry)
	credits_changed.emit(credits)
	ore_sold.emit(to_sell, earned)
	EventLog.add("Sold %d ore for %d CR" % [to_sell, earned], "SHOP")
	if resource_type == "shards":
		materials_changed.emit(scrap_metal, player_carried_shards)
	return earned


func sell_all_carried() -> int:
	var total = 0
	for t in ["common", "rare", "aethite", "voidstone", "shards"]:
		total += sell_resource(t, get_carried_of(t))
	return total


# --- Per-resource buy / sell (storage pool) ---
# Used by the Shop Terminal "RESOURCES" tab so the player can trade individual
# ore types in/out of the depot pool with credits.

const RESOURCE_BUY_MARKUP: float = 2.0  # buying costs 2x the sell price


func get_storage_of(resource_type: String) -> int:
	match resource_type:
		"rare":      return storage_rare_ore
		"aethite":   return storage_aethite
		"voidstone": return storage_voidstone
		"shards":    return storage_shards
		_:           return storage_ore - storage_rare_ore - storage_aethite - storage_voidstone - storage_shards


func get_resource_sell_price(resource_type: String) -> int:
	return ore_prices.get(resource_type, 1)


func get_resource_buy_price(resource_type: String) -> int:
	return int(ceil(ore_prices.get(resource_type, 1) * RESOURCE_BUY_MARKUP))


func sell_from_storage(resource_type: String, amount: int) -> int:
	## Sells up to `amount` of `resource_type` directly from the depot pool.
	## Returns credits earned.
	if amount <= 0:
		return 0
	var available = get_storage_of(resource_type)
	var to_sell = mini(amount, available)
	if to_sell <= 0:
		return 0

	var earned = to_sell * get_resource_sell_price(resource_type)

	match resource_type:
		"rare":      storage_rare_ore  -= to_sell
		"aethite":   storage_aethite   -= to_sell
		"voidstone": storage_voidstone -= to_sell
		"shards":    storage_shards    -= to_sell
	storage_ore -= to_sell
	credits += earned

	storage_changed.emit(storage_ore, storage_capacity)
	credits_changed.emit(credits)
	ore_sold.emit(to_sell, earned)
	EventLog.add("Sold %d ore for %d CR" % [to_sell, earned], "SHOP")
	return earned


func buy_resource_to_storage(resource_type: String, amount: int) -> int:
	## Spends credits to deposit `amount` of `resource_type` into the depot pool.
	## Returns the amount actually purchased (clamped by credits & storage space).
	if amount <= 0:
		return 0
	var price = get_resource_buy_price(resource_type)
	if price <= 0:
		return 0
	var space = storage_capacity - storage_ore
	if space <= 0:
		return 0
	var max_affordable = credits / price
	var to_buy = mini(mini(amount, space), max_affordable)
	if to_buy <= 0:
		return 0

	var cost = to_buy * price
	credits -= cost
	storage_ore += to_buy
	match resource_type:
		"rare":      storage_rare_ore  += to_buy
		"aethite":   storage_aethite   += to_buy
		"voidstone": storage_voidstone += to_buy
		"shards":    storage_shards    += to_buy

	storage_changed.emit(storage_ore, storage_capacity)
	credits_changed.emit(credits)
	return to_buy


# --- Storage Pool (depot) ---

func is_storage_full() -> bool:
	return storage_ore >= storage_capacity


func deposit_to_storage(amount: int, ore_type: String = "common") -> int:
	## Deposits `amount` of `ore_type` into the depot storage pool (e.g., from a drone).
	## Returns the amount actually deposited.
	if amount <= 0:
		return 0
	var space = storage_capacity - storage_ore
	var to_deposit = mini(amount, space)
	if to_deposit <= 0:
		return 0

	storage_ore += to_deposit
	match ore_type:
		"rare":      storage_rare_ore  += to_deposit
		"aethite":   storage_aethite   += to_deposit
		"voidstone": storage_voidstone += to_deposit
		"shards":    storage_shards    += to_deposit
		# "common" — no subset; only total increases

	storage_changed.emit(storage_ore, storage_capacity)
	return to_deposit


func dump_inventory_to_storage() -> int:
	## Transfers all carried ore into the depot storage pool.
	## Returns the amount actually deposited.
	var space = storage_capacity - storage_ore
	var to_deposit = mini(player_carried_ore, space)
	if to_deposit <= 0:
		return 0

	# Transfer subsets proportionally (deposit what we can)
	var common_carried = get_common_carried()
	var common_to_deposit = mini(common_carried, to_deposit)
	var remaining = to_deposit - common_to_deposit

	# Deposit rare types up to whatever room is left
	var rare_to_deposit = mini(player_rare_ore, remaining)
	remaining -= rare_to_deposit
	var aethite_to_deposit = mini(player_aethite, remaining)
	remaining -= aethite_to_deposit
	var voidstone_to_deposit = mini(player_voidstone, remaining)
	remaining -= voidstone_to_deposit
	var shards_to_deposit = mini(player_carried_shards, remaining)

	# Update storage
	storage_ore += to_deposit
	storage_rare_ore += rare_to_deposit
	storage_aethite += aethite_to_deposit
	storage_voidstone += voidstone_to_deposit
	storage_shards += shards_to_deposit

	# Update player inventory
	player_carried_ore -= to_deposit
	player_rare_ore -= rare_to_deposit
	player_aethite -= aethite_to_deposit
	player_voidstone -= voidstone_to_deposit
	player_carried_shards -= shards_to_deposit

	inventory_changed.emit(player_carried_ore, player_max_carry)
	storage_changed.emit(storage_ore, storage_capacity)
	if shards_to_deposit > 0:
		materials_changed.emit(scrap_metal, player_carried_shards)
	return to_deposit


func sell_all_ore() -> int:
	## Sells everything in the storage pool + player inventory.
	## Returns total credits earned (storage + carried).
	var carried_earned = sell_all_carried()  # Sell carried first (adds credits directly)

	var total_earned: int = carried_earned

	# Then sell from storage pool
	var common_stored = storage_ore - storage_rare_ore - storage_aethite - storage_voidstone - storage_shards
	if common_stored > 0:
		total_earned += common_stored * ore_prices.get("common", 1)
	if storage_rare_ore > 0:
		total_earned += storage_rare_ore * ore_prices.get("rare", 5)
	if storage_aethite > 0:
		total_earned += storage_aethite * ore_prices.get("aethite", 8)
	if storage_voidstone > 0:
		total_earned += storage_voidstone * ore_prices.get("voidstone", 15)
	if storage_shards > 0:
		total_earned += storage_shards * ore_prices.get("shards", 3)

	var had_storage = storage_ore > 0
	var had_carried = carried_earned > 0
	storage_ore = 0
	storage_rare_ore = 0
	storage_aethite = 0
	storage_voidstone = 0
	storage_shards = 0

	var storage_earned = total_earned - carried_earned
	if storage_earned > 0:
		credits += storage_earned
		credits_changed.emit(credits)
		ore_sold.emit(storage_earned, storage_earned)
		EventLog.add("Sold %d ore for %d CR" % [storage_earned, storage_earned], "SHOP")
	if had_storage:
		storage_changed.emit(storage_ore, storage_capacity)
	if had_carried:
		inventory_changed.emit(player_carried_ore, player_max_carry)
	return total_earned



# --- Credits ---

func can_afford(cost: int) -> bool:
	return credits >= cost


func spend_credits(cost: int) -> bool:
	if credits >= cost:
		credits -= cost
		credits_changed.emit(credits)
		return true
	return false



# --- Crafting Materials ---

func add_material(mat_type: String, amount: int) -> void:
	match mat_type:
		"scrap_metal": scrap_metal += amount
	materials_changed.emit(scrap_metal, player_carried_shards)


# --- Spaceship Parts ---

func can_craft_ship_part(part_id: String) -> bool:
	if spaceship_parts_crafted.get(part_id, false):
		return false  # already crafted
	var part = ProducerData.get_ship_part(part_id)
	if part.is_empty():
		return false
	if credits      < part.get("credits_cost",    0): return false
	if scrap_metal  < part.get("requires_scrap",  0): return false
	if storage_shards < part.get("requires_shards", 0): return false
	return true


func craft_ship_part(part_id: String) -> bool:
	if not can_craft_ship_part(part_id):
		return false
	var part = ProducerData.get_ship_part(part_id)
	spend_credits(part.get("credits_cost", 0))
	var scrap_cost  = part.get("requires_scrap",  0)
	var shards_cost = part.get("requires_shards", 0)

	scrap_metal    -= scrap_cost
	storage_shards -= shards_cost
	if shards_cost > 0:
		storage_ore -= shards_cost  # shards are a subset of storage_ore total

	spaceship_parts_crafted[part_id] = true
	materials_changed.emit(scrap_metal, player_carried_shards)
	if shards_cost > 0:
		storage_changed.emit(storage_ore, storage_capacity)
	ship_part_crafted.emit(part_id)
	return true


func is_ship_ready() -> bool:
	for part_id in spaceship_parts_crafted:
		if not spaceship_parts_crafted[part_id]:
			return false
	return true


func parts_built_count() -> int:
	var count = 0
	for part_id in spaceship_parts_crafted:
		if spaceship_parts_crafted[part_id]:
			count += 1
	return count


# --- Upgrades ---

func purchase_upgrade(upgrade_id: String) -> bool:
	var upgrade = ProducerData.get_upgrade(upgrade_id)
	if upgrade.is_empty():
		return false

	var cost = upgrade.get("cost", 0)
	if upgrade.has("scales"):
		var times_bought = purchased_upgrades.get(upgrade_id, 0)
		cost = cost * int(pow(2, times_bought))

	if not spend_credits(cost):
		return false

	purchased_upgrades[upgrade_id] = purchased_upgrades.get(upgrade_id, 0) + 1
	_apply_upgrade(upgrade_id, upgrade)
	upgrade_purchased.emit(upgrade_id)
	EventLog.add("Purchased %s" % upgrade.get("name", upgrade_id), "SHOP")
	return true


func _apply_upgrade(upgrade_id: String, _upgrade: Dictionary) -> void:
	match upgrade_id:
		"drill_bit_mk2":
			player_mine_time *= 0.5
		"cargo_pockets":
			player_max_carry += 5
			inventory_changed.emit(player_carried_ore, player_max_carry)
		"thruster_boots":
			player_move_speed *= 1.2
		"fleet_license":
			max_fleet_size += 1
		"storage_expansion":
			storage_capacity += 25
			storage_changed.emit(storage_ore, storage_capacity)
		"drone_drill_1", "drone_cargo_rack":
			pass


func has_upgrade(upgrade_id: String) -> bool:
	return purchased_upgrades.has(upgrade_id)


func get_upgrade_count(upgrade_id: String) -> int:
	return purchased_upgrades.get(upgrade_id, 0)


# --- Drones ---

func can_deploy_drone() -> bool:
	return active_drone_count < max_fleet_size


func register_drone(drone: Node2D) -> void:
	active_drone_count += 1
	drone_deployed.emit(drone)
	EventLog.add("Drone deployed", "DRONE")


func unregister_drone(_drone: Node2D) -> void:
	active_drone_count -= 1


func on_drone_returned(drone: Node2D, ore_carried: int) -> void:
	drone_returned.emit(drone, ore_carried)
	EventLog.add("Drone returned with %d ore" % ore_carried, "DRONE")


func despawn_all_drones() -> void:
	## Called before a planet transition — clears drone count and removes nodes.
	for drone in get_tree().get_nodes_in_group("drones"):
		drone.queue_free()
	active_drone_count = 0


# --- Buildings ---

func is_building_constructed(building_id: String) -> bool:
	return building_id in constructed_buildings


func construct_building(building_id: String) -> void:
	if building_id not in constructed_buildings:
		constructed_buildings.append(building_id)
		building_constructed.emit(building_id)
		EventLog.add("Building constructed: %s" % building_id, "BUILD")


# --- Survey Tool Tier System ---

func get_survey_tool_tier() -> int:
	"""Get current Survey Tool tier (1, 2, or 3)."""
	return survey_tool_tier


func get_survey_range(tier: int) -> int:
	"""Get scan range in pixels for a tier."""
	match tier:
		1: return 30
		2: return 60
		3: return 120
		_: return 30


func get_survey_precision(tier: int) -> float:
	"""Get precision (as ±% decimal) for a tier."""
	match tier:
		1: return 0.15
		2: return 0.05
		3: return 0.01
		_: return 0.15


func can_deep_scan() -> bool:
	"""Can perform Deep Scan (15s hold to reveal 3 top attributes) at Tier II+."""
	return survey_tool_tier >= 2


func survey_shows_all_attributes() -> bool:
	"""Shows all 11 attributes at Tier III."""
	return survey_tool_tier >= 3


func _on_tech_node_unlocked(node_id: String) -> void:
	"""Called when a tech tree node is unlocked."""
	match node_id:
		"3.S":  # Survey Tool Mk.II
			survey_tool_tier = maxf(survey_tool_tier, 2)
		"3.T":  # Survey Tool Mk.III
			survey_tool_tier = maxf(survey_tool_tier, 3)


# --- Save / Load ---

func get_save_data() -> Dictionary:
	return {
		"credits": credits,
		"player_carried_ore": player_carried_ore,
		"player_rare_ore": player_rare_ore,
		"player_aethite": player_aethite,
		"player_voidstone": player_voidstone,
		"player_carried_shards": player_carried_shards,
		"player_max_carry": player_max_carry,
		"player_move_speed": player_move_speed,
		"player_mine_time": player_mine_time,
		"storage_ore": storage_ore,
		"storage_capacity": storage_capacity,
		"storage_rare_ore": storage_rare_ore,
		"storage_aethite": storage_aethite,
		"storage_voidstone": storage_voidstone,
		"storage_shards": storage_shards,
		"scrap_metal": scrap_metal,
		"spaceship_parts_crafted": spaceship_parts_crafted.duplicate(),
		"current_planet": current_planet,
		"max_fleet_size": max_fleet_size,
		"purchased_upgrades": purchased_upgrades,
		"constructed_buildings": constructed_buildings,
		"unlocked_planets": unlocked_planets.duplicate(),
		"visited_planets": visited_planets.duplicate(),
		"survey_tool_tier": survey_tool_tier,
		"tech_tree": TechTree.get_save_data(),
	}


func load_save_data(data: Dictionary) -> void:
	credits               = data.get("credits", 0)
	player_carried_ore    = data.get("player_carried_ore", 0)
	player_rare_ore       = data.get("player_rare_ore", 0)
	player_aethite        = data.get("player_aethite", 0)
	player_voidstone      = data.get("player_voidstone", 0)
	player_carried_shards = data.get("player_carried_shards", 0)
	player_max_carry      = data.get("player_max_carry", 10)
	player_move_speed     = data.get("player_move_speed", 120.0)
	player_mine_time      = data.get("player_mine_time", 1.5)
	storage_ore           = data.get("storage_ore", 0)
	storage_capacity      = data.get("storage_capacity", 50)
	storage_rare_ore      = data.get("storage_rare_ore", 0)
	storage_aethite       = data.get("storage_aethite", 0)
	storage_voidstone     = data.get("storage_voidstone", 0)
	storage_shards        = data.get("storage_shards", 0)
	scrap_metal           = data.get("scrap_metal", 0)
	current_planet        = data.get("current_planet", "asteroid_a1")
	max_fleet_size        = data.get("max_fleet_size", 1)
	purchased_upgrades    = data.get("purchased_upgrades", {})
	research_points       = data.get("research_points", 0.0)
	survey_tool_tier      = data.get("survey_tool_tier", 1)

	var raw_unlocked = data.get("unlocked_planets", ["asteroid_a1", "planet_b"])
	unlocked_planets.clear()
	for p in raw_unlocked:
		unlocked_planets.append(str(p))

	var raw_visited = data.get("visited_planets", [])
	visited_planets.clear()
	for p in raw_visited:
		visited_planets.append(str(p))

	var raw_tech_nodes = data.get("unlocked_tech_nodes", [])
	unlocked_tech_nodes.clear()
	for node_id in raw_tech_nodes:
		unlocked_tech_nodes.append(str(node_id))

	var raw_parts = data.get("spaceship_parts_crafted", {})
	for part_id in spaceship_parts_crafted:
		spaceship_parts_crafted[part_id] = raw_parts.get(part_id, false)

	var raw_buildings = data.get("constructed_buildings", ["sell_terminal", "shop_terminal"])
	constructed_buildings.clear()
	for b in raw_buildings:
		constructed_buildings.append(str(b))

	var raw_tech_tree = data.get("tech_tree", {})
	TechTree.load_save_data(raw_tech_tree)

	credits_changed.emit(credits)
	inventory_changed.emit(player_carried_ore, player_max_carry)
	storage_changed.emit(storage_ore, storage_capacity)
	materials_changed.emit(scrap_metal, player_carried_shards)
	interaction_target_changed.emit(current_interaction_target)


# --- Planet Unlock ---

func on_planet_visited(planet_id: String) -> void:
	## Call this when the player successfully travels to a planet.
	## Records the visit and triggers any unlock checks.
	if planet_id not in visited_planets:
		visited_planets.append(planet_id)
	# Check if visiting this planet unlocks anything
	try_unlock_planet("unknown_a3")


func try_unlock_planet(planet_id: String) -> bool:
	## Checks unlock conditions for planet_id. Unlocks and emits signal if met.
	## Returns true if the planet was newly unlocked, false otherwise.
	if planet_id in unlocked_planets:
		return false  # already unlocked
	var can_unlock := false
	match planet_id:
		"unknown_a3":
			can_unlock = "planet_b" in visited_planets
	if can_unlock:
		unlocked_planets.append(planet_id)
		planet_unlocked.emit(planet_id)
		return true
	return false


func launch_to_planet_b() -> void:
	current_planet = "planet_b"
	print("[GameState] Launching to Planet B.")
	get_tree().change_scene_to_file("res://scenes/planet_b/planet_b.tscn")


func reset_to_defaults() -> void:
	## Resets all runtime state to fresh-game values. Called by "New Game" on the main menu.
	player_move_speed     = 120.0
	player_max_carry      = 15
	player_mine_time      = 1.5
	player_carried_ore    = 0
	player_rare_ore       = 0
	player_aethite        = 0
	player_voidstone      = 0
	player_carried_shards = 0
	credits               = 0
	storage_ore           = 0
	storage_capacity      = 50
	storage_rare_ore      = 0
	storage_aethite       = 0
	storage_voidstone     = 0
	storage_shards        = 0
	scrap_metal           = 0
	current_planet        = "asteroid_a1"
	max_fleet_size        = 1
	active_drone_count    = 0
	purchased_upgrades    = {}
	constructed_buildings = ["sell_terminal", "shop_terminal"]
	research_points       = 0.0
	unlocked_tech_nodes   = []
	survey_tool_tier      = 1
	for part_id in spaceship_parts_crafted:
		spaceship_parts_crafted[part_id] = false
	unlocked_planets = ["asteroid_a1", "planet_b"]
	visited_planets  = []

	credits_changed.emit(credits)
	inventory_changed.emit(player_carried_ore, player_max_carry)
	storage_changed.emit(storage_ore, storage_capacity)
	materials_changed.emit(scrap_metal, player_carried_shards)


func debug_fill_resources() -> void:
	## Fills resources for testing purposes.
	player_max_carry = 10000
	player_rare_ore = 1000
	player_aethite = 1000
	player_voidstone = 1000
	player_carried_shards = 1000
	player_carried_ore = 5000

	storage_capacity = 10000
	storage_ore = 5000
	storage_rare_ore = 1000
	storage_aethite = 1000
	storage_voidstone = 1000
	storage_shards = 1000

	credits = 5000
	scrap_metal = 500
	max_fleet_size = 5

	credits_changed.emit(credits)
	inventory_changed.emit(player_carried_ore, player_max_carry)
	storage_changed.emit(storage_ore, storage_capacity)
	materials_changed.emit(scrap_metal, player_carried_shards)

	print("[DEBUG] Resources filled: %d ore, %d credits" % [player_carried_ore, credits])
