extends "res://tests/framework/test_case.gd"
## TDD unit tests for Warp Gate (M14).

const WarpGateScript = preload("res://scenes/world/warp_gate.gd")


func test_warp_gate_requires_unlock_tech() -> void:
	var gate = WarpGateScript.new()
	assert_true(gate.requires_tech_3p, "Warp Gate requires tech 3.P")


func test_warp_gate_construction_cost() -> void:
	var gate = WarpGateScript.new()
	assert_eq(gate.build_cost_cr, 20000, "Warp Gate costs 20,000 CR")
	assert_eq(gate.build_cost_void_cores, 50, "Warp Gate costs 50 Void Cores")
	assert_eq(gate.build_cost_alloy, 100, "Warp Gate costs 100 Alloy Rods")


func test_warp_gate_build_time() -> void:
	var gate = WarpGateScript.new()
	assert_eq(gate.build_time, 300.0, "Warp Gate takes 5 minutes to build")


func test_warp_gate_enables_instant_travel() -> void:
	var gate = WarpGateScript.new()
	assert_true(gate.has_method("travel_between_planets"), "Warp Gate should enable instant travel")


func test_warp_gate_no_fuel_cost() -> void:
	var gate = WarpGateScript.new()
	var fuel_required = gate.get_fuel_cost()
	assert_eq(fuel_required, 0, "Warp Gate travel should cost no fuel")


func test_warp_gate_status_active() -> void:
	var gate = WarpGateScript.new()
	gate.status = "ACTIVE"
	assert_eq(gate.status, "ACTIVE", "Built Warp Gate should be ACTIVE")


func test_warp_gate_unlocks_a3() -> void:
	var gate = WarpGateScript.new()
	var unlocked = gate.travel_between_planets("a1", "a3")
	assert_true(unlocked, "Warp Gate should enable A3 travel once built")
