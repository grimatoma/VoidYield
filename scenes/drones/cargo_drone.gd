class_name CargoDrone
extends Node2D

const DRONE_TYPE = "cargo"
const CARRY_CAPACITY: int = 20

var carrying: int = 0
var carrying_type: String = ""

func pickup(amount: int, ore_type: String) -> int:
	var space_available = CARRY_CAPACITY - carrying
	var to_pickup = min(amount, space_available)
	carrying += to_pickup
	carrying_type = ore_type
	return to_pickup

func deliver() -> Dictionary:
	var result = {
		"type": carrying_type,
		"amount": carrying
	}
	carrying = 0
	carrying_type = ""
	return result
