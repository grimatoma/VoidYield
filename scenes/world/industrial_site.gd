extends Node2D
class_name IndustrialSite
## IndustrialSite — a zone where factories/buildings can be placed with a hard slot limit.

@export var site_id: String = ""
@export var max_slots: int = 3

var _buildings: Array[Node] = []
var _building_slots: Dictionary = {}  # building -> slot_cost
var used_slots: int = 0

signal building_placed(building: Node)
signal building_removed(building: Node)


func can_place(slot_cost: int) -> bool:
	return used_slots + slot_cost <= max_slots


func place_building(building: Node, slot_cost: int) -> bool:
	if not can_place(slot_cost):
		return false

	_buildings.append(building)
	_building_slots[building] = slot_cost
	used_slots += slot_cost
	building_placed.emit(building)
	return true


func remove_building(building: Node) -> void:
	var index = _buildings.find(building)
	if index == -1:
		return

	_buildings.remove_at(index)
	var slot_cost = _building_slots.get(building, 0)
	_building_slots.erase(building)
	used_slots -= slot_cost
	building_removed.emit(building)


func free_slots() -> int:
	return max_slots - used_slots
