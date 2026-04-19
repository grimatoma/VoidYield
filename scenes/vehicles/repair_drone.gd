class_name RepairDrone
extends RefCounted
## Repair Drone — autonomous unit that repairs broken cargo ships (M13, tech 2.S).

const speed: float = 90.0
const carry_capacity: int = 0
const repair_cost_alloy: int = 5
const is_autonomous: bool = true

var position: Vector2 = Vector2.ZERO
var target_ship: CargoShip = null


func find_broken_ships(ships: Array) -> Array:
	var broken = []
	for ship in ships:
		if ship and ship.status == "BREAKDOWN":
			broken.append(ship)
	return broken


func repair_ship(ship: CargoShip) -> bool:
	if ship and ship.status == "BREAKDOWN":
		return ship.repair()
	return false


func move_toward(target: Vector2, delta: float) -> Vector2:
	var direction = (target - position).normalized()
	var movement = direction * speed * delta
	position += movement
	return movement
