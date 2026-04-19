class_name A2Depot
extends RefCounted
## Gas depot on A2 asteroid. Stores 200 RF, regenerates 5 RF/hr.

const MAX_FUEL = 200.0
const REGEN_RATE = 5.0 / 3600.0  # 5 RF per hour (per second)

var rocket_fuel_current: float = 200.0


func tick(delta: float) -> void:
	rocket_fuel_current = minf(rocket_fuel_current + REGEN_RATE * delta, MAX_FUEL)


func refuel(amount: float) -> float:
	var refueled = minf(amount, MAX_FUEL - rocket_fuel_current)
	rocket_fuel_current += refueled
	return refueled
