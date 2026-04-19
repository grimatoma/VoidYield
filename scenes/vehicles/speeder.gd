class_name Speeder
extends RefCounted
## High-speed vehicle with survey mount capability. Speed 520 px/s, carry +10, fuel 20 gas (M12).

const speed: float = 520.0
const carry_bonus: int = 10
const fuel_type: String = "gas"
const fuel_capacity: int = 20

var fuel_current: float = 0.0
var is_drivable: bool = true


func move(direction_velocity: Vector2, delta: float) -> Vector2:
	if fuel_current <= 0:
		return Vector2.ZERO

	var distance = direction_velocity.length()
	var duration = distance / speed if speed > 0 else 0
	var fuel_cost = duration * (fuel_capacity / 60.0)

	if fuel_cost > fuel_current:
		fuel_cost = fuel_current
		duration = fuel_cost / (fuel_capacity / 60.0) if (fuel_capacity / 60.0) > 0 else 0

	fuel_current -= fuel_cost
	return direction_velocity.normalized() * speed * delta


func refuel(amount: int) -> void:
	fuel_current = minf(fuel_current + amount, fuel_capacity)
