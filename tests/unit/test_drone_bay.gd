extends "res://tests/framework/test_case.gd"

const DroneBayScript = preload("res://scenes/drones/drone_bay.gd")
const DroneTaskQueueScript = preload("res://scenes/drones/drone_task_queue.gd")
const CargoDroneScript = preload("res://scenes/drones/cargo_drone.gd")

var bay
var queue


func before_each() -> void:
	queue = DroneTaskQueueScript.new()
	add_child(queue)

	bay = DroneBayScript.new()
	bay.task_queue = queue
	add_child(bay)


func after_each() -> void:
	if bay and bay.is_inside_tree():
		bay.queue_free()
	if queue and queue.is_inside_tree():
		queue.queue_free()


func test_register_adds_drone() -> void:
	var drone = CargoDroneScript.new()
	bay.register_drone(drone)
	assert_eq(bay.drones.size(), 1, "Should add drone to array")
	assert_eq(bay.drones[0], drone, "Should be the registered drone")


func test_unregister_removes_drone() -> void:
	var drone = CargoDroneScript.new()
	bay.register_drone(drone)
	bay.unregister_drone(drone)
	assert_eq(bay.drones.size(), 0, "Should remove drone from array")


func test_drone_count_correct() -> void:
	var drone1 = CargoDroneScript.new()
	var drone2 = CargoDroneScript.new()
	bay.register_drone(drone1)
	bay.register_drone(drone2)
	assert_eq(bay.drone_count(), 2, "Should return correct drone count")


func test_idle_drones_all_idle_initially() -> void:
	var drone1 = CargoDroneScript.new()
	var drone2 = CargoDroneScript.new()
	bay.register_drone(drone1)
	bay.register_drone(drone2)
	var idle = bay.get_idle_drones()
	assert_eq(idle.size(), 2, "All drones should be idle initially")


func test_dispatch_pending_assigns_tasks() -> void:
	var drone = CargoDroneScript.new()
	bay.register_drone(drone)
	queue.enqueue(DroneTaskQueueScript.TaskType.HAUL, "target_1", 0)

	bay.dispatch_pending()

	assert_eq(queue.active_tasks.size(), 1, "Should have active task")


func test_dispatch_pending_only_idle_drones() -> void:
	var drone1 = CargoDroneScript.new()
	var drone2 = CargoDroneScript.new()
	bay.register_drone(drone1)
	bay.register_drone(drone2)

	queue.enqueue(DroneTaskQueueScript.TaskType.HAUL, "target_1", 0)
	queue.assign_next(drone1)  # drone1 now busy

	bay.dispatch_pending()

	# Only drone2 should get assigned
	assert_eq(queue.active_tasks.size(), 1, "Only one task should be active")


func test_request_haul_enqueues_task() -> void:
	bay.request_haul(null, null, "common", 50, 0)
	assert_eq(queue.pending_tasks.size(), 1, "Should enqueue haul task")
	assert_eq(queue.pending_tasks[0].type, DroneTaskQueueScript.TaskType.HAUL, "Should be HAUL type")


func test_request_repair_enqueues_task() -> void:
	bay.request_repair(null, 5)
	assert_eq(queue.pending_tasks.size(), 1, "Should enqueue repair task")
	assert_eq(queue.pending_tasks[0].type, DroneTaskQueueScript.TaskType.REPAIR, "Should be REPAIR type")


func test_drone_registered_signal_fires() -> void:
	var signal_received = []
	bay.drone_registered.connect(func(drone):
		signal_received.append(drone)
	)
	var drone = CargoDroneScript.new()
	bay.register_drone(drone)
	assert_gt(signal_received.size(), 0, "Signal should fire on register")
	assert_eq(signal_received[0], drone, "Signal should pass drone")


func test_drone_dispatched_signal_fires() -> void:
	var signal_received = []
	bay.drone_dispatched.connect(func(drone, task):
		signal_received.append({"drone": drone, "task": task})
	)
	var drone = CargoDroneScript.new()
	bay.register_drone(drone)
	queue.enqueue(DroneTaskQueueScript.TaskType.HAUL, "target_1", 0)

	bay.dispatch_pending()

	assert_gt(signal_received.size(), 0, "Signal should fire on dispatch")


func test_idle_count_decreases_after_dispatch() -> void:
	var drone1 = CargoDroneScript.new()
	var drone2 = CargoDroneScript.new()
	bay.register_drone(drone1)
	bay.register_drone(drone2)

	assert_eq(bay.idle_count(), 2, "Should have 2 idle drones")

	queue.enqueue(DroneTaskQueueScript.TaskType.HAUL, "target_1", 0)
	bay.dispatch_pending()

	assert_eq(bay.idle_count(), 1, "Should have 1 idle drone after dispatch")
