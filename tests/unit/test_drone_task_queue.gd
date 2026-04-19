class_name TestDroneTaskQueue
extends TestCase

var queue: DroneTaskQueue

func before_each() -> void:
	queue = DroneTaskQueue.new()

func test_enqueue_adds_task() -> void:
	var task = {"type": DroneTaskQueue.TaskType.HAUL, "target": "ore_node_1", "priority": 0}
	queue.enqueue(DroneTaskQueue.TaskType.HAUL, "ore_node_1", 0)
	assert_eq(queue.pending_tasks.size(), 1, "Task should be added")

func test_assign_next_highest_priority() -> void:
	queue.enqueue(DroneTaskQueue.TaskType.HAUL, "target_1", 1)
	queue.enqueue(DroneTaskQueue.TaskType.SCOUT, "target_2", 5)
	queue.enqueue(DroneTaskQueue.TaskType.HAUL, "target_3", 3)

	var drone = "drone_1"
	var task = queue.assign_next(drone)
	assert_eq(task.priority, 5, "Should assign highest priority task")
	assert_eq(task.target, "target_2", "Should assign scout task")

func test_assign_next_empty_when_no_tasks() -> void:
	var drone = "drone_1"
	var task = queue.assign_next(drone)
	assert_eq(task.size(), 0, "Should return empty dict when no tasks")

func test_complete_removes_from_active() -> void:
	queue.enqueue(DroneTaskQueue.TaskType.HAUL, "target_1", 0)
	var drone = "drone_1"
	queue.assign_next(drone)
	assert_eq(queue.active_tasks.size(), 1, "Task should be in active")
	queue.complete_task(drone)
	assert_eq(queue.active_tasks.size(), 0, "Task should be removed from active")

func test_cancel_tasks_for_target_clears_all() -> void:
	queue.enqueue(DroneTaskQueue.TaskType.HAUL, "target_1", 0)
	queue.enqueue(DroneTaskQueue.TaskType.SCOUT, "target_1", 1)
	queue.enqueue(DroneTaskQueue.TaskType.HAUL, "target_2", 2)

	queue.cancel_tasks_for("target_1")
	assert_eq(queue.pending_tasks.size(), 1, "Should remove all tasks for target")
	assert_eq(queue.pending_tasks[0].target, "target_2", "Should keep other target's task")

func test_task_assigned_signal() -> void:
	queue.enqueue(DroneTaskQueue.TaskType.HAUL, "target_1", 0)
	var signal_received = false
	queue.task_assigned.connect(func(_d, _t): signal_received = true)
	queue.assign_next("drone_1")
	assert_true(signal_received, "task_assigned signal should fire")

func test_task_completed_signal() -> void:
	queue.enqueue(DroneTaskQueue.TaskType.HAUL, "target_1", 0)
	var signal_received = false
	queue.task_completed.connect(func(_d, _t): signal_received = true)
	queue.assign_next("drone_1")
	queue.complete_task("drone_1")
	assert_true(signal_received, "task_completed signal should fire")
