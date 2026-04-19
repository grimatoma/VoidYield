class_name RepairDrone
extends Node2D

const REPAIR_RATE: float = 10.0
const MOVE_SPEED: float = 90.0

var target: Node = null
var is_repairing: bool = false


func start_repair(repair_target: Node) -> void:
	target = repair_target
	is_repairing = true


func tick_repair(delta: float) -> void:
	if not is_repairing or target == null:
		return

	if not target.has_method("get_health") or not target.has_method("get_max_health"):
		is_repairing = false
		return

	var current_health = target.get_health()
	var max_health = target.get_max_health()
	var healing = REPAIR_RATE * delta
	var new_health = min(current_health + healing, max_health)

	if target.has_method("set_health"):
		target.set_health(new_health)

	if new_health >= max_health:
		is_repairing = false
		target = null
