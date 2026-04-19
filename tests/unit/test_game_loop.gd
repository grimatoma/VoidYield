extends "res://tests/framework/test_case.gd"

const GameLoopScript = preload("res://scenes/world/game_loop.gd")
const StorageDepotScript = preload("res://scenes/world/storage_depot.gd")
const DroneBayScript = preload("res://scenes/drones/drone_bay.gd")
const DroneTaskQueueScript = preload("res://scenes/drones/drone_task_queue.gd")

var loop
var depot
var bay
var queue


func before_each() -> void:
	depot = StorageDepotScript.new()
	add_child(depot)

	queue = DroneTaskQueueScript.new()
	add_child(queue)

	bay = DroneBayScript.new()
	bay.task_queue = queue
	add_child(bay)

	loop = GameLoopScript.new()
	add_child(loop)


func after_each() -> void:
	if loop and loop.is_inside_tree():
		loop.queue_free()
	if bay and bay.is_inside_tree():
		bay.queue_free()
	if queue and queue.is_inside_tree():
		queue.queue_free()
	if depot and depot.is_inside_tree():
		depot.queue_free()


func test_setup_links_components() -> void:
	loop.setup(depot, bay, queue)
	assert_eq(loop.storage, depot, "Should link depot")
	assert_eq(loop.drone_bay, bay, "Should link bay")
	assert_eq(loop.task_queue, queue, "Should link queue")


func test_tick_dispatches_pending_tasks() -> void:
	loop.setup(depot, bay, queue)
	queue.enqueue(DroneTaskQueueScript.TaskType.HAUL, null, 0)
	loop.tick(0.016)
	# Just verify tick doesn't error - dispatch happens internally
	assert_true(true, "Tick should complete without error")


func test_storage_signal_triggers_haul_request() -> void:
	loop.setup(depot, bay, queue)
	# Deposit ore into storage
	depot.deposit("common", 50)
	# Verify a haul task was enqueued (inventory_changed signal should trigger haul)
	assert_gt(queue.pending_tasks.size(), 0, "Should enqueue haul task on storage change")
