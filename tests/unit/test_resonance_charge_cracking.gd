extends "res://tests/framework/test_case.gd"
## TDD unit tests for Resonance Charge Cracking (M13).

const CrystalHarvesterScript = preload("res://scenes/world/crystal_harvester.gd")


func test_crystal_harvester_placed_at_formation() -> void:
	var harvester = CrystalHarvesterScript.new()
	var formation_pos = Vector2(2000, 1500)

	harvester.formation_position = formation_pos
	assert_eq(harvester.formation_position, formation_pos, "Harvester should be placed at formation")


func test_resonance_charge_consumption() -> void:
	var harvester = CrystalHarvesterScript.new()
	harvester.charges_available = 10

	harvester.use_charge()
	assert_eq(harvester.charges_available, 9, "Charge should be consumed")


func test_crack_yields_shards() -> void:
	var harvester = CrystalHarvesterScript.new()
	var shards = harvester.crack_formation()

	assert_gt(shards, 0, "Cracking should yield resonance shards")
	assert_le(shards, 5, "Crack should yield 1-5 shards")


func test_formation_is_finite() -> void:
	var harvester = CrystalHarvesterScript.new()
	harvester.remaining_crack_cycles = 3

	harvester.crack_formation()
	assert_lt(harvester.remaining_crack_cycles, 3, "Crack cycles should decrease")


func test_formation_depletes() -> void:
	var harvester = CrystalHarvesterScript.new()
	harvester.remaining_crack_cycles = 1

	harvester.crack_formation()
	assert_eq(harvester.remaining_crack_cycles, 0, "Formation should deplete")


func test_harvester_cannot_crack_depleted_formation() -> void:
	var harvester = CrystalHarvesterScript.new()
	harvester.remaining_crack_cycles = 0

	var result = harvester.crack_formation()
	assert_eq(result, 0, "Depleted formation should yield 0 shards")
