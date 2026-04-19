class_name RepairDrone
extends Node2D

const DRONE_TYPE = "repair"
const REPAIR_RATE: float = 10.0

var repair_target: Node = null

func start_repair(target: Node) -> void:
	repair_target = target

func tick_repair(delta: float) -> void:
	if repair_target and repair_target.has_meta("health"):
		var current_health = repair_target.get_meta("health")
		var new_health = current_health + REPAIR_RATE * delta
		repair_target.set_meta("health", new_health)
	elif repair_target and "health" in repair_target:
		repair_target.health += REPAIR_RATE * delta
