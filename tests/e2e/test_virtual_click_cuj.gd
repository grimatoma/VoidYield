extends "res://tests/framework/e2e_test_case.gd"
## E2E: virtual clicking on world interactables.
##
## Main supports `debug_click_mode` which lets a left-click anywhere on the
## screen teleport the player to the Interactable under the cursor and fire
## its interact(). We exercise that flow here by synthesizing
## InputEventMouseButton events and verifying the expected side effects.

func before_each() -> void:
	await load_main_scene()
	GameState.debug_click_mode = true


func after_each() -> void:
	await unload_main_scene()


## Build an InputEventMouseButton with screen coords at the given world
## position, going through the player's camera so our coordinate maths matches
## main._input's reverse transform.
func _synth_click_at_world(world_pos: Vector2) -> InputEventMouseButton:
	var player := get_player()
	var camera: Camera2D = player.get_node("Camera2D")
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var screen_pos: Vector2 = (world_pos - camera.get_screen_center_position()) * camera.zoom \
		+ viewport_size * 0.5

	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = screen_pos
	return ev


func test_click_shop_terminal_opens_shop_panel() -> void:
	# Extra wait for physics world to sync Area2D collision shapes.
	await wait_seconds(0.5)

	# Find the shop terminal in the Main scene tree (no group assigned).
	var shop_terminal: Node2D = _find_by_script(main_scene, "shop_terminal.gd")
	assert_not_null(shop_terminal, "shop terminal must exist in asteroid field")
	if shop_terminal == null:
		return

	# Synthesize a click at the shop terminal's world position and feed it
	# directly into main._input — more reliable than Input.parse_input_event
	# which must route through the viewport's input dispatch (problematic when
	# multiple root-level scenes coexist).
	var ev := _synth_click_at_world(shop_terminal.global_position)
	main_scene._input(ev)
	await wait_frames(4)

	var shop_panel := get_shop_panel()
	var opened = await wait_until(func(): return shop_panel.is_open, 1.5)
	assert_true(opened, "clicking shop terminal should open the shop panel")


func test_click_over_open_panel_is_ignored() -> void:
	var shop_panel := get_shop_panel()
	shop_panel.open()
	await wait_seconds(0.3)

	var player := get_player()
	var start := player.global_position

	# Click in the middle of the (now-open) shop panel area: Main should
	# swallow the event and NOT teleport the player.
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = shop_panel.get_global_rect().get_center()
	main_scene._input(ev)
	await wait_frames(4)

	assert_near(player.global_position.x, start.x, 0.5,
		"player must not teleport when panel is open")
	assert_near(player.global_position.y, start.y, 0.5)


func _all_nodes(root: Node) -> Array:
	var out: Array = [root]
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for c in n.get_children():
			out.append(c)
			stack.append(c)
	return out


func _find_by_script(root: Node, script_suffix: String) -> Node:
	for n in _all_nodes(root):
		var s = n.get_script()
		if s != null and s.resource_path.ends_with(script_suffix):
			return n
	return null
