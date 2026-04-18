class_name VirtualInput
extends RefCounted
## Helpers for simulating user input in E2E tests.
##
## We deliberately call button.pressed.emit() rather than synthesising mouse
## clicks wherever possible — this is more reliable across resolutions and
## avoids the ShopPanel slide-in animation racing the click.
## For world-space interactables we drive the same code path as main.gd's
## debug-click handler (physics query + interact()).


## Emit a Button's pressed signal. Safe no-op if btn is null or disabled.
static func click_button(btn: Button) -> bool:
	if btn == null or not is_instance_valid(btn):
		return false
	if btn.disabled:
		return false
	btn.pressed.emit()
	return true


## Find the first descendant Button whose text matches (case-insensitive).
static func find_button_by_text(root: Node, text: String) -> Button:
	if root == null:
		return null
	var needle := text.to_lower()
	for child in _iter_all(root):
		if child is Button and (child as Button).text.to_lower() == needle:
			return child
	return null


## Find the first descendant Button whose text contains `substr`.
static func find_button_containing(root: Node, substr: String) -> Button:
	if root == null:
		return null
	var needle := substr.to_lower()
	for child in _iter_all(root):
		if child is Button and (child as Button).text.to_lower().find(needle) != -1:
			return child
	return null


## Find the first descendant Label whose text contains `substr`.
static func find_label_containing(root: Node, substr: String) -> Label:
	if root == null:
		return null
	var needle := substr.to_lower()
	for child in _iter_all(root):
		if child is Label and (child as Label).text.to_lower().find(needle) != -1:
			return child
	return null


## Press an input action for one physics tick (action_press + release).
## Useful for the single-frame "interact" action.
static func tap_action(action: String) -> void:
	Input.action_press(action)
	await Engine.get_main_loop().process_frame
	Input.action_release(action)


## Hold an input action for `seconds` real-time.
static func hold_action(action: String, seconds: float) -> void:
	Input.action_press(action)
	await Engine.get_main_loop().create_timer(seconds, true, false, true).timeout
	Input.action_release(action)


## Move the player character towards an absolute world position using action
## presses. Gives up after `max_seconds`. Returns true if arrival threshold
## hit before timeout.
static func move_player_to(player: Node2D, target: Vector2,
		threshold: float = 8.0, max_seconds: float = 4.0) -> bool:
	if player == null or not is_instance_valid(player):
		return false

	var start_time := Time.get_ticks_msec()
	while is_instance_valid(player):
		var delta: Vector2 = target - player.global_position
		if delta.length() <= threshold:
			_release_movement()
			return true

		_release_movement()
		if abs(delta.x) > threshold * 0.5:
			Input.action_press("move_right" if delta.x > 0 else "move_left")
		if abs(delta.y) > threshold * 0.5:
			Input.action_press("move_down" if delta.y > 0 else "move_up")

		await Engine.get_main_loop().physics_frame

		if Time.get_ticks_msec() - start_time > int(max_seconds * 1000.0):
			_release_movement()
			return false
	_release_movement()
	return false


static func _release_movement() -> void:
	for a in ["move_left", "move_right", "move_up", "move_down"]:
		if Input.is_action_pressed(a):
			Input.action_release(a)


## Directly trigger the interact() method on an Interactable. Bypasses
## proximity/area detection so unit-shaped tests are less flaky.
static func interact_with(target: Node, player: Node2D) -> void:
	if target == null or not target.has_method("interact"):
		return
	target.interact(player)


## Iterate every descendant of `root`, depth-first.
static func _iter_all(root: Node) -> Array:
	var out: Array = []
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n != root:
			out.append(n)
		for c in n.get_children():
			stack.append(c)
	return out
