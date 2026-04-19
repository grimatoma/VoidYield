extends "res://tests/framework/test_case.gd"
## TDD unit tests for the TechTree autoload.
## Covers: RP accumulation, unlocking, prerequisites, costs, persistence.

func before_each() -> void:
	reset_game_state()
	# Reset TechTree to fresh state
	TechTree.research_points = 0.0
	TechTree.unlocked_nodes.clear()


func after_each() -> void:
	TechTree.research_points = 0.0
	TechTree.unlocked_nodes.clear()


# --- RP Accumulation ---

func test_initial_rp_is_zero() -> void:
	assert_eq(TechTree.research_points, 0.0, "RP should start at 0")


func test_add_rp_increases_total() -> void:
	TechTree.add_rp(50.0)
	assert_eq(TechTree.research_points, 50.0, "RP should increase by 50")


func test_rp_changed_signal_fires() -> void:
	var captured := {"fired": false, "rp": 0.0}
	TechTree.rp_changed.connect(func(new_rp: float):
		captured.fired = true
		captured.rp = new_rp
	)
	TechTree.add_rp(30.0)
	assert_true(captured.fired, "rp_changed signal should fire")
	assert_eq(captured.rp, 30.0, "signal should carry new RP value")


# --- Unlock Conditions ---

func test_can_unlock_root_node_with_enough_resources() -> void:
	GameState.credits = 1000
	TechTree.add_rp(100.0)
	# "1.A" is a root node (requires=[]) with 50 RP + 200 CR cost
	assert_true(TechTree.can_unlock("1.A"), "should be able to unlock root node with enough resources")


func test_cannot_unlock_if_missing_prerequisite() -> void:
	GameState.credits = 1000
	TechTree.add_rp(500.0)  # plenty of RP
	# "1.B" requires "1.A", which is not unlocked
	assert_false(TechTree.can_unlock("1.B"), "should not unlock without prerequisite")


func test_cannot_unlock_if_insufficient_rp() -> void:
	GameState.credits = 1000
	TechTree.add_rp(30.0)  # not enough: 1.A costs 50 RP
	assert_false(TechTree.can_unlock("1.A"), "should not unlock with insufficient RP")


func test_cannot_unlock_if_insufficient_credits() -> void:
	TechTree.add_rp(100.0)  # plenty of RP
	GameState.credits = 10  # not enough: 1.A costs 50 CR
	assert_false(TechTree.can_unlock("1.A"), "should not unlock with insufficient credits")


# --- Unlock Action ---

func test_unlock_deducts_rp_and_credits() -> void:
	GameState.credits = 1000
	TechTree.add_rp(100.0)
	TechTree.unlock("1.A")  # costs 50 RP + 50 CR
	assert_eq(TechTree.research_points, 50.0, "RP should be deducted")
	assert_eq(GameState.credits, 950, "credits should be deducted")


func test_unlock_adds_to_unlocked_list() -> void:
	GameState.credits = 1000
	TechTree.add_rp(100.0)
	TechTree.unlock("1.A")
	assert_true("1.A" in TechTree.unlocked_nodes, "node should be in unlocked list")


func test_node_unlocked_signal_fires() -> void:
	GameState.credits = 1000
	TechTree.add_rp(100.0)
	var captured := {"fired": false, "id": ""}
	TechTree.node_unlocked.connect(func(node_id: String):
		captured.fired = true
		captured.id = node_id
	)
	TechTree.unlock("1.A")
	assert_true(captured.fired, "node_unlocked signal should fire")
	assert_eq(captured.id, "1.A", "signal should carry node ID")


func test_cannot_unlock_already_unlocked_node() -> void:
	GameState.credits = 1000
	TechTree.add_rp(200.0)
	TechTree.unlock("1.A")
	var credits_before = GameState.credits
	var rp_before = TechTree.research_points
	# Try to unlock again
	var result = TechTree.unlock("1.A")
	assert_false(result, "second unlock should return false")
	assert_eq(GameState.credits, credits_before, "credits should not be deducted twice")
	assert_eq(TechTree.research_points, rp_before, "RP should not be deducted twice")


# --- Prerequisite Chain ---

func test_prerequisite_chain_enforced() -> void:
	GameState.credits = 5000
	TechTree.add_rp(1000.0)

	# Without 1.A, cannot unlock 1.B
	assert_false(TechTree.can_unlock("1.B"), "cannot unlock 1.B without 1.A")

	# After unlocking 1.A, can unlock 1.B
	TechTree.unlock("1.A")
	assert_true(TechTree.can_unlock("1.B"), "can unlock 1.B after unlocking 1.A")

	# Unlock 1.B
	TechTree.unlock("1.B")
	assert_true(TechTree.can_unlock("1.C"), "can unlock 1.C after unlocking 1.B")


# --- Queries ---

func test_is_unlocked() -> void:
	GameState.credits = 1000
	TechTree.add_rp(100.0)
	assert_false(TechTree.is_unlocked("1.A"), "node not unlocked yet")
	TechTree.unlock("1.A")
	assert_true(TechTree.is_unlocked("1.A"), "node should be unlocked")


func test_get_node_data() -> void:
	var data = TechTree.get_node_data("1.A")
	assert_false(data.is_empty(), "should return node data")
	assert_eq(data.get("name"), "Drone Drill I", "should have correct name")
	assert_eq(data.get("rp_cost"), 50, "should have correct RP cost")
	assert_eq(data.get("cr_cost"), 50, "should have correct CR cost")


func test_get_node_data_invalid() -> void:
	var data = TechTree.get_node_data("invalid.node")
	assert_true(data.is_empty(), "should return empty dict for invalid node")


# --- Persistence ---

func test_roundtrip_serialization() -> void:
	GameState.credits = 1000
	TechTree.add_rp(100.0)
	TechTree.unlock("1.A")

	# Get save data
	var save_data = TechTree.get_save_data()
	assert_eq(save_data.get("rp"), 50.0, "should save remaining RP")
	assert_has(save_data.get("unlocked", []), "1.A", "should save unlocked nodes")

	# Reset and load
	TechTree.research_points = 0.0
	TechTree.unlocked_nodes.clear()
	TechTree.load_save_data(save_data)

	assert_eq(TechTree.research_points, 50.0, "should restore RP")
	assert_true(TechTree.is_unlocked("1.A"), "should restore unlocked state")
