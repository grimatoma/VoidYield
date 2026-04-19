extends "res://tests/framework/test_case.gd"
## TDD unit tests for the ConsumptionManager autoload.
## Covers: population tiers, needs, productivity multiplier, tier advancement.

func before_each() -> void:
	reset_game_state()
	# Reset ConsumptionManager to fresh state (Planet A1 only)
	ConsumptionManager.reset()


func after_each() -> void:
	ConsumptionManager.reset()


# --- Population Tiers ---

func test_initial_tier_is_pioneers() -> void:
	assert_eq(ConsumptionManager.get_tier("a1"), "pioneers", "Should start as Pioneers tier")


func test_pioneer_tier_default_population() -> void:
	var pop = ConsumptionManager.get_population_count("a1", "pioneers")
	assert_eq(pop, 4, "Pioneers should start with 4 crew")


func test_get_all_population_per_tier() -> void:
	var count = ConsumptionManager.get_total_population("a1")
	assert_eq(count, 4, "Total population should be 4 Pioneers")


# --- Consumption Rates ---

func test_pioneers_consume_compressed_gas() -> void:
	var rate = ConsumptionManager.get_consumption_rate("pioneers", "compressed_gas")
	assert_eq(rate, 2, "Each Pioneer consumes 2 Compressed Gas per day")


func test_pioneers_consume_water() -> void:
	var rate = ConsumptionManager.get_consumption_rate("pioneers", "water")
	assert_eq(rate, 1, "Each Pioneer consumes 1 Water per day")


func test_colonists_consume_processed_rations() -> void:
	var rate = ConsumptionManager.get_consumption_rate("colonists", "processed_rations")
	assert_eq(rate, 5, "Each Colonist consumes 5 Processed Rations per day")


func test_get_daily_demand() -> void:
	# 4 Pioneers: 4 * 2 = 8 Compressed Gas per day
	var demand = ConsumptionManager.get_daily_demand("a1", "compressed_gas")
	assert_eq(demand, 8, "4 Pioneers consume 8 Compressed Gas per day")


# --- Needs Satisfaction & Supply ---

func test_set_supply_percentage() -> void:
	ConsumptionManager.set_supply_percentage("a1", "compressed_gas", 100.0)
	var supply = ConsumptionManager.get_supply_percentage("a1", "compressed_gas")
	assert_eq(supply, 100.0, "Supply should be 100%")


func test_basic_needs_list_for_pioneers() -> void:
	var needs = ConsumptionManager.get_basic_needs("pioneers")
	assert_has(needs, "compressed_gas", "Compressed Gas is Pioneers basic need")
	assert_has(needs, "water", "Water is Pioneers basic need")
	assert_eq(needs.size(), 2, "Pioneers have 2 basic needs")


func test_luxury_needs_list_for_pioneers() -> void:
	var needs = ConsumptionManager.get_luxury_needs("pioneers")
	assert_has(needs, "processed_rations", "Processed Rations is Pioneers luxury need")
	assert_eq(needs.size(), 1, "Pioneers have 1 luxury need")


# --- Productivity Multiplier ---

func test_100_percent_supply_gives_full_multiplier() -> void:
	ConsumptionManager.set_supply_percentage("a1", "compressed_gas", 100.0)
	ConsumptionManager.set_supply_percentage("a1", "water", 100.0)
	var mult = ConsumptionManager.get_productivity_multiplier("a1")
	assert_eq(mult, 1.0, "100% supply = 1.0x multiplier")


func test_50_percent_supply_gives_reduced_multiplier() -> void:
	ConsumptionManager.set_supply_percentage("a1", "compressed_gas", 50.0)
	ConsumptionManager.set_supply_percentage("a1", "water", 100.0)
	var mult = ConsumptionManager.get_productivity_multiplier("a1")
	assert_eq(mult, 0.65, "50% supply = 0.65x multiplier")


