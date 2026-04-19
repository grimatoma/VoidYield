extends Node2D
## Main — Root scene. Manages world loading, player placement, and planet transitions.

@onready var world_container: Node2D = $WorldContainer
@onready var shop_panel: PanelContainer = $UILayer/ShopPanel
@onready var spaceship_panel: PanelContainer = $UILayer/SpaceshipPanel
@onready var galaxy_map_panel: Control = $UILayer/GalaxyMapPanel
@onready var _pause_menu: CanvasLayer = $PauseMenu

const ASTEROID_FIELD_SCENE = preload("res://scenes/world/asteroid_field.tscn")
const PLANET_B_SCENE       = preload("res://scenes/world/planet_b.tscn")
const PLAYER_SCENE         = preload("res://scenes/player/player.tscn")
const TechTreePanelScene   = preload("res://scenes/ui/tech_tree_panel.tscn")

# Maps galaxy-map destination ids to (scene, spawn) for world loading.
const DESTINATIONS := {
	"asteroid_a1": {"scene": ASTEROID_FIELD_SCENE, "spawn": Vector2(700, 450)},
	"planet_b":    {"scene": PLANET_B_SCENE,       "spawn": Vector2(280, 330)},
}

var _player: Node2D = null
var _current_world: Node2D = null
var _colony: ColonyManager


func _ready() -> void:
	# Scale the game to fill the screen while keeping the 960x540 base aspect ratio.
	# Canvas items mode means sprites and UI scale up on larger/fullscreen displays.
	get_tree().root.content_scale_mode   = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	get_tree().root.content_scale_size   = Vector2i(960, 540)

	# HUD and UILayer must keep processing while the tree is paused (pause menu open)
	$HUD.process_mode     = Node.PROCESS_MODE_ALWAYS
	$UILayer.process_mode = Node.PROCESS_MODE_ALWAYS

	add_to_group("main_scene")
	shop_panel.add_to_group("shop_panel")
	spaceship_panel.add_to_group("spaceship_panel")
	galaxy_map_panel.add_to_group("galaxy_map_panel")

	# Ship LAUNCH and LaunchPad open the galaxy map; the map emits travel_requested.
	spaceship_panel.launch_requested.connect(_on_launch_requested)
	galaxy_map_panel.travel_requested.connect(_on_galaxy_travel_requested)

	# Instantiate and add tech tree panel
	var tech_tree_panel = TechTreePanelScene.instantiate()
	$UILayer.add_child(tech_tree_panel)
	tech_tree_panel.add_to_group("tech_tree_panel")

	# Load initial world (A1)
	_load_world(ASTEROID_FIELD_SCENE, Vector2(700, 450))

	# Initialize colony manager
	_colony = ColonyManager.new()
	_colony.set_need("water", true)
	_colony.set_need("food", true)
	_colony.set_need("power", true)

	print("[Main] VoidYield initialized.")


func _process(delta: float) -> void:
	_colony.tick(delta)


func _input(event: InputEvent) -> void:
	# F11 toggles fullscreen
	if event is InputEventKey and event.pressed and not event.echo \
			and event.keycode == KEY_F11:
		SettingsManager.set_fullscreen(not SettingsManager.fullscreen)
		get_viewport().set_input_as_handled()
		return

	# ESC toggles pause (but not if a full-screen panel is open)
	if event.is_action_pressed("ui_cancel"):
		if not galaxy_map_panel.is_open and not shop_panel.is_open and not spaceship_panel.is_open:
			get_tree().paused = not get_tree().paused
			_pause_menu.toggle()
			get_viewport().set_input_as_handled()
			return

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
	if galaxy_map_panel.visible and galaxy_map_panel.is_open:
		return true  # full-screen modal — block clicks everywhere
	return false


# --- Planet Transition ---

func _on_launch_requested() -> void:
	# Fired by the ship panel's LAUNCH button — show the galaxy map so the
	# player can pick a destination.
	open_galaxy_map()


func open_galaxy_map() -> void:
	galaxy_map_panel.open()


func _on_galaxy_travel_requested(destination_id: String) -> void:
	if not DESTINATIONS.has(destination_id):
		push_warning("[Main] Unknown galaxy map destination: %s" % destination_id)
		return
	if destination_id == GameState.current_planet:
		return  # already there — no-op
	var dest: Dictionary = DESTINATIONS[destination_id]
	_travel_to(destination_id, dest["scene"], dest["spawn"])


func _travel_to(destination_id: String, scene: PackedScene, spawn: Vector2) -> void:
	GameState.despawn_all_drones()
	GameState.current_planet = destination_id
	GameState.on_planet_visited(destination_id)
	_load_world(scene, spawn)
	print("[Main] Traveled to %s." % destination_id)


# Back-compat shim — Planet B's launch pad used to call this directly.
# The launch pad now opens the galaxy map instead, but older callers may remain.
func return_to_a1() -> void:
	_on_galaxy_travel_requested("asteroid_a1")


func _load_world(scene: PackedScene, player_spawn: Vector2) -> void:
	# Close any open panels
	if shop_panel.is_open:
		shop_panel.close()
	if spaceship_panel.is_open:
		spaceship_panel.close()
	if galaxy_map_panel.is_open:
		galaxy_map_panel.close()

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
