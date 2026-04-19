class_name DroneTaskQueue
extends Node

enum TaskType { IDLE, HAUL, SCOUT, REPAIR, REFUEL }

var pending_tasks: Array = []
var active_tasks: Dictionary = {}

signal task_assigned(drone: Node, task: Dictionary)
signal task_completed(drone: Node, task: Dictionary)


func enqueue(type: TaskType, target: Node, priority: int = 0) -> void:
	var task = {
		"type": type,
		"target": target,
		"priority": priority
	}
	pending_tasks.append(task)
	pending_tasks.sort_custom(func(a, b): return a.priority > b.priority)


func assign_next(drone: Node) -> Dictionary:
	if pending_tasks.is_empty():
		return {}

	var task = pending_tasks.pop_front()
	var drone_id = drone.get_instance_id()
	active_tasks[drone_id] = task
	task_assigned.emit(drone, task)
	return task


func complete_task(drone: Node) -> void:
	var drone_id = drone.get_instance_id()
	if drone_id in active_tasks:
		var task = active_tasks[drone_id]
		active_tasks.erase(drone_id)
		task_completed.emit(drone, task)


func cancel_tasks_for(target: Node) -> void:
	pending_tasks = pending_tasks.filter(func(t): return t.target != target)
