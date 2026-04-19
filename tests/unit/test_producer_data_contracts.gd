extends "res://tests/framework/test_case.gd"
## TDD tests for ProducerData data contracts.
## RED tests marked below FAIL until JSON migration + real values are in place.

func before_each() -> void:
	reset_game_state()


# --- Drone data contract -----------------------------------------------------

func test_all_drones_have_required_fields() -> void:
	for d in ProducerData.get_shop_drones():
		var id: String = d.get("id", "?")
		assert_has(d, "name",          "%s missing name" % id)
		assert_has(d, "cost",          "%s missing cost" % id)
		assert_has(d, "speed",         "%s missing speed" % id)
		assert_has(d, "carry_capacity","%s missing carry_capacity" % id)
		assert_has(d, "mine_time",     "%s missing mine_time" % id)
		assert_has(d, "scene",         "%s missing scene path" % id)


func test_heavy_drone_uses_distinct_scene() -> void:
	## RED until heavy_drone.tscn exists and JSON is updated.
	var scout := ProducerData.get_drone("scout_drone")
	var heavy := ProducerData.get_drone("heavy_drone")
	assert_ne(scout.get("scene", ""), heavy.get("scene", ""),
			"heavy_drone must reference its own scene, not scout_drone.tscn")


func test_scout_drone_cost_is_real_value() -> void:
	## RED until JSON uses real costs (was 1 in test-mode).
	var d := ProducerData.get_drone("scout_drone")
	assert_ge(d.get("cost", 0), 20, "scout_drone cost should be ≥ 20 credits")


func test_heavy_drone_cost_exceeds_scout() -> void:
	## RED until JSON uses real costs.
	var scout := ProducerData.get_drone("scout_drone")
	var heavy := ProducerData.get_drone("heavy_drone")
	assert_gt(heavy.get("cost", 0), scout.get("cost", 0),
			"heavy drone should cost more than scout")


func test_heavy_drone_carry_capacity_exceeds_scout() -> void:
	var scout := ProducerData.get_drone("scout_drone")
	var heavy := ProducerData.get_drone("heavy_drone")
	assert_gt(heavy.get("carry_capacity", 0), scout.get("carry_capacity", 0),
			"heavy should carry more than scout")


# --- Upgrade data contract ---------------------------------------------------

func test_all_upgrades_have_required_fields() -> void:
	for u in ProducerData.get_shop_upgrades():
		var id: String = u.get("id", "?")
		assert_has(u, "name",        "%s missing name" % id)
		assert_has(u, "description", "%s missing description" % id)
		assert_has(u, "cost",        "%s missing cost" % id)
		assert_has(u, "category",    "%s missing category" % id)
		assert_has(u, "max_purchases", "%s missing max_purchases" % id)


func test_upgrade_costs_are_real_values() -> void:
	## RED until JSON uses real costs (all were 1 in test-mode).
	var upgrades := ProducerData.get_shop_upgrades()
	for u in upgrades:
		assert_gt(u.get("cost", 0), 1,
				"upgrade %s cost should be > 1 (real game values)" % u.get("id", "?"))


func test_drill_bit_upgrade_exists_with_correct_category() -> void:
	var u := ProducerData.get_upgrade("drill_bit_mk2")
	assert_false(u.is_empty())
	assert_eq(u.get("category"), "player")
	assert_eq(u.get("max_purchases"), 1)


func test_fleet_license_is_bay_only() -> void:
	var u := ProducerData.get_upgrade("fleet_license")
	assert_true(u.get("bay_only", false), "fleet_license should be bay_only")
	assert_true(u.get("scales", false), "fleet_license should scale in cost")


# --- Ship part data contract -------------------------------------------------

func test_all_ship_parts_have_required_fields() -> void:
	for part_id in ["hull_plating", "ion_drive", "navigation_core", "fuel_cell"]:
		var p := ProducerData.get_ship_part(part_id)
		assert_false(p.is_empty(), "%s not found" % part_id)
		assert_has(p, "name")
		assert_has(p, "requires_scrap")
		assert_has(p, "requires_shards")
		assert_has(p, "credits_cost")


func test_ship_part_costs_are_real_values() -> void:
	var hull := ProducerData.get_ship_part("hull_plating")
	assert_ge(hull.get("requires_scrap", 0), 30,
			"hull_plating should require ≥ 30 scrap metal (real value = 40)")

	var ion := ProducerData.get_ship_part("ion_drive")
	assert_ge(ion.get("credits_cost", 0), 200,
			"ion_drive credits cost should be ≥ 200 (real value = 300)")

	var nav := ProducerData.get_ship_part("navigation_core")
	assert_ge(nav.get("credits_cost", 0), 400,
			"navigation_core credits cost should be ≥ 400 (real value = 500)")


func test_hull_plating_requires_zero_shards() -> void:
	var hull := ProducerData.get_ship_part("hull_plating")
	assert_eq(hull.get("requires_shards", -1), 0,
			"hull_plating needs no shards")


func test_fuel_cell_requires_zero_credits() -> void:
	var fuel := ProducerData.get_ship_part("fuel_cell")
	assert_eq(fuel.get("credits_cost", -1), 0,
			"fuel_cell is free (credits)")


# --- Drone bay upgrade passthrough -------------------------------------------

func test_upgrade_carry_is_data_driven_not_hardcoded() -> void:
	## Regression guard: drone carry capacity must come from drone data,
	## not a magic number 3 hardcoded in drone_bay._on_upgrade_purchased.
	## We test the ProducerData layer: base capacity comes from the dict.
	var heavy := ProducerData.get_drone("heavy_drone")
	var base_carry: int = heavy.get("carry_capacity", -1)
	assert_gt(base_carry, 3,
			"heavy_drone base carry_capacity should exceed scout (3)")

	# With 2 rack upgrades, heavy drone should have base_carry + 4
	GameState.purchased_upgrades["drone_cargo_rack"] = 2
	var modified := ProducerData.get_drone_carry_capacity(base_carry)
	assert_eq(modified, base_carry + 4)
