class_name RefineryDrone
extends Node2D
## A specialized drone that autonomously runs a FUEL→HAUL→REFUEL circuit

enum State { IDLE, MOVING_TO_DEPOSIT, HARVESTING, MOVING_TO_DEPOT, DELIVERING, REFUELING }

const MOVE_SPEED: float = 100.0
const FUEL_CAPACITY: float = 100.0
const FUEL_PER_TRIP: float = 20.0
const CARRY_CAPACITY: int = 20

var state: State = State.IDLE
var fuel_level: float = FUEL_CAPACITY
var carrying: int = 0
var cargo_type: String = ""
var assigned_deposit: Node = null
var assigned_depot: Node = null

signal state_changed(new_state: State)
signal circuit_completed(ore_type: String, amount: int)
signal fuel_low(current_fuel: float)


func assign_circuit(deposit: Node, depot: Node) -> void:
	assigned_deposit = deposit
	assigned_depot = depot
	_set_state(State.MOVING_TO_DEPOSIT)


func tick(delta: float) -> void:
	match state:
		State.MOVING_TO_DEPOSIT:
			_set_state(State.HARVESTING)
		State.HARVESTING:
			_do_harvest()
		State.MOVING_TO_DEPOT:
			_set_state(State.DELIVERING)
		State.DELIVERING:
			_do_deliver()
		State.REFUELING:
			_do_refuel()


func _do_harvest() -> void:
	if assigned_deposit and assigned_deposit.has_method("collect_ore"):
		var result = assigned_deposit.collect_ore(CARRY_CAPACITY)
		carrying = result.get("amount", 0)
		cargo_type = result.get("ore_type", "")

	if fuel_level < 30:
		fuel_low.emit(fuel_level)

	_set_state(State.MOVING_TO_DEPOT)


func _do_deliver() -> void:
	if assigned_depot and assigned_depot.has_method("deposit"):
		assigned_depot.deposit(cargo_type, carrying)

	var amount_delivered = carrying
	carrying = 0
	cargo_type = ""

	fuel_level -= FUEL_PER_TRIP
	fuel_level = max(fuel_level, 0.0)

	circuit_completed.emit(assigned_depot.name if assigned_depot else "", amount_delivered)

	if fuel_level < 30:
		_set_state(State.REFUELING)
	else:
		_set_state(State.IDLE)


func _do_refuel() -> void:
	fuel_level = FUEL_CAPACITY
	_set_state(State.IDLE)


func refuel(amount: float) -> void:
	fuel_level = minf(fuel_level + amount, FUEL_CAPACITY)


func get_state_name() -> String:
	match state:
		State.IDLE:
			return "IDLE"
		State.MOVING_TO_DEPOSIT:
			return "MOVING_TO_DEPOSIT"
		State.HARVESTING:
			return "HARVESTING"
		State.MOVING_TO_DEPOT:
			return "MOVING_TO_DEPOT"
		State.DELIVERING:
			return "DELIVERING"
		State.REFUELING:
			return "REFUELING"
		_:
			return "UNKNOWN"


func is_available() -> bool:
	return state == State.IDLE


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)
