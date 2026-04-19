class_name PlanetC
extends Node2D
## Planet C (Rift world) with void-touched ore and shifting deposits (M13).

const WORLD_WIDTH: int = 4000
const WORLD_HEIGHT: int = 3000
const SITE_COUNT: int = 18
const GEYSER_COUNT: int = 8
const background_color: String = "#3a2d5e"

var _void_touched_deposits: Array = []
var _resonance_formations: Array = []
var _dark_gas_geysers: Array = []
var _shift_timer: float = 0.0
var _shift_interval: float = randf_range(120.0, 240.0)  # 2-4 in-game minutes

signal deposits_shifted


func _ready() -> void:
	_initialize_world()


func _initialize_world() -> void:
	# Create background
	var bg = ColorRect.new()
	bg.color = Color(background_color)
	bg.size = Vector2(WORLD_WIDTH, WORLD_HEIGHT)
	add_child(bg)

	# Create 18 Industrial Sites (6 per region)
	_create_industrial_sites()

	# Create Void-Touched Ore deposits (scattered, quality 150-950)
	_create_void_touched_deposits()

	# Create 6 Resonance Crystal formations
	_create_resonance_formations()

	# Create 8 Dark Gas Geysers
	_create_dark_gas_geysers()


func _create_industrial_sites() -> void:
	# Western region: 6 sites
	var western_positions = [
		Vector2(400, 400), Vector2(400, 1200), Vector2(400, 2200),
		Vector2(800, 700), Vector2(800, 1500), Vector2(800, 2400)
	]
	for pos in western_positions:
		_create_industrial_site(pos)

	# Rift region: 6 sites
	var rift_positions = [
		Vector2(2000, 300), Vector2(2000, 1000), Vector2(2000, 1800),
		Vector2(2000, 2600), Vector2(1800, 1400), Vector2(2200, 1400)
	]
	for pos in rift_positions:
		_create_industrial_site(pos)

	# Eastern region: 6 sites
	var eastern_positions = [
		Vector2(3600, 400), Vector2(3600, 1200), Vector2(3600, 2200),
		Vector2(3200, 700), Vector2(3200, 1500), Vector2(3200, 2400)
	]
	for pos in eastern_positions:
		_create_industrial_site(pos)


func _create_industrial_site(pos: Vector2) -> void:
	var site = IndustrialSite.new()
	site.position = pos
	_void_touched_deposits.append(site)


func _create_void_touched_deposits() -> void:
	# Create deposits across the map with randomized OQ (150-950)
	for i in range(12):
		var x = randf_range(100, WORLD_WIDTH - 100)
		var y = randf_range(100, WORLD_HEIGHT - 100)
		var deposit = _create_deposit(Vector2(x, y))
		_void_touched_deposits.append(deposit)


func _create_deposit(pos: Vector2) -> Dictionary:
	return {
		"position": pos,
		"ore_type": "void_touched",
		"oq": randf_range(150, 950),
		"concentration": randf_range(40, 95),
		"yield_remaining": randi_range(80, 200)
	}


func _create_resonance_formations() -> void:
	# 6 Resonance Crystal formations
	var formation_positions = [
		Vector2(500, 800),
		Vector2(1000, 1800),
		Vector2(1500, 2400),
		Vector2(2500, 600),
		Vector2(3200, 1400),
		Vector2(3600, 2300)
	]

	for pos in formation_positions:
		var formation = {
			"position": pos,
			"type": "resonance_crystal",
			"crack_cycles": randi_range(3, 5),
			"yield": randi_range(15, 30)
		}
		_resonance_formations.append(formation)


func _create_dark_gas_geysers() -> void:
	# 8 fixed Dark Gas Geyser positions
	var geyser_positions = [
		Vector2(800, 500),
		Vector2(1200, 1000),
		Vector2(1800, 1500),
		Vector2(2400, 600),
		Vector2(2800, 2000),
		Vector2(3200, 800),
		Vector2(3600, 1800),
		Vector2(3000, 2800)
	]

	for pos in geyser_positions:
		var geyser = {
			"position": pos,
			"type": "dark_gas_geyser",
			"eruption_rate": randf_range(0.1, 0.2),  # ~1 per 5-10 seconds
			"yield_per_eruption": randi_range(5, 15)
		}
		_dark_gas_geysers.append(geyser)


func _physics_process(delta: float) -> void:
	_shift_timer += delta

	if _shift_timer >= _shift_interval:
		trigger_deposit_shift()
		_shift_timer = 0.0
		_shift_interval = randf_range(120.0, 240.0)


func trigger_deposit_shift() -> void:
	# Shift all void-touched deposits' concentration ±30%
	for deposit in _void_touched_deposits:
		if deposit is Dictionary and "concentration" in deposit:
			var shift = randf_range(-30, 30)
			deposit["concentration"] = clampf(deposit["concentration"] + shift, 10, 100)

	deposits_shifted.emit()


func get_void_touched_deposits() -> Array:
	return _void_touched_deposits.filter(func(d): return d is Dictionary and d.get("ore_type") == "void_touched")


func get_resonance_formations() -> Array:
	return _resonance_formations


func has_standard_gas_deposits() -> bool:
	return false


class IndustrialSite:
	var position: Vector2 = Vector2.ZERO
	var site_id: String = ""
	var is_occupied: bool = false
