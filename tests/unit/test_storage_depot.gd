extends "res://tests/framework/test_case.gd"

const StorageDepotScript = preload("res://scenes/world/storage_depot.gd")

var depot


func before_each() -> void:
	depot = StorageDepotScript.new()
	add_child(depot)


func after_each() -> void:
	if depot and depot.is_inside_tree():
		depot.queue_free()


func test_initial_empty() -> void:
	assert_eq(depot.total_stored(), 0, "Should start empty")


func test_deposit_adds_ore() -> void:
	var deposited = depot.deposit("common", 50)
	assert_eq(deposited, 50, "Should deposit ore")
	assert_eq(depot.get_amount("common"), 50, "Should store ore")


func test_deposit_returns_actual_deposited() -> void:
	var deposited = depot.deposit("rare", 100)
	assert_eq(deposited, 100, "Should return actual deposited")


func test_deposit_capped_at_capacity() -> void:
	var deposited = depot.deposit("common", 600)
	assert_eq(deposited, 500, "Should cap at capacity")
	assert_eq(depot.total_stored(), 500, "Should be full")


func test_deposit_mixed_types() -> void:
	depot.deposit("common", 200)
	depot.deposit("rare", 150)
	assert_eq(depot.get_amount("common"), 200, "Should store common")
	assert_eq(depot.get_amount("rare"), 150, "Should store rare")
	assert_eq(depot.total_stored(), 350, "Should sum all types")


func test_withdraw_removes_ore() -> void:
	depot.deposit("common", 100)
	var withdrawn = depot.withdraw("common", 30)
	assert_eq(withdrawn, 30, "Should withdraw ore")
	assert_eq(depot.get_amount("common"), 70, "Should reduce amount")


func test_withdraw_returns_actual_withdrawn() -> void:
	depot.deposit("rare", 50)
	var withdrawn = depot.withdraw("rare", 100)
	assert_eq(withdrawn, 50, "Should return actual withdrawn")
	assert_eq(depot.get_amount("rare"), 0, "Should be empty")


func test_withdraw_clamped_to_available() -> void:
	depot.deposit("common", 25)
	var withdrawn = depot.withdraw("common", 40)
	assert_eq(withdrawn, 25, "Should clamp to available")


func test_get_amount_returns_zero_for_unknown() -> void:
	assert_eq(depot.get_amount("unknown"), 0, "Should return 0 for unknown type")


func test_total_stored_sums_all() -> void:
	depot.deposit("common", 100)
	depot.deposit("rare", 50)
	depot.deposit("aethite", 75)
	assert_eq(depot.total_stored(), 225, "Should sum all types")


func test_free_space_decreases_on_deposit() -> void:
	assert_eq(depot.free_space(), 500, "Should start with full capacity")
	depot.deposit("common", 200)
	assert_eq(depot.free_space(), 300, "Should reduce by deposited amount")


func test_has_enough_true_when_sufficient() -> void:
	depot.deposit("steel_bar", 10)
	assert_true(depot.has_enough("steel_bar", 5), "Should have enough")


func test_has_enough_false_when_insufficient() -> void:
	depot.deposit("steel_bar", 5)
	assert_false(depot.has_enough("steel_bar", 10), "Should not have enough")


func test_inventory_changed_signal_on_deposit() -> void:
	var signal_received = []
	depot.inventory_changed.connect(func(t, a):
		signal_received.append({"type": t, "amount": a})
	)
	depot.deposit("common", 50)
	assert_gt(signal_received.size(), 0, "Signal should fire on deposit")
	assert_eq(signal_received[0].type, "common", "Should pass ore type")
	assert_eq(signal_received[0].amount, 50, "Should pass amount")


func test_inventory_changed_signal_on_withdraw() -> void:
	depot.deposit("rare", 100)
	var signal_received = []
	depot.inventory_changed.connect(func(t, a):
		signal_received.append({"type": t, "amount": a})
	)
	depot.withdraw("rare", 30)
	assert_gt(signal_received.size(), 0, "Signal should fire on withdraw")
	assert_eq(signal_received[0].type, "rare", "Should pass ore type")
	assert_eq(signal_received[0].amount, 30, "Should pass amount withdrawn")


func test_capacity_reached_signal_when_full() -> void:
	var signal_received = []
	depot.capacity_reached.connect(func():
		signal_received.append(true)
	)
	depot.deposit("common", 500)
	assert_gt(signal_received.size(), 0, "Should emit capacity_reached when full")
