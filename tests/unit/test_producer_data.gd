extends "res://tests/framework/test_case.gd"
## Unit tests for the ProducerData autoload. Validates catalogue lookups and
## upgrade scaling / stat modifier helpers.

func before_each() -> void:
	reset_game_state()


func test_get_drone_returns_entry() -> void:
	var d = ProducerData.get_drone("scout_drone")
	assert_false(d.is_empty())
	assert_has(d, "speed")
	assert_has(d, "carry_capacity")
	assert_has(d, "mine_time")


func test_get_drone_unknown_returns_empty_dict() -> void:
	assert_true(ProducerData.get_drone("no_such_drone").is_empty())


func test_get_upgrade_and_ship_part_lookups() -> void:
	var u = ProducerData.get_upgrade("cargo_pockets")
	assert_has(u, "cost")
	assert_true(ProducerData.get_upgrade("missing").is_empty())

	var p = ProducerData.get_ship_part("ion_drive")
	assert_has(p, "requires_rare")
	assert_true(ProducerData.get_ship_part("no_part").is_empty())


func test_shop_upgrades_tag_each_entry_with_id_and_cost() -> void:
	var upgrades = ProducerData.get_shop_upgrades()
	assert_gt(upgrades.size(), 0)
	for u in upgrades:
		assert_has(u, "id")
		assert_has(u, "actual_cost")
		assert_has(u, "can_purchase")


func test_shop_drones_tag_each_entry_with_id() -> void:
	var drones = ProducerData.get_shop_drones()
	assert_gt(drones.size(), 0)
	for d in drones:
		assert_has(d, "id")


func test_scaling_upgrade_cost_escalates_with_purchases() -> void:
	# First purchase: actual_cost == cost.
	var list_1 = ProducerData.get_shop_upgrades()
	var storage_exp_1 = _find_by_id(list_1, "storage_expansion")
	assert_not_null(storage_exp_1)
	assert_eq(storage_exp_1["actual_cost"], storage_exp_1["cost"])

	# Bump up a purchase and re-query: cost should double.
	GameState.purchased_upgrades["storage_expansion"] = 2
	var list_2 = ProducerData.get_shop_upgrades()
	var storage_exp_2 = _find_by_id(list_2, "storage_expansion")
	assert_eq(storage_exp_2["actual_cost"], storage_exp_2["cost"] * 4, "×2^2 after two levels")


func test_drone_drill_upgrade_reduces_mine_time() -> void:
	var base := 3.0
	assert_near(ProducerData.get_drone_mine_time(base), base, 0.001)
	GameState.purchased_upgrades["drone_drill_1"] = 2
	# 3.0 * 0.8^2 = 1.92
	assert_near(ProducerData.get_drone_mine_time(base), 3.0 * 0.64, 0.001)


func test_drone_cargo_rack_adds_capacity() -> void:
	assert_eq(ProducerData.get_drone_carry_capacity(3), 3)
	GameState.purchased_upgrades["drone_cargo_rack"] = 2
	assert_eq(ProducerData.get_drone_carry_capacity(3), 3 + 4)


func test_can_purchase_flips_off_when_maxed() -> void:
	# thruster_boots has max_purchases = 1
	GameState.purchased_upgrades["thruster_boots"] = 1
	var list = ProducerData.get_shop_upgrades()
	var tb = _find_by_id(list, "thruster_boots")
	assert_false(tb["can_purchase"])


func _find_by_id(arr: Array, id: String) -> Dictionary:
	for e in arr:
		if e.get("id") == id:
			return e
	return {}
