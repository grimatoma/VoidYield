class_name MainScene
extends Node
## MainScene — Root scene orchestrator that wires all game systems together.

const StorageDepotScript = preload("res://scenes/world/storage_depot.gd")
const DroneBayScript = preload("res://scenes/drones/drone_bay.gd")
const DroneTaskQueueScript = preload("res://scenes/drones/drone_task_queue.gd")
const GameLoopScript = preload("res://scenes/world/game_loop.gd")

var storage: StorageDepot
var drone_bay: DroneBay
var drone_queue: DroneTaskQueue
var game_loop: GameLoop

var _harvesters: Array = []
var _game_loop_ticks: int = 0


func setup() -> void:
	# Create component instances
	storage = StorageDepotScript.new()
	add_child(storage)

	drone_queue = DroneTaskQueueScript.new()
	add_child(drone_queue)

	drone_bay = DroneBayScript.new()
	drone_bay.task_queue = drone_queue
	add_child(drone_bay)

	game_loop = GameLoopScript.new()
	game_loop.setup(storage, drone_bay, drone_queue)
	add_child(game_loop)


func _process(delta: float) -> void:
	if not game_loop:
		return

	game_loop.tick(delta)
	_game_loop_ticks += 1

	# Tick all registered harvesters
	for harvester in _harvesters:
		if harvester and not harvester.is_queued_for_deletion():
			harvester.tick(delta)


func register_harvester(harvester) -> void:
	if harvester not in _harvesters:
		_harvesters.append(harvester)
	if storage:
		harvester.link_depot(storage)
