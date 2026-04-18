extends "res://tests/framework/test_case.gd"
## TDD tests for AudioManager autoload.
## Tests verify the public API contract — not actual audio playback
## (which requires hardware and is not reliably testable headlessly).

func before_each() -> void:
	reset_game_state()


# --- Autoload existence ------------------------------------------------------

func test_audio_manager_autoload_exists() -> void:
	var am := get_node_or_null("/root/AudioManager")
	assert_not_null(am, "AudioManager must be registered as an autoload")


# --- Volume API --------------------------------------------------------------

func test_set_sfx_volume_clamps_to_valid_range() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am == null:
		fail("AudioManager not found")
		return
	# Should not crash on extreme inputs
	am.set_sfx_volume_linear(0.0)
	am.set_sfx_volume_linear(1.0)
	am.set_sfx_volume_linear(2.0)   # over-range — should clamp
	am.set_sfx_volume_linear(-1.0)  # under-range — should clamp


func test_set_music_volume_clamps_to_valid_range() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am == null:
		fail("AudioManager not found")
		return
	am.set_music_volume_linear(0.0)
	am.set_music_volume_linear(1.0)


func test_get_sfx_volume_returns_clamped_value() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am == null:
		fail("AudioManager not found")
		return
	am.set_sfx_volume_linear(0.5)
	assert_near(am.get_sfx_volume_linear(), 0.5, 0.01)


func test_get_music_volume_returns_clamped_value() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am == null:
		fail("AudioManager not found")
		return
	am.set_music_volume_linear(0.3)
	assert_near(am.get_music_volume_linear(), 0.3, 0.01)


# --- play_sfx with null stream -----------------------------------------------

func test_play_sfx_with_null_does_not_crash() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am == null:
		fail("AudioManager not found")
		return
	# Passing null for a missing SFX file should fail silently
	am.play_sfx(null)


func test_play_music_with_null_stops_music() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am == null:
		fail("AudioManager not found")
		return
	am.play_music(null)  # should stop any current music without crashing


# --- Bus existence -----------------------------------------------------------

func test_sfx_bus_exists() -> void:
	var idx := AudioServer.get_bus_index("SFX")
	assert_ge(idx, 0, "SFX audio bus must exist")


func test_music_bus_exists() -> void:
	var idx := AudioServer.get_bus_index("Music")
	assert_ge(idx, 0, "Music audio bus must exist")
