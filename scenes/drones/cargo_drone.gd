class_name CargoDrone
extends Node2D

const CARRY_CAPACITY: int = 20

var carrying: int = 0
var cargo_type: String = ""


func pickup(amount: int, ore_type: String) -> int:
	var space_available = CARRY_CAPACITY - carrying
	var to_pickup = min(amount, space_available)
	carrying += to_pickup
	cargo_type = ore_type
	return to_pickup


func deliver() -> Dictionary:
	var result = {
		"amount": carrying,
		"ore_type": cargo_type
	}
	carrying = 0
	cargo_type = ""
	return result
