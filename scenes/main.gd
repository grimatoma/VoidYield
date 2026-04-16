extends Node2D
## Main — Root scene. Manages world loading, player placement, and planet transitions.

@onready var world_container: Node2D = $WorldContainer
@onready var shop_panel: PanelContainer = $UILayer/ShopPanel
@onready var spaceship_panel: PanelContainer = $UILayer/SpaceshipPanel

const ASTEROID_FIELD_SCENE = preload("res://scenes/world/asteroid_field.tscn")
const PLANET_B_SCENE       = preload("res://scenes/world/planet_b.tscn")
const PLAYER_SCENE         = preload("res://scenes/player/player.tscn")

var _player: Node2D = null
var _current_world: Node2D = null


func _ready() -> void:
	add_to_group("main_scene")
	shop_panel.add_to_group("shop_panel")
	spaceship_panel.add_to_group("spaceship_panel")

	# Connect SpaceshipPanel launch signal
	spaceship_panel.launch_requested.connect(_on_launch_requested)

	# Load initial world (A1)
	_load_world(ASTEROID_FIELD_SCENE, Vector2(280, 420))

	print("[Main] VoidYield initialized.")


func _input(event: InputEvent) -> void:
	## Debug click-to-interact: left-click anywhere in the world to instantly
	## interact with the nearest Interactable under the cursor.
	if not GameState.debug_click_mode:
		return
	if not event is InputEventMouseButton:
		return
	var mb := event as InputEventMouseButton
	if not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return

	# Don't teleport if the click landed on an open UI panel.
	if _is_click_over_open_panel(mb.position):
		return

	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	# Convert screen click to world position via the player's camera
	var camera: Camera2D = player.get_node_or_null("Camera2D")
	var world_pos: Vector2
	if camera:
		world_pos = camera.get_screen_center_position() \
				  + (mb.position - get_viewport().get_visible_rect().size * 0.5) / camera.zoom
	else:
		world_pos = get_viewport().get_canvas_transform().affine_inverse() * mb.position

	# Physics query for all Area2D at the click position
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 4  # Layer 3 — interactables

	var hits := space.intersect_point(query, 8)
	for hit in hits:
		var obj = hit.get("collider")
		if obj is Interactable and obj.is_interactable():
			player.global_position = obj.global_position + Vector2(20, 0)
			obj.interact(player)
			get_viewport().set_input_as_handled()
			return


func _is_click_over_open_panel(screen_pos: Vector2) -> bool:
	## Returns true if the click falls inside any currently-open UI panel.
	for panel in [shop_panel, spaceship_panel]:
		if panel.visible and panel.is_open and panel.get_global_rect().has_point(screen_pos):
			return true
	return false


# --- Planet Transition ---

func _on_launch_requested() -> void:
	_travel_to_planet_b()


func _travel_to_planet_b() -> void:
	GameState.despawn_all_drones()
	GameState.current_planet = "planet_b"

	_load_world(PLANET_B_SCENE, Vector2(280, 330))
	print("[Main] Arrived at Planet B — Vortex Drift.")


func return_to_a1() -> void:
	GameState.despawn_all_drones()
	GameState.current_planet = "asteroid_a1"

	_load_world(ASTEROID_FIELD_SCENE, Vector2(280, 420))
	print("[Main] Returned to Asteroid A1.")


func _load_world(scene: PackedScene, player_spawn: Vector2) -> void:
	# Close any open panels
	if shop_panel.is_open:
		shop_panel.close()
	if spaceship_panel.is_open:
		spaceship_panel.close()

	# Clear interaction target
	GameState.current_interaction_target = null
	GameState.interaction_target_changed.emit(null)

	# Remove old world + player
	for child in world_container.get_children():
		child.queue_free()

	# Small delay so queue_free completes before adding new world
	await get_tree().process_frame
	await get_tree().process_frame

	# Instantiate new world
	_current_world = scene.instantiate()
	world_container.add_child(_current_world)

	# Spawn player inside the new world
	_player = PLAYER_SCENE.instantiate()
	_current_world.add_child(_player)
	_player.global_position = player_spawn
