class_name StorageDepot
extends Node2D

var _inventory: Dictionary = {}
var capacity: int = 500

signal inventory_changed(type: String, amount: int)
signal capacity_reached()


func deposit(type: String, amount: int) -> int:
	var free = free_space()
	var to_deposit = min(amount, free)
	_inventory[type] = _inventory.get(type, 0) + to_deposit
	inventory_changed.emit(type, to_deposit)
	if total_stored() >= capacity:
		capacity_reached.emit()
	return to_deposit


func withdraw(type: String, amount: int) -> int:
	var current = _inventory.get(type, 0)
	var to_withdraw = min(amount, current)
	_inventory[type] = current - to_withdraw
	if _inventory[type] == 0:
		_inventory.erase(type)
	inventory_changed.emit(type, to_withdraw)
	return to_withdraw


func get_amount(type: String) -> int:
	return _inventory.get(type, 0)


func total_stored() -> int:
	var total = 0
	for amount in _inventory.values():
		total += amount
	return total


func free_space() -> int:
	return capacity - total_stored()


func has_enough(type: String, amount: int) -> bool:
	return get_amount(type) >= amount
