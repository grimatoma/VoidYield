class_name VehicleBase
extends Node2D
## Base class for all vehicles (Rover, Speeder, Shuttle).
##
## Provides:
## - Movement and fuel consumption
## - Cargo capacity
## - Upgrade slots
## - Player enter/exit

signal player_entered(vehicle: VehicleBase)
signal player_exited(vehicle: VehicleBase, cargo_carried: int)
signal fuel_changed(current_fuel: float, max_fuel: float)
signal fuel_empty()

# --- Vehicle Stats (overridden per vehicle) ---
var vehicle_id: String = "vehicle_base"
var speed_px_per_sec: float = 0.0  # Override per vehicle
var carry_bonus: int = 0  # Override per vehicle
var fuel_type: String = "gas"  # "gas" or "rocket_fuel"
var fuel_tank_capacity: float = 0.0  # Override per vehicle
var fuel_consumption_rate: float = 0.1  # units per second while moving

# --- Runtime State ---
var current_fuel: float = 0.0
var current_speed: float = 0.0  # Current movement speed (0 to speed_px_per_sec)
var is_moving: bool = false
var player_inside: bool = false
var carried_cargo: int = 0  # Cargo items currently in vehicle

# --- Upgrades ---
var installed_upgrades: Dictionary = {}  # upgrade_id → count

# --- Survey Mount (Speeder only) ---
var has_survey_mount: bool = false
var can_scan_while_moving: bool = false


func _ready() -> void:
	# Start with full fuel tank
	current_fuel = fuel_tank_capacity


func _process(delta: float) -> void:
	if not player_inside or not is_moving:
		return

	# Consume fuel while moving
	if current_fuel > 0:
		current_fuel -= fuel_consumption_rate * delta
		if current_fuel < 0:
			current_fuel = 0
			_on_fuel_empty()
		fuel_changed.emit(current_fuel, fuel_tank_capacity)


# --- Movement ---

func drive(direction: Vector2, speed_fraction: float = 1.0) -> void:
	"""Drive in a direction at a speed fraction (0.0–1.0)."""
	if not player_inside or current_fuel <= 0:
		return

	current_speed = speed_px_per_sec * clampf(speed_fraction, 0.0, 1.0)
	is_moving = current_speed > 0
	position += direction.normalized() * current_speed * get_physics_process_delta_time()


func stop() -> void:
	"""Stop moving."""
	current_speed = 0.0
	is_moving = false


# --- Fuel Management ---

func refuel(amount: float) -> float:
	"""Add fuel, up to capacity. Returns amount actually added."""
	var space = fuel_tank_capacity - current_fuel
	var added = minf(amount, space)
	current_fuel += added
	fuel_changed.emit(current_fuel, fuel_tank_capacity)
	return added


func is_fuel_low() -> bool:
	"""Returns true if fuel is below 25% of tank."""
	return current_fuel < (fuel_tank_capacity * 0.25)


func _on_fuel_empty() -> void:
	"""Called when fuel runs out."""
	stop()
	fuel_empty.emit()


# --- Cargo ---

func add_cargo(amount: int) -> int:
	"""Add cargo items. Returns amount actually added (clamped by capacity)."""
	var capacity = GameState.player_max_carry + carry_bonus
	var space = capacity - carried_cargo
	var added = mini(amount, space)
	carried_cargo += added
	return added


func remove_cargo(amount: int) -> int:
	"""Remove cargo items. Returns amount actually removed."""
	var removed = mini(amount, carried_cargo)
	carried_cargo -= removed
	return removed


func get_cargo() -> int:
	"""Get current cargo count."""
	return carried_cargo


func get_cargo_capacity() -> int:
	"""Get total cargo capacity (player carry + vehicle bonus)."""
	return GameState.player_max_carry + carry_bonus


# --- Player Entry/Exit ---

func player_enter() -> void:
	"""Player enters the vehicle."""
	player_inside = true
	player_entered.emit(self)


func player_exit() -> void:
	"""Player exits the vehicle."""
	stop()
	player_inside = false
	player_exited.emit(self, carried_cargo)


# --- Upgrades ---

func install_upgrade(upgrade_id: String) -> bool:
	"""Install an upgrade (if supported by this vehicle). Returns success."""
	# Override in subclass if vehicle has upgrade slots
	return false


func has_upgrade(upgrade_id: String) -> bool:
	"""Check if an upgrade is installed."""
	return upgrade_id in installed_upgrades


# --- Survey Mount (Speeder only) ---

func supports_survey_mount() -> bool:
	"""Override in Speeder."""
	return false


func install_survey_mount() -> bool:
	"""Install Vehicle Survey Mount (Speeder only)."""
	if not supports_survey_mount():
		return false
	has_survey_mount = true
	can_scan_while_moving = true
	return true


func can_perform_full_scan_now() -> bool:
	"""Check if Full Scan is possible right now (for survey mount feature)."""
	if not has_survey_mount:
		return false
	# Can only scan while moving at ≤50 px/sec
	return current_speed <= 50.0


# --- Persistence ---

func get_save_data() -> Dictionary:
	return {
		"vehicle_id": vehicle_id,
		"fuel": current_fuel,
		"carried_cargo": carried_cargo,
		"upgrades": installed_upgrades.duplicate(),
		"has_survey_mount": has_survey_mount,
	}


func load_save_data(data: Dictionary) -> void:
	current_fuel = data.get("fuel", fuel_tank_capacity)
	carried_cargo = data.get("carried_cargo", 0)
	installed_upgrades = data.get("upgrades", {})
	has_survey_mount = data.get("has_survey_mount", false)
	can_scan_while_moving = has_survey_mount
