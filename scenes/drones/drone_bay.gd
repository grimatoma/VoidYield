class_name DroneBay
extends Node

var drones: Array = []
var task_queue = null  # DroneTaskQueue

signal drone_registered(drone: Node)
signal drone_dispatched(drone: Node, task: Dictionary)


func register_drone(drone: Node) -> void:
	drones.append(drone)
	drone_registered.emit(drone)


func unregister_drone(drone: Node) -> void:
	drones.erase(drone)


func get_idle_drones() -> Array:
	var idle = []
	if task_queue == null:
		return drones.duplicate()
	for drone in drones:
		var drone_id = drone.get_instance_id()
		if not drone_id in task_queue.active_tasks:
			idle.append(drone)
	return idle


func dispatch_pending() -> void:
	if task_queue == null:
		return

	var idle = get_idle_drones()
	for drone in idle:
		var task = task_queue.assign_next(drone)
		if task.size() > 0:
			drone_dispatched.emit(drone, task)


func request_haul(from_node: Node, to_node: Node, ore_type: String, amount: int, priority: int = 0) -> void:
	if task_queue == null:
		return

	task_queue.enqueue(1, to_node, priority)


func request_repair(target: Node, priority: int = 5) -> void:
	if task_queue == null:
		return

	task_queue.enqueue(3, target, priority)


func drone_count() -> int:
	return drones.size()


func idle_count() -> int:
	return get_idle_drones().size()
