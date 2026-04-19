extends "res://tests/framework/test_case.gd"
## TDD unit tests for GameState.reset_to_defaults().
## RED → these tests define the contract; GREEN when the implementation satisfies them.

func before_each() -> void:
	reset_game_state()


# --- Credits & Economy -------------------------------------------------------

func test_reset_clears_credits() -> void:
	GameState.credits = 9999
	GameState.reset_to_defaults()
	assert_eq(GameState.credits, 0)


func test_reset_restores_default_carry_capacity() -> void:
	GameState.player_max_carry = 9999
	GameState.reset_to_defaults()
	assert_eq(GameState.player_max_carry, 15)


func test_reset_restores_default_move_speed() -> void:
	GameState.player_move_speed = 999.0
	GameState.reset_to_defaults()
	assert_near(GameState.player_move_speed, 120.0)


func test_reset_restores_default_mine_time() -> void:
	GameState.player_mine_time = 0.1
	GameState.reset_to_defaults()
	assert_near(GameState.player_mine_time, 1.5)


# --- Inventory ---------------------------------------------------------------

func test_reset_clears_all_carried_ore() -> void:
	GameState.player_max_carry      = 100
	GameState.player_carried_ore    = 80
	GameState.player_rare_ore       = 20
	GameState.player_aethite        = 20
	GameState.player_voidstone      = 20
	GameState.player_carried_shards = 20
	GameState.reset_to_defaults()
	assert_eq(GameState.player_carried_ore,    0, "total carried")
	assert_eq(GameState.player_rare_ore,       0, "rare carried")
	assert_eq(GameState.player_aethite,        0, "aethite carried")
	assert_eq(GameState.player_voidstone,      0, "voidstone carried")
	assert_eq(GameState.player_carried_shards, 0, "shards carried")


# --- Storage Pool ------------------------------------------------------------

func test_reset_clears_storage_pool() -> void:
	GameState.storage_ore       = 9999
	GameState.storage_capacity  = 9999
	GameState.storage_rare_ore  = 200
	GameState.storage_aethite   = 200
	GameState.storage_voidstone = 200
	GameState.storage_shards    = 200
	GameState.reset_to_defaults()
	assert_eq(GameState.storage_ore,       0,  "storage total")
	assert_eq(GameState.storage_capacity,  50, "default capacity")
	assert_eq(GameState.storage_rare_ore,  0,  "storage rare")
	assert_eq(GameState.storage_aethite,   0,  "storage aethite")
	assert_eq(GameState.storage_voidstone, 0,  "storage voidstone")
	assert_eq(GameState.storage_shards,    0,  "storage shards")


func test_reset_clears_scrap_metal() -> void:
	GameState.scrap_metal = 500
	GameState.reset_to_defaults()
	assert_eq(GameState.scrap_metal, 0)


# --- Upgrades & Progression --------------------------------------------------

func test_reset_clears_purchased_upgrades() -> void:
	GameState.purchased_upgrades = {"drill_bit_mk2": 1, "cargo_pockets": 2}
	GameState.reset_to_defaults()
	assert_eq(GameState.purchased_upgrades, {})


func test_reset_clears_all_ship_parts() -> void:
	for part_id in GameState.spaceship_parts_crafted:
		GameState.spaceship_parts_crafted[part_id] = true
	GameState.reset_to_defaults()
	for part_id in GameState.spaceship_parts_crafted:
		assert_false(GameState.spaceship_parts_crafted[part_id],
				"%s should be false after reset" % part_id)


func test_reset_restores_default_fleet_size() -> void:
	GameState.max_fleet_size     = 99
	GameState.active_drone_count = 7
	GameState.reset_to_defaults()
	assert_eq(GameState.max_fleet_size,     1, "default fleet = 1")
	assert_eq(GameState.active_drone_count, 0, "no active drones")


func test_reset_keeps_starting_buildings_only() -> void:
	GameState.constructed_buildings.append("extra_structure")
	GameState.reset_to_defaults()
	assert_eq(GameState.constructed_buildings.size(), 2,
			"only sell_terminal + shop_terminal")
	assert_has(GameState.constructed_buildings, "sell_terminal")
	assert_has(GameState.constructed_buildings, "shop_terminal")


func test_reset_restores_default_planet() -> void:
	GameState.current_planet = "planet_b"
	GameState.reset_to_defaults()
	assert_eq(GameState.current_planet, "asteroid_a1")


# --- Signal Emission ---------------------------------------------------------

func test_reset_emits_credits_changed_with_zero() -> void:
	var received: Array = []
	var handler := func(v: int): received.append(v)
	GameState.credits_changed.connect(handler)
	GameState.credits = 500
	GameState.reset_to_defaults()
	GameState.credits_changed.disconnect(handler)
	assert_true(received.size() > 0, "credits_changed should emit at least once")
	assert_eq(received.back(), 0, "last emission should be 0 credits")


func test_reset_emits_inventory_changed() -> void:
	var received: Array = []
	var handler := func(_c, _m): received.append(true)
	GameState.inventory_changed.connect(handler)
	GameState.player_max_carry = 100
	GameState.player_carried_ore = 50
	GameState.reset_to_defaults()
	GameState.inventory_changed.disconnect(handler)
	assert_true(received.size() > 0, "inventory_changed should emit")


func test_reset_emits_storage_changed() -> void:
	var received: Array = []
	var handler := func(_s, _c): received.append(true)
	GameState.storage_changed.connect(handler)
	GameState.storage_ore = 100
	GameState.reset_to_defaults()
	GameState.storage_changed.disconnect(handler)
	assert_true(received.size() > 0, "storage_changed should emit")


# --- Idempotency -------------------------------------------------------------

func test_reset_is_idempotent() -> void:
	## Calling reset twice should give the same result as calling it once.
	GameState.credits = 5000
	GameState.reset_to_defaults()
	GameState.reset_to_defaults()
	assert_eq(GameState.credits, 0)
	assert_eq(GameState.player_max_carry, 15)
	assert_eq(GameState.storage_capacity, 50)


# --- Integration: reset then save/load gives clean slate --------------------

func test_reset_then_get_save_data_gives_defaults() -> void:
	GameState.credits = 500
	GameState.player_max_carry = 9999
	GameState.reset_to_defaults()
	var data := GameState.get_save_data()
	assert_eq(data.get("credits"), 0)
	assert_eq(data.get("player_max_carry"), 15)
	assert_eq(data.get("storage_capacity"), 50)
	assert_eq(data.get("storage_ore"), 0)
