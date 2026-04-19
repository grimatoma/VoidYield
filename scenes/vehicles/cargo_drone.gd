class_name CargoDrone
extends RefCounted
## Cargo Drone — shuttles cargo between nodes via Freight Lanes (M13, tech 3.R).

const speed: float = 35.0
const carry_capacity: int = 20
const fuel_type: String = "none"

var position: Vector2 = Vector2.ZERO
var cargo_amount: int = 0
var source_node: Node = null
var destination_node: Node = null
var is_in_lane: bool = false


func execute_freight_lane(source: Node, destination: Node) -> bool:
	if source and destination:
		source_node = source
		destination_node = destination
		is_in_lane = true
		return true
	return false


func pickup_cargo(amount: int) -> int:
	var picked_up = mini(amount, carry_capacity - cargo_amount)
	cargo_amount += picked_up
	return picked_up


func drop_cargo(amount: int = cargo_amount) -> int:
	var dropped = mini(amount, cargo_amount)
	cargo_amount -= dropped
	return dropped


func move_toward(target: Vector2, delta: float) -> Vector2:
	var direction = (target - position).normalized()
	var movement = direction * speed * delta
	position += movement
	return movement


func is_at_capacity() -> bool:
	return cargo_amount >= carry_capacity


func is_empty() -> bool:
	return cargo_amount == 0
