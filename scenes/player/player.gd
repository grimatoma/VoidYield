extends CharacterBody2D
## Player — Top-down character with 8-directional movement and interaction system.

# --- Node References ---
@onready var interaction_area: Area2D = $InteractionArea
@onready var sprite: ColorRect = $Sprite
@onready var camera: Camera2D = $Camera2D

# --- State ---
var is_mining: bool = false
var mining_target: Node2D = null
var mining_progress: float = 0.0
var mining_duration: float = 1.5
var nearest_interactable: Node2D = null
var interactables_in_range: Array = []

# --- Camera look-ahead ---
var look_ahead_offset: Vector2 = Vector2.ZERO
const LOOK_AHEAD_DISTANCE: float = 32.0
const LOOK_AHEAD_SMOOTHING: float = 3.0

# --- Direction for sprite (future animation) ---
var facing_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	interaction_area.body_entered.connect(_on_interactable_entered)
	interaction_area.body_exited.connect(_on_interactable_exited)
	interaction_area.area_entered.connect(_on_interactable_area_entered)
	interaction_area.area_exited.connect(_on_interactable_area_exited)


func _physics_process(delta: float) -> void:
	if is_mining:
		_process_mining(delta)
		return

	_process_movement(delta)
	_process_interaction_input()
	_update_camera(delta)
	_update_nearest_interactable()


func _process_movement(delta: float) -> void:
	var input_dir = Vector2.ZERO

	# Keyboard input
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	# Mobile joystick input (added via signal from MobileControls)
	# This is combined with keyboard — whichever is active works
	if input_dir == Vector2.ZERO and _mobile_input != Vector2.ZERO:
		input_dir = _mobile_input

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		facing_direction = input_dir
		velocity = input_dir * GameState.player_move_speed
		# TODO: Update sprite direction based on facing_direction
	else:
		velocity = velocity.move_toward(Vector2.ZERO, GameState.player_move_speed * 8.0 * delta)

	move_and_slide()


# --- Mobile Joystick Input ---
var _mobile_input: Vector2 = Vector2.ZERO

func set_mobile_input(input: Vector2) -> void:
	_mobile_input = input


# --- Camera ---

func _update_camera(delta: float) -> void:
	# Look-ahead: camera leads slightly in movement direction
	var target_offset = Vector2.ZERO
	if velocity.length() > 10.0:
		target_offset = velocity.normalized() * LOOK_AHEAD_DISTANCE
	look_ahead_offset = look_ahead_offset.lerp(target_offset, LOOK_AHEAD_SMOOTHING * delta)
	camera.offset = look_ahead_offset


# --- Interaction System ---

func _process_interaction_input() -> void:
	if nearest_interactable == null:
		return

	if Input.is_action_just_pressed("interact"):
		_start_interaction(nearest_interactable)


func _start_interaction(target: Node2D) -> void:
	if not target.is_interactable():
		return

	if target.is_held_interaction:
		# Start held interaction (mining)
		is_mining = true
		mining_target = target
		mining_progress = 0.0
		mining_duration = target.hold_duration
		velocity = Vector2.ZERO
	else:
		# Instant interaction (sell, deposit, shop)
		target.interact(self)


func _process_mining(delta: float) -> void:
	# Cancel if player tries to move
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	if input_dir == Vector2.ZERO and _mobile_input != Vector2.ZERO:
		input_dir = _mobile_input

	if input_dir.length() > 0.3:
		_cancel_mining()
		return

	# Cancel if interact button released (optional: could also be tap-to-start)
	# For now, mining continues once started until completion or movement

	mining_progress += delta
	if mining_target:
		mining_target.set_meta("mining_progress", mining_progress / mining_duration)

	if mining_progress >= mining_duration:
		_complete_mining()


func _complete_mining() -> void:
	if mining_target and mining_target.has_method("interact"):
		mining_target.interact(self)
		# Screen shake — juice!
		_do_screen_shake(1.5, 0.1)
	is_mining = false
	mining_target = null
	mining_progress = 0.0


func _cancel_mining() -> void:
	if mining_target and mining_target.has_method("cancel_interaction"):
		mining_target.cancel_interaction()
	is_mining = false
	mining_target = null
	mining_progress = 0.0


# --- Screen Shake ---

func _do_screen_shake(intensity: float, duration: float) -> void:
	var tween = create_tween()
	var original_offset = camera.offset
	for i in range(4):
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(camera, "offset", original_offset + shake_offset, duration / 4.0)
	tween.tween_property(camera, "offset", original_offset, duration / 4.0)


# --- Interactable Tracking ---

func _on_interactable_area_entered(area: Area2D) -> void:
	if area is Interactable:
		if area not in interactables_in_range:
			interactables_in_range.append(area)
			_update_nearest_interactable()


func _on_interactable_area_exited(area: Area2D) -> void:
	if area in interactables_in_range:
		interactables_in_range.erase(area)
		if area == nearest_interactable:
			nearest_interactable = null
		_update_nearest_interactable()
	# Tell the interactable the player has left its range (closes open menus)
	if area.has_method("on_player_left"):
		area.on_player_left()


func _on_interactable_entered(body: Node2D) -> void:
	if body is Interactable:
		if body not in interactables_in_range:
			interactables_in_range.append(body)
			_update_nearest_interactable()


func _on_interactable_exited(body: Node2D) -> void:
	if body in interactables_in_range:
		interactables_in_range.erase(body)
		if body == nearest_interactable:
			nearest_interactable = null
		_update_nearest_interactable()


func _update_nearest_interactable() -> void:
	var closest: Node2D = null
	var closest_dist: float = INF

	for interactable in interactables_in_range:
		if not is_instance_valid(interactable):
			continue
		if not interactable.is_interactable():
			continue
		var dist = global_position.distance_to(interactable.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = interactable

	if closest != nearest_interactable:
		nearest_interactable = closest
		GameState.current_interaction_target = closest
		GameState.interaction_target_changed.emit(closest)


func get_mining_progress() -> float:
	if is_mining and mining_duration > 0:
		return mining_progress / mining_duration
	return 0.0
