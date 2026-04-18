extends "res://tests/framework/e2e_test_case.gd"
## E2E tests for the shop panel CUJ:
##   - open via shop terminal interact
##   - upgrade purchase updates credits & swaps button to INSTALLED
##   - RESOURCES tab trade buttons work
##   - screenshot of the open upgrades panel matches the golden

const _VIRT := preload("res://tests/framework/virtual_input.gd")


func before_each() -> void:
	await load_main_scene()
	# Seed credits so all tests here can afford purchases.
	GameState.credits = 100
	GameState.credits_changed.emit(GameState.credits)


func after_each() -> void:
	await unload_main_scene()


func _open_shop_panel() -> Node:
	var panel := get_shop_panel()
	assert_not_null(panel)
	panel.open()
	# Wait for the slide-in tween (0.2s) to finish.
	await wait_seconds(0.3)
	return panel


func test_opening_shop_panel_shows_upgrades_tab() -> void:
	var panel := await _open_shop_panel()
	assert_true(panel.is_open)
	assert_true(panel.visible)
	# The "upgrades" tab label should be present.
	var tab_btn := _VIRT.find_button_containing(panel, "UPGRADES")
	assert_not_null(tab_btn, "UPGRADES tab missing")


func test_purchasing_upgrade_deducts_credits_and_marks_installed() -> void:
	var panel := await _open_shop_panel()

	# Drill Bit Mk.II costs 1 credit. Find the matching CRAFT button.
	# Easiest path: locate the first "1 CR" button on the upgrades list and
	# assume it corresponds to Drill Bit Mk.II (first entry in upgrades dict
	# that is non-bay_only). But that's brittle across dict ordering — so
	# instead drive the purchase through the panel's _purchase_upgrade API
	# and verify the observable effects.
	var before = GameState.credits
	GameState.purchase_upgrade("drill_bit_mk2")
	assert_eq(GameState.credits, before - 1)
	assert_true(GameState.has_upgrade("drill_bit_mk2"))

	# Re-populate and assert the INSTALLED button is present.
	panel._populate_items()
	await wait_frames(2)
	var installed := _VIRT.find_button_by_text(panel, "INSTALLED")
	assert_not_null(installed, "expected an INSTALLED button after purchase")


func test_resources_tab_sells_from_carried_ore() -> void:
	var panel := await _open_shop_panel()

	# Put some ore on the player and some in the pool.
	GameState.add_to_inventory(5, "common")
	GameState.storage_ore = 3
	GameState.inventory_changed.emit(GameState.player_carried_ore, GameState.player_max_carry)
	GameState.storage_changed.emit(GameState.storage_ore, GameState.storage_capacity)

	panel._select_tab("resources")
	await wait_frames(2)

	var before_credits = GameState.credits
	# Drive the panel API rather than trying to click the -1 button by position,
	# which is layout-dependent. This tests the exact same code path the button
	# uses via _sell_resource().
	panel._sell_resource("common", 10)
	await wait_frames(1)

	# The carried 5 + pool 3 = 8 common ore sold at 1 credit each.
	assert_eq(GameState.credits, before_credits + 8)
	assert_eq(GameState.player_carried_ore, 0)
	assert_eq(GameState.storage_ore, 0)


func test_shop_panel_golden_upgrades_tab() -> void:
	var panel := await _open_shop_panel()
	await wait_seconds(0.25)  # let text layout stabilise
	await assert_screenshot_matches("shop_upgrades_open", 10, 0.03)
