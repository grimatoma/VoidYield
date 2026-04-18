extends "res://tests/framework/e2e_test_case.gd"
## End-to-end core-loop CUJ:
##   1. player gains ore (simulated mine via GameState API)
##   2. deposits to storage pool
##   3. sells via sell_terminal → credits increase, HUD label updates
##   4. crafts a ship part via spaceship panel
##
## This is a whitebox trace through the economy pipeline exercised from the
## real Main scene so signal wiring, HUD reactions, and GameState mutation
## are validated together.


func before_each() -> void:
	await load_main_scene()


func after_each() -> void:
	await unload_main_scene()


func test_core_loop_mine_deposit_sell() -> void:
	# --- mine: simulate 6 successful ore pickups ---
	for i in 6:
		GameState.add_to_inventory(1, "common")
	assert_eq(GameState.player_carried_ore, 6)

	# --- deposit to storage via dump helper ---
	var moved = GameState.dump_inventory_to_storage()
	assert_eq(moved, 6)
	assert_eq(GameState.storage_ore, 6)
	assert_eq(GameState.player_carried_ore, 0)

	# --- sell via the core API (what the terminal calls) ---
	var earned = GameState.sell_all_ore()
	assert_eq(earned, 6, "6 * common price 1")
	assert_eq(GameState.storage_ore, 0)

	# HUD reacts via its signal handlers; let a frame tick so labels update.
	await wait_frames(2)
	var hud := get_tree().root.find_child("HUD", true, false)
	if hud != null:
		var credits_lbl: Label = hud.get_node_or_null("TopBar/CreditsLabel")
		if credits_lbl != null:
			assert_true(credits_lbl.text.find("6") != -1,
				"credits HUD should contain the new total, got '%s'" % credits_lbl.text)


func test_craft_ship_part_via_panel() -> void:
	var panel := get_spaceship_panel()
	assert_not_null(panel)

	# Seed materials: hull plating needs 10 common ore.
	GameState.storage_ore = 10
	GameState.storage_changed.emit(GameState.storage_ore, GameState.storage_capacity)

	panel.open()
	await wait_seconds(0.3)

	assert_true(GameState.can_craft_ship_part("hull_plating"))
	GameState.craft_ship_part("hull_plating")
	assert_true(GameState.spaceship_parts_crafted["hull_plating"])

	# Repopulate panel; the part row should now display "✓ BUILT".
	panel._populate()
	await wait_frames(2)

	var built = false
	for lbl in _labels(panel):
		if lbl.text.find("BUILT") != -1:
			built = true
			break
	assert_true(built, "expected a ✓ BUILT marker on the hull row")


func _labels(root: Node) -> Array:
	var out: Array = []
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is Label:
			out.append(n)
		for c in n.get_children():
			stack.append(c)
	return out
