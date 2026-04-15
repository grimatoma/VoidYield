extends CanvasLayer
## MobileControls — Virtual joystick and context-sensitive action button.
## Only visible when touch input is detected.

@onready var joystick_outer: Control = $JoystickOuter
@onready var joystick_inner: Control = $JoystickOuter/JoystickInner
@onready var action_button: Button = $ActionButton

var joystick_active: bool = false
var joystick_center: Vector2 = Vector2.ZERO
var joystick_radius: float = 50.0
var joystick_touch_index: int = -1
var current_input: Vector2 = Vector2.ZERO

var is_touch_device: bool = false


func _ready() -> void:
	# Show on touchscreen devices or in the browser (web export)
	is_touch_device = DisplayServer.is_touchscreen_available() or OS.has_feature("web")
	visible = is_touch_device

	if is_touch_device:
		joystick_center = joystick_outer.get_rect().get_center()
		action_button.pressed.connect(_on_action_pressed)

	# Listen for interaction target changes
	GameState.interaction_target_changed.connect(_on_interaction_target_changed)


func _input(event: InputEvent) -> void:
	if not is_touch_device:
		return

	# Handle joystick touch
	if event is InputEventScreenTouch:
		if event.pressed:
			# Check if touch is in left half of screen (joystick area)
			if event.position.x < get_viewport().get_visible_rect().size.x * 0.4:
				joystick_active = true
				joystick_touch_index = event.index
				_update_joystick(event.position)
		else:
			if event.index == joystick_touch_index:
				_reset_joystick()

	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_index and joystick_active:
			_update_joystick(event.position)


func _update_joystick(touch_pos: Vector2) -> void:
	var local_pos = touch_pos - joystick_outer.global_position - joystick_center
	var distance = local_pos.length()

	if distance > joystick_radius:
		local_pos = local_pos.normalized() * joystick_radius

	joystick_inner.position = joystick_center + local_pos - joystick_inner.size / 2
	current_input = local_pos / joystick_radius

	# Send input to player
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_mobile_input"):
		player.set_mobile_input(current_input)


func _reset_joystick() -> void:
	joystick_active = false
	joystick_touch_index = -1
	joystick_inner.position = joystick_center - joystick_inner.size / 2
	current_input = Vector2.ZERO

	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_mobile_input"):
		player.set_mobile_input(Vector2.ZERO)


func _on_action_pressed() -> void:
	# Simulate interact input
	Input.action_press("interact")
	# Release next frame
	await get_tree().process_frame
	Input.action_release("interact")


func _on_interaction_target_changed(target: Node2D) -> void:
	if target and target.has_method("get_prompt_text"):
		var text = target.get_prompt_text()
		action_button.text = text.replace("[E] ", "")
		action_button.visible = text != ""
	else:
		action_button.visible = false
