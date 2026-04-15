extends Interactable
## DroneBay — Spawns and manages active drones. Drones launch from here and return here.

signal bay_opened
signal bay_closed

@onready var sprite: ColorRect = $Sprite

const COLOR_BASE = Color(0.3, 0.4, 0.35)
const DRONE_SCENE = preload("res://scenes/drones/scout_drone.tscn")

var active_drones: Array = []
var is_bay_open: bool = false


func _ready() -> void:
	is_held_interaction = false
	sprite.color = COLOR_BASE
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)


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

	var drone_instance = DRONE_SCENE.instantiate()
	drone_instance.move_speed    = drone_data.get("speed", 60.0)
	drone_instance.carry_capacity = ProducerData.get_drone_carry_capacity(drone_data.get("carry_capacity", 3))
	drone_instance.mine_time     = ProducerData.get_drone_mine_time(drone_data.get("mine_time", 3.0))
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


func _on_upgrade_purchased(_upgrade_id: String) -> void:
	for drone in active_drones:
		if is_instance_valid(drone):
			drone.carry_capacity = ProducerData.get_drone_carry_capacity(3)
			drone.mine_time      = ProducerData.get_drone_mine_time(3.0)
