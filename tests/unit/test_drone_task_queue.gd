extends "res://tests/framework/test_case.gd"

const DroneTaskQueueScript = preload("res://scenes/drones/drone_task_queue.gd")

var queue
var signal_received_data = {}


func before_each() -> void:
	queue = DroneTaskQueueScript.new()
	add_child(queue)
	signal_received_data = {}


func after_each() -> void:
	if queue and queue.is_inside_tree():
		queue.queue_free()


func test_enqueue_adds_task() -> void:
	queue.enqueue(DroneTaskQueueScript.TaskType.IDLE, null, 0)
	assert_eq(queue.pending_tasks.size(), 1, "Should add task to pending")


func test_assign_highest_priority() -> void:
	queue.enqueue(DroneTaskQueueScript.TaskType.IDLE, null, 1)
	queue.enqueue(DroneTaskQueueScript.TaskType.HAUL, null, 5)
	queue.enqueue(DroneTaskQueueScript.TaskType.SCOUT, null, 3)

	var drone = Node.new()
	var assigned = queue.assign_next(drone)

	assert_eq(assigned.type, DroneTaskQueueScript.TaskType.HAUL, "Should assign highest priority task")


func test_assign_empty_returns_empty_dict() -> void:
	var drone = Node.new()
	var assigned = queue.assign_next(drone)

	assert_eq(assigned.size(), 0, "Should return empty dict when no tasks")


func test_assign_moves_to_active() -> void:
	queue.enqueue(DroneTaskQueueScript.TaskType.IDLE, null, 0)
	var drone = Node.new()
	var assigned = queue.assign_next(drone)

	assert_eq(queue.pending_tasks.size(), 0, "Should remove from pending")
	assert_eq(queue.active_tasks.size(), 1, "Should add to active")


func test_complete_removes_from_active() -> void:
	queue.enqueue(DroneTaskQueueScript.TaskType.IDLE, null, 0)
	var drone = Node.new()
	queue.assign_next(drone)

	queue.complete_task(drone)

	assert_eq(queue.active_tasks.size(), 0, "Should remove from active")


func test_cancel_for_target_removes_all() -> void:
	var target = Node.new()
	queue.enqueue(DroneTaskQueueScript.TaskType.HAUL, target, 0)
	queue.enqueue(DroneTaskQueueScript.TaskType.HAUL, target, 0)
	queue.enqueue(DroneTaskQueueScript.TaskType.SCOUT, null, 0)

	queue.cancel_tasks_for(target)

	assert_eq(queue.pending_tasks.size(), 1, "Should only remove tasks for target")


func test_assigned_signal() -> void:
	var drone = Node.new()
	queue.task_assigned.connect(_on_task_assigned)

	queue.enqueue(DroneTaskQueueScript.TaskType.IDLE, null, 0)
	queue.assign_next(drone)

	assert_true(signal_received_data.has("drone"), "Signal should fire and pass drone")
	assert_eq(signal_received_data.drone, drone, "Signal should pass correct drone")
	assert_eq(signal_received_data.task.type, DroneTaskQueueScript.TaskType.IDLE, "Signal should pass task")


func test_completed_signal() -> void:
	var drone = Node.new()
	queue.task_completed.connect(_on_task_completed)

	queue.enqueue(DroneTaskQueueScript.TaskType.IDLE, null, 0)
	queue.assign_next(drone)
	queue.complete_task(drone)

	assert_true(signal_received_data.has("drone"), "Signal should fire and pass drone")
	assert_eq(signal_received_data.drone, drone, "Signal should pass correct drone")
	assert_eq(signal_received_data.task.type, DroneTaskQueueScript.TaskType.IDLE, "Signal should pass task")


func _on_task_assigned(drone: Node, task: Dictionary) -> void:
	signal_received_data.drone = drone
	signal_received_data.task = task


func _on_task_completed(drone: Node, task: Dictionary) -> void:
	signal_received_data.drone = drone
	signal_received_data.task = task
