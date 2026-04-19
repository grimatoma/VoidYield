extends Node2D
class_name HarvesterBase
## HarvesterBase — the automated miner. Attaches to a DepositNode and extracts ore.

@export var base_ber: float = 1.0
@export var cycle_time: float = 10.0
@export var fuel_capacity: float = 100.0
@export var fuel_per_cycle: float = 5.0
@export var hopper_capacity: int = 50

var fuel_level: float = 100.0
var hopper_ore: int = 0
var upgrade_multiplier: float = 1.0
var linked_deposit = null  # DepositNode
var linked_depot = null  # StorageDepot
var _cycle_timer: float = 0.0
var is_running: bool = false

signal cycle_completed(ore_added: int)
signal hopper_collected(amount: int)


func link_deposit(deposit) -> void:
	linked_deposit = deposit
	is_running = fuel_level > 0 and hopper_ore < hopper_capacity


func link_depot(depot) -> void:
	linked_depot = depot


func tick(delta: float) -> void:
	if not is_running:
		return

	_cycle_timer += delta
	if _cycle_timer >= cycle_time:
		_run_cycle()
		_cycle_timer = 0.0


func _run_cycle() -> void:
	if linked_deposit == null:
		return
	if fuel_level < fuel_per_cycle:
		return
	if hopper_ore >= hopper_capacity:
		return

	fuel_level -= fuel_per_cycle

	var output = linked_deposit.ber_output(base_ber, linked_deposit.concentration, upgrade_multiplier)
	var ore_added = int(floor(output))
	hopper_ore += ore_added
	hopper_ore = min(hopper_ore, hopper_capacity)

	cycle_completed.emit(ore_added)


func collect_hopper() -> Dictionary:
	var amount = hopper_ore
	var ore_type = linked_deposit.ore_type if linked_deposit else "common"
	var amount_deposited = amount

	if linked_depot:
		amount_deposited = linked_depot.deposit(ore_type, amount)

	hopper_ore = 0
	hopper_collected.emit(amount)
	return {"ore_type": ore_type, "amount": amount_deposited}


func refuel(amount: float) -> void:
	fuel_level += amount
	fuel_level = min(fuel_level, fuel_capacity)


func is_full() -> bool:
	return hopper_ore >= hopper_capacity


func is_out_of_fuel() -> bool:
	return fuel_level < fuel_per_cycle
