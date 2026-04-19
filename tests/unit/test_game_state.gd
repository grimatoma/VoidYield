extends "res://tests/framework/test_case.gd"
## Unit tests for the GameState autoload. Covers inventory, storage pool,
## selling, buying, crafting, upgrades, and drone bookkeeping. No UI or
## scene tree touched — everything runs directly against the singleton.

func before_each() -> void:
	reset_game_state()


# --- Inventory -------------------------------------------------------------

func test_add_to_inventory_respects_capacity() -> void:
	GameState.player_max_carry = 5
	var added_1 = GameState.add_to_inventory(3, "common")
	assert_eq(added_1, 3)
	assert_eq(GameState.player_carried_ore, 3)

	var added_2 = GameState.add_to_inventory(5, "common")
	assert_eq(added_2, 2, "should only accept 2 more before hitting capacity")
	assert_eq(GameState.player_carried_ore, 5)

	var added_3 = GameState.add_to_inventory(4, "common")
	assert_eq(added_3, 0, "should accept nothing once full")


func test_add_to_inventory_tracks_subtypes() -> void:
	GameState.player_max_carry = 10
	GameState.add_to_inventory(2, "common")
	GameState.add_to_inventory(3, "rare")
	GameState.add_to_inventory(1, "aethite")
	GameState.add_to_inventory(1, "voidstone")
	GameState.add_to_inventory(1, "shards")

	assert_eq(GameState.player_carried_ore, 8)
	assert_eq(GameState.player_rare_ore, 3)
	assert_eq(GameState.player_aethite, 1)
	assert_eq(GameState.player_voidstone, 1)
	assert_eq(GameState.player_carried_shards, 1)
	assert_eq(GameState.get_common_carried(), 2)
	assert_eq(GameState.get_carried_of("rare"), 3)


# --- Selling carried ore ---------------------------------------------------

func test_sell_resource_computes_credits_and_clears_subtype() -> void:
	GameState.player_max_carry = 10
	GameState.add_to_inventory(4, "rare")   # rare price = 5
	GameState.add_to_inventory(3, "common") # common price = 1

	var earned = GameState.sell_resource("rare", 4)
	assert_eq(earned, 20, "4 rare * 5 credits")
	assert_eq(GameState.player_rare_ore, 0)
	assert_eq(GameState.player_carried_ore, 3, "3 common left carried")
	assert_eq(GameState.credits, 20)


func test_sell_all_carried() -> void:
	GameState.player_max_carry = 20
	GameState.add_to_inventory(2, "common")
	GameState.add_to_inventory(2, "aethite")
	GameState.add_to_inventory(1, "voidstone")
	var earned = GameState.sell_all_carried()
	# 2*1 (common) + 2*8 (aethite) + 1*15 (voidstone) = 2 + 16 + 15 = 33
	assert_eq(earned, 33)
	assert_eq(GameState.player_carried_ore, 0)


func test_sell_resource_rejects_amount_zero_or_negative() -> void:
	GameState.player_max_carry = 5
	GameState.add_to_inventory(3, "common")
	assert_eq(GameState.sell_resource("common", 0), 0)
	assert_eq(GameState.sell_resource("common", -4), 0)
	assert_eq(GameState.player_carried_ore, 3, "inventory untouched")


# --- Storage pool ----------------------------------------------------------

func test_dump_inventory_to_storage_transfers_within_space() -> void:
	GameState.player_max_carry = 10
	GameState.storage_capacity = 10
	GameState.add_to_inventory(4, "common")
	GameState.add_to_inventory(3, "rare")
	GameState.storage_ore = 7   # only 3 slots left

	var moved = GameState.dump_inventory_to_storage()
	assert_eq(moved, 3)
	assert_eq(GameState.player_carried_ore, 4, "4 left in player")
	assert_eq(GameState.storage_ore, 10)


func test_buy_resource_to_storage_limited_by_credits_and_space() -> void:
	GameState.credits = 50
	GameState.storage_capacity = 20
	# Common buy price is 1 * 2.0 = 2 credits each. Space = 20. Request = 30.
	var bought = GameState.buy_resource_to_storage("common", 30)
	assert_eq(bought, 20, "capped by storage space")
	assert_eq(GameState.credits, 50 - 20 * 2)


func test_sell_all_ore_drains_pool_and_inventory() -> void:
	GameState.player_max_carry = 10
	GameState.storage_capacity = 50
	GameState.storage_ore = 8
	GameState.storage_rare_ore = 2
	GameState.add_to_inventory(3, "common")

	var earned = GameState.sell_all_ore()
	# Storage: 6 common + 2 rare = 6*1 + 2*5 = 16, Carried: 3 common = 3
	# sell_all_ore returns 19 (16 storage + 3 carried).
	# NOTE: credits end up at 22 because sell_all_carried→sell_resource adds
	# carried credits (3) to GameState.credits internally, then sell_all_ore
	# adds the full total_earned (19) again. This is a known double-count bug
	# tracked here so any fix triggers a deliberate test update.
	assert_eq(earned, 19)
	assert_eq(GameState.storage_ore, 0)
	assert_eq(GameState.player_carried_ore, 0)
	assert_eq(GameState.credits, 19, "sell_all_ore returns correct total without double-counting")


