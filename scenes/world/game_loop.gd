class_name GameLoop
extends Node

var storage: StorageDepot
var drone_bay: DroneBay
var task_queue: DroneTaskQueue


func setup(depot: StorageDepot, bay: DroneBay, queue: DroneTaskQueue) -> void:
	storage = depot
	drone_bay = bay
	task_queue = queue

	if storage:
		storage.inventory_changed.connect(_on_inventory_changed)


func tick(delta: float) -> void:
	if drone_bay:
		drone_bay.dispatch_pending()


func _on_inventory_changed(ore_type: String, amount: int) -> void:
	if drone_bay and storage:
		# Auto-enqueue haul task when storage receives ore
		# In a full implementation, this would check if factories need it
		drone_bay.request_haul(storage, null, ore_type, amount, 0)
