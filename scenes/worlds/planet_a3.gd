class_name PlanetA3
extends Node2D
## Planet A3 — Void Nexus, home of Warp Gate and Galactic Hub (M14).

const WORLD_WIDTH: int = 3200
const WORLD_HEIGHT: int = 2400
const SITE_COUNT: int = 6
const background_color: String = "#1a0f2e"

var _industrial_sites: Array = []
var _ore_deposits: Array = []


func _ready() -> void:
	_initialize_world()


func _initialize_world() -> void:
	# Create dark void-touched background
	var bg = ColorRect.new()
	bg.color = Color(background_color)
	bg.size = Vector2(WORLD_WIDTH, WORLD_HEIGHT)
	add_child(bg)

	# Create 6 Industrial Sites for A3
	_create_industrial_sites()

	# Create diverse ore deposits (all 5 types: Vorax, Krysite, Aethite, Voidstone, Gas)
	_create_ore_deposits()

	# Mark Warp Gate placement zone
	_create_warp_gate_zone()

	# Mark Galactic Hub placement zone
	_create_galactic_hub_zone()


func _create_industrial_sites() -> void:
	var positions = [
		Vector2(400, 600),
		Vector2(1600, 400),
		Vector2(2800, 600),
		Vector2(400, 1800),
		Vector2(1600, 2000),
		Vector2(2800, 1800),
	]

	for pos in positions:
		var site = {
			"position": pos,
			"site_id": "a3_s%d" % _industrial_sites.size(),
			"is_occupied": false,
		}
		_industrial_sites.append(site)


func _create_ore_deposits() -> void:
	# Diverse ore distribution: all 5 types with higher variance
	var ore_types = ["vorax", "krysite", "aethite", "voidstone", "gas"]

	for i in range(15):
		var ore_type = ore_types[i % 5]
		var deposit = {
			"position": Vector2(randf_range(200, WORLD_WIDTH - 200), randf_range(200, WORLD_HEIGHT - 200)),
			"ore_type": ore_type,
			"oq": randf_range(300, 950),  # Higher variance, wider range
			"concentration": randf_range(50, 100),
			"yield_remaining": randi_range(150, 300),
		}
		_ore_deposits.append(deposit)


func _create_warp_gate_zone() -> void:
	# Central position for Warp Gate
	var gate_zone = ColorRect.new()
	gate_zone.color = Color.TRANSPARENT
	gate_zone.position = Vector2(1400, 1000)
	gate_zone.size = Vector2(200, 200)
	gate_zone.add_to_group("warp_gate_zone")
	add_child(gate_zone)


func _create_galactic_hub_zone() -> void:
	# Eastern position for Galactic Hub
	var hub_zone = ColorRect.new()
	hub_zone.color = Color.TRANSPARENT
	hub_zone.position = Vector2(2400, 1600)
	hub_zone.size = Vector2(300, 300)
	hub_zone.add_to_group("galactic_hub_zone")
	add_child(hub_zone)


func get_industrial_sites() -> Array:
	return _industrial_sites


func get_ore_deposits() -> Array:
	return _ore_deposits


func get_ferrovoid_deposits() -> Array:
	# A3-exclusive ore with higher OQ and unique attributes
	var ferrovoid = []
	for deposit in _ore_deposits:
		if deposit["oq"] > 850:  # High-quality deposits can be Ferrovoid
			ferrovoid.append(deposit)
	return ferrovoid
