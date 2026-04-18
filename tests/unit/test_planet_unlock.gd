extends "res://tests/framework/test_case.gd"
## TDD tests for the planet unlock system in GameState.
## RED: All tests below FAIL until GameState gains unlocked_planets,
##      visited_planets, on_planet_visited(), and try_unlock_planet().

func before_each() -> void:
	reset_game_state()


# --- Starting state ----------------------------------------------------------

func test_asteroid_a1_starts_unlocked() -> void:
	assert_has(GameState.unlocked_planets, "asteroid_a1",
			"A1 must be accessible from the start")


func test_planet_b_starts_unlocked() -> void:
	assert_has(GameState.unlocked_planets, "planet_b",
			"A2 (Vortex Drift) must be accessible from the start")


func test_unknown_a3_starts_locked() -> void:
	assert_false("unknown_a3" in GameState.unlocked_planets,
			"A3 must be locked until the unlock condition is met")


# --- Visiting a planet -------------------------------------------------------

func test_visiting_a1_adds_to_visited_set() -> void:
	GameState.on_planet_visited("asteroid_a1")
	assert_has(GameState.visited_planets, "asteroid_a1")


func test_visiting_planet_b_adds_to_visited_set() -> void:
	GameState.on_planet_visited("planet_b")
	assert_has(GameState.visited_planets, "planet_b")


func test_visiting_planet_b_unlocks_a3() -> void:
	assert_false("unknown_a3" in GameState.unlocked_planets, "precondition: A3 locked")
	GameState.on_planet_visited("planet_b")
	assert_has(GameState.unlocked_planets, "unknown_a3",
			"visiting A2 should unlock A3")


func test_visiting_a1_does_not_unlock_a3() -> void:
	GameState.on_planet_visited("asteroid_a1")
	assert_false("unknown_a3" in GameState.unlocked_planets,
			"visiting A1 alone should not unlock A3")


# --- try_unlock_planet -------------------------------------------------------

func test_try_unlock_planet_returns_true_when_conditions_met() -> void:
	GameState.visited_planets.append("planet_b")
	var result := GameState.try_unlock_planet("unknown_a3")
	assert_true(result, "should succeed when condition is met")
	assert_has(GameState.unlocked_planets, "unknown_a3")


func test_try_unlock_planet_returns_false_when_already_unlocked() -> void:
	GameState.visited_planets.append("planet_b")
	GameState.try_unlock_planet("unknown_a3")
	var result := GameState.try_unlock_planet("unknown_a3")
	assert_false(result, "second call should return false (already unlocked)")


func test_try_unlock_planet_returns_false_when_conditions_not_met() -> void:
	var result := GameState.try_unlock_planet("unknown_a3")
	assert_false(result, "should fail when planet_b not yet visited")


# --- Signal emission ---------------------------------------------------------

func test_planet_unlocked_signal_fires_with_correct_id() -> void:
	var received: Array = []
	var handler := func(id: String): received.append(id)
	GameState.planet_unlocked.connect(handler)
	GameState.on_planet_visited("planet_b")
	GameState.planet_unlocked.disconnect(handler)
	assert_has(received, "unknown_a3",
			"planet_unlocked should emit with 'unknown_a3'")


func test_planet_unlocked_signal_not_emitted_if_already_unlocked() -> void:
	GameState.visited_planets.append("planet_b")
	GameState.unlocked_planets.append("unknown_a3")  # pre-unlock it
	var received: Array = []
	var handler := func(id: String): received.append(id)
	GameState.planet_unlocked.connect(handler)
	GameState.on_planet_visited("planet_b")  # already done
	GameState.planet_unlocked.disconnect(handler)
	assert_false("unknown_a3" in received,
			"signal should not fire for already-unlocked planet")


# --- Save / load roundtrip ---------------------------------------------------

func test_save_load_preserves_unlocked_planets() -> void:
	GameState.on_planet_visited("planet_b")  # unlocks A3
	assert_has(GameState.unlocked_planets, "unknown_a3")
	var data := GameState.get_save_data()
	reset_game_state()
	assert_false("unknown_a3" in GameState.unlocked_planets, "reset cleared it")
	GameState.load_save_data(data)
	assert_has(GameState.unlocked_planets, "unknown_a3",
			"A3 unlock should survive save/load roundtrip")


func test_save_load_preserves_visited_planets() -> void:
	GameState.on_planet_visited("asteroid_a1")
	GameState.on_planet_visited("planet_b")
	var data := GameState.get_save_data()
	reset_game_state()
	GameState.load_save_data(data)
	assert_has(GameState.visited_planets, "asteroid_a1")
	assert_has(GameState.visited_planets, "planet_b")


# --- Reset -------------------------------------------------------------------

func test_reset_restores_default_unlocked_planets() -> void:
	GameState.on_planet_visited("planet_b")
	assert_has(GameState.unlocked_planets, "unknown_a3")
	GameState.reset_to_defaults()
	assert_false("unknown_a3" in GameState.unlocked_planets,
			"reset should clear A3 unlock")
	assert_has(GameState.unlocked_planets, "asteroid_a1", "A1 always unlocked")
	assert_has(GameState.unlocked_planets, "planet_b",    "A2 always unlocked")


func test_reset_clears_visited_planets() -> void:
	GameState.on_planet_visited("planet_b")
	GameState.reset_to_defaults()
	assert_false("planet_b" in GameState.visited_planets,
			"reset should clear visited history")
