extends "res://scripts/interactable.gd"
## DroneBay — Spawns and manages active drones. Drones launch from here and return here.

signal bay_opened
signal bay_closed

@onready var sprite: Sprite2D = $Sprite

const DEFAULT_DRONE_SCENE = "res://scenes/drones/scout_drone.tscn"

var active_drones: Array = []
var is_bay_open: bool = false


func _ready() -> void:
	is_held_interaction = false
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)
	if GameState.debug_click_mode:
		# DEBUG: auto-deploy 2 drones at startup
		call_deferred("_debug_auto_deploy")


func get_prompt_text() -> String:
	return "[E] Drone Bay (%d/%d)" % [GameState.active_drone_count, GameState.max_fleet_size]


func interact(_player: Node2D) -> void:
	if not is_bay_open:
		is_bay_open = true
		bay_opened.emit()


func close_bay() -> void:
	if is_bay_open:
		is_bay_open = false
		bay_closed.emit()


func on_player_left() -> void:
	close_bay()


func is_interactable() -> bool:
	return not is_bay_open


func deploy_drone(drone_id: String = "scout_drone") -> bool:
	if not GameState.can_deploy_drone():
		return false
	var drone_data = ProducerData.get_drone(drone_id)
	if drone_data.is_empty():
		return false

	var scene_path: String = drone_data.get("scene", DEFAULT_DRONE_SCENE)
	var drone_scene: PackedScene = load(scene_path)
	if drone_scene == null:
		push_error("[DroneBay] Could not load drone scene: %s" % scene_path)
		return false
	var drone_instance = drone_scene.instantiate()
	var base_carry: int = drone_data.get("carry_capacity", 3)
	var base_time: float = drone_data.get("mine_time", 3.0)
	drone_instance.move_speed     = drone_data.get("speed", 60.0)
	drone_instance.carry_capacity = ProducerData.get_drone_carry_capacity(base_carry)
	drone_instance.mine_time      = ProducerData.get_drone_mine_time(base_time)
	drone_instance.drone_bay_position = global_position
	drone_instance.storage_position   = _find_storage_position()

	var field = get_parent().get_parent()
	field.add_child(drone_instance)
	drone_instance.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))

	active_drones.append(drone_instance)
	GameState.register_drone(drone_instance)
	return true


func get_active_drones() -> Array:
	## Returns live drone instances (filters out invalid/freed drones).
	active_drones = active_drones.filter(func(d): return is_instance_valid(d))
	return active_drones


func _find_storage_position() -> Vector2:
	var storage = get_tree().get_first_node_in_group("storage_depot")
	if storage:
		return storage.global_position
	return global_position


func _debug_auto_deploy() -> void:
	for i in 2:
		deploy_drone("scout_drone")


func _on_upgrade_purchased(_upgrade_id: String) -> void:
	## Re-apply stats from data to all live drones when an upgrade is purchased.
	for drone in active_drones:
		if not is_instance_valid(drone):
			continue
		# Determine which drone type this is by matching its scene resource path.
		# Fall back to scout_drone stats if we can't identify the type.
		var drone_id := _identify_drone_type(drone)
		var drone_data := ProducerData.get_drone(drone_id)
		if drone_data.is_empty():
			drone_data = ProducerData.get_drone("scout_drone")
		var base_carry: int   = drone_data.get("carry_capacity", 3)
		var base_time: float  = drone_data.get("mine_time", 3.0)
		drone.carry_capacity  = ProducerData.get_drone_carry_capacity(base_carry)
		drone.mine_time       = ProducerData.get_drone_mine_time(base_time)


func _identify_drone_type(drone: Node) -> String:
	## Returns the drone_id by matching the scene file path of the drone instance.
	var scene_path: String = drone.get_scene_file_path()
	for drone_id in ProducerData.drones:
		if ProducerData.drones[drone_id].get("scene", "") == scene_path:
			return drone_id
	return "scout_drone"