# --- Credits & upgrades ----------------------------------------------------

func test_spend_credits_rejects_when_insufficient() -> void:
	GameState.credits = 10
	assert_false(GameState.spend_credits(25))
	assert_eq(GameState.credits, 10)
	assert_true(GameState.spend_credits(9))
	assert_eq(GameState.credits, 1)


func test_purchase_upgrade_applies_effect() -> void:
	GameState.credits = 10
	var before_speed = GameState.player_move_speed
	assert_true(GameState.purchase_upgrade("thruster_boots"))
	assert_near(GameState.player_move_speed, before_speed * 1.2, 0.01)
	assert_true(GameState.has_upgrade("thruster_boots"))


func test_scaling_upgrade_doubles_cost_each_level() -> void:
	GameState.credits = 1000
	# storage_expansion base cost = 1, scales (×2 per level)
	assert_true(GameState.purchase_upgrade("storage_expansion"), "first")
	var after_first = GameState.credits
	# Cost of next level = 2
	assert_true(GameState.purchase_upgrade("storage_expansion"), "second")
	var spent_on_second = after_first - GameState.credits
	assert_eq(spent_on_second, 2, "second level costs 2")
	# Third level = 4
	var before_third = GameState.credits
	assert_true(GameState.purchase_upgrade("storage_expansion"), "third")
	assert_eq(before_third - GameState.credits, 4)


# --- Ship part crafting ----------------------------------------------------

func test_can_craft_ship_part_requires_materials_and_credits() -> void:
	# hull_plating: 40 scrap, 0 shards, 0 credits
	assert_false(GameState.can_craft_ship_part("hull_plating"), "no scrap")
	GameState.scrap_metal = 40
	assert_true(GameState.can_craft_ship_part("hull_plating"))


func test_craft_ship_part_consumes_materials() -> void:
	# ion_drive: 0 scrap, 20 shards, 300 credits
	GameState.storage_shards = 20
	GameState.credits = 500
	assert_true(GameState.craft_ship_part("ion_drive"))
	assert_eq(GameState.storage_shards, 0)
	assert_eq(GameState.credits, 200)
	assert_true(GameState.spaceship_parts_crafted["ion_drive"])


func test_is_ship_ready_requires_all_four_parts() -> void:
	assert_false(GameState.is_ship_ready())
	for part_id in GameState.spaceship_parts_crafted:
		GameState.spaceship_parts_crafted[part_id] = true
	assert_true(GameState.is_ship_ready())
	assert_eq(GameState.parts_built_count(), 4)


# --- Drone bookkeeping -----------------------------------------------------

func test_drone_deploy_limit() -> void:
	GameState.max_fleet_size = 2
	assert_true(GameState.can_deploy_drone())
	GameState.register_drone(Node2D.new())
	assert_true(GameState.can_deploy_drone())
	GameState.register_drone(Node2D.new())
	assert_false(GameState.can_deploy_drone(), "capped at max_fleet_size")


# --- Save / load roundtrip -------------------------------------------------

func test_save_and_load_roundtrips_state() -> void:
	GameState.credits = 1234
	GameState.player_max_carry = 17
	GameState.storage_ore = 9
	GameState.storage_rare_ore = 3
	GameState.spaceship_parts_crafted["hull_plating"] = true
	GameState.purchase_upgrade.bind("cargo_pockets")  # not actually calling — just data

	var data = GameState.get_save_data()
	reset_game_state()
	assert_eq(GameState.credits, 0, "state cleared before reload")

	GameState.load_save_data(data)
	assert_eq(GameState.credits, 1234)
	assert_eq(GameState.player_max_carry, 17)
	assert_eq(GameState.storage_ore, 9)
	assert_eq(GameState.storage_rare_ore, 3)
	assert_true(GameState.spaceship_parts_crafted["hull_plating"])


# --- Signal emission -------------------------------------------------------

func test_credits_changed_signal_fires_on_sale() -> void:
	var received: Array = []
	var handler := func(amt: int): received.append(amt)
	GameState.credits_changed.connect(handler)

	GameState.player_max_carry = 5
	GameState.add_to_inventory(2, "common")
	GameState.sell_all_carried()

	GameState.credits_changed.disconnect(handler)
	assert_gt(received.size(), 0, "expected at least one credits_changed emission")
	assert_eq(received.back(), GameState.credits)
