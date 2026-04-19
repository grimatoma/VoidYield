class_name DroneTaskQueue
extends Node

enum TaskType { IDLE, HAUL, SCOUT, REPAIR, REFUEL }

var pending_tasks: Array = []
var active_tasks: Dictionary = {}

signal task_assigned(drone, task)
signal task_completed(drone, task)

func enqueue(task_type: int, target: String, priority: int = 0) -> void:
	var task = {
		"type": task_type,
		"target": target,
		"priority": priority
	}

	# Sorted insert by priority descending
	var inserted = false
	for i in range(pending_tasks.size()):
		if priority > pending_tasks[i].priority:
			pending_tasks.insert(i, task)
			inserted = true
			break

	if not inserted:
		pending_tasks.append(task)

func assign_next(drone: String) -> Dictionary:
	if pending_tasks.is_empty():
		return {}

	var task = pending_tasks.pop_front()
	active_tasks[drone] = task
	task_assigned.emit(drone, task)
	return task

func complete_task(drone: String) -> void:
	if drone in active_tasks:
		var task = active_tasks[drone]
		active_tasks.erase(drone)
		task_completed.emit(drone, task)

func cancel_tasks_for(target: String) -> void:
	var to_remove = []
	for i in range(pending_tasks.size()):
		if pending_tasks[i].target == target:
			to_remove.append(i)

	for i in to_remove.reverse():
		pending_tasks.remove_at(i)