func test_0_percent_supply_gives_minimum_multiplier() -> void:
	ConsumptionManager.set_supply_percentage("a1", "compressed_gas", 0.0)
	ConsumptionManager.set_supply_percentage("a1", "water", 0.0)
	var mult = ConsumptionManager.get_productivity_multiplier("a1")
	assert_eq(mult, 0.15, "0% supply = 0.15x multiplier")


func test_multiplier_uses_lowest_basic_need() -> void:
	# Lowest basic need determines multiplier
	ConsumptionManager.set_supply_percentage("a1", "compressed_gas", 100.0)
	ConsumptionManager.set_supply_percentage("a1", "water", 50.0)
	var mult = ConsumptionManager.get_productivity_multiplier("a1")
	assert_eq(mult, 0.65, "Should use lowest supply (water at 50%) for multiplier")


# --- Tier Advancement ---

func test_cannot_advance_without_luxury_needs_met() -> void:
	# Set basic needs to 100% but luxury to 0%
	ConsumptionManager.set_supply_percentage("a1", "compressed_gas", 100.0)
	ConsumptionManager.set_supply_percentage("a1", "water", 100.0)
	ConsumptionManager.set_supply_percentage("a1", "processed_rations", 0.0)

	var can_advance = ConsumptionManager.can_tier_advance("a1")
	assert_false(can_advance, "Should not advance without luxury needs met")


func test_can_advance_with_all_needs_met() -> void:
	# Set all needs (basic + luxury) to 100%
	ConsumptionManager.set_supply_percentage("a1", "compressed_gas", 100.0)
	ConsumptionManager.set_supply_percentage("a1", "water", 100.0)
	ConsumptionManager.set_supply_percentage("a1", "processed_rations", 100.0)

	var can_advance = ConsumptionManager.can_tier_advance("a1")
	assert_true(can_advance, "Should be able to advance when all needs met")


func test_tier_advancement_signal_fires() -> void:
	var captured := {"fired": false, "old_tier": "", "new_tier": ""}
	ConsumptionManager.tier_advanced.connect(func(planet: String, old: String, new: String):
		captured.fired = true
		captured.old_tier = old
		captured.new_tier = new
	)

	# Set all needs to 100%
	ConsumptionManager.set_supply_percentage("a1", "compressed_gas", 100.0)
	ConsumptionManager.set_supply_percentage("a1", "water", 100.0)
	ConsumptionManager.set_supply_percentage("a1", "processed_rations", 100.0)

	# Advance tier
	ConsumptionManager.advance_tier("a1")

	assert_true(captured.fired, "tier_advanced signal should fire")
	assert_eq(captured.old_tier, "pioneers", "old tier should be pioneers")
	assert_eq(captured.new_tier, "colonists", "new tier should be colonists")


func test_tier_sequence() -> void:
	# Advance through all tiers
	var current = ConsumptionManager.get_tier("a1")
	assert_eq(current, "pioneers")

	# Advance to colonists
	ConsumptionManager.set_all_needs("a1", 100.0)
	ConsumptionManager.advance_tier("a1")
	current = ConsumptionManager.get_tier("a1")
	assert_eq(current, "colonists", "Should advance to Colonists")

	# Advance to technicians
	ConsumptionManager.set_all_needs("a1", 100.0)
	ConsumptionManager.advance_tier("a1")
	current = ConsumptionManager.get_tier("a1")
	assert_eq(current, "technicians", "Should advance to Technicians")


# --- Persistence ---

func test_roundtrip_serialization() -> void:
	ConsumptionManager.set_supply_percentage("a1", "compressed_gas", 75.0)
	ConsumptionManager.set_supply_percentage("a1", "water", 90.0)

	var save_data = ConsumptionManager.get_save_data()

	# Reset and load
	ConsumptionManager.reset()
	ConsumptionManager.load_save_data(save_data)

	var supply = ConsumptionManager.get_supply_percentage("a1", "compressed_gas")
	assert_eq(supply, 75.0, "Should restore compressed_gas supply %")
