extends "res://tests/framework/test_case.gd"
## Unit tests for colony tier advancement.

const ColonyTierScript = preload("res://autoloads/colony_tiers.gd")


func test_colony_starts_as_pioneers() -> void:
	var colony = ColonyTierScript.new()
	assert_eq(colony.current_tier, "pioneer", "Should start as pioneers")


func test_colony_tier_has_required_needs() -> void:
	var colony = ColonyTierScript.new()
	var needs = colony.get_tier_needs("pioneer")
	assert_has(needs, "basic", "Tier should have basic needs")
	assert_has(needs, "luxury", "Tier should have luxury needs")


func test_colony_can_advance_to_colonist() -> void:
	var colony = ColonyTierScript.new()
	# Pioneers need 100% luxury for 10 min. Simplified test: just call advance
	colony.advance_tier()
	assert_eq(colony.current_tier, "colonist", "Should advance to colonist tier")


func test_colonist_tier_needs() -> void:
	var colony = ColonyTierScript.new()
	colony.advance_tier()
	var needs = colony.get_tier_needs("colonist")
	# Colonists: Basic = Rations + Gas + Water; Luxury = Power Cells
	assert_has(needs["basic"], "rations", "Colonists should need rations")
	assert_has(needs["basic"], "gas", "Colonists should need gas")
	assert_has(needs["basic"], "water", "Colonists should need water")


func test_technician_tier_needs() -> void:
	var colony = ColonyTierScript.new()
	colony.current_tier = "technician"  # Jump for test
	var needs = colony.get_tier_needs("technician")
	# Technicians: Basic = Power Cells + Rations + Gas; Luxury = Bio-Circuit Boards
	assert_has(needs["basic"], "power_cell", "Technicians should need power cells")


func test_colony_tier_count() -> void:
	var colony = ColonyTierScript.new()
	var tiers = colony.get_all_tiers()
	assert_eq(tiers.size(), 5, "Should have 5 tiers: pioneer, colonist, technician, engineer, director")
