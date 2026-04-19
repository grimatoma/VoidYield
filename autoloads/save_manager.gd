extends Node
## SaveManager — Versioned serialization with two slots.
##   SLOT_MAIN  — written on explicit save() and on "Save & Quit"
##   SLOT_AUTO  — written every 60 s automatically (never overwrites SLOT_MAIN)
##
## Version bump intentionally wipes incompatible saves rather than crashing.

const SAVE_VERSION       := "0.2"
const SLOT_MAIN_PATH     := "user://save.json"
const SLOT_AUTO_PATH     := "user://save_auto.json"
const AUTO_SAVE_INTERVAL := 60.0
const SAVE_COOLDOWN      := 5.0

var _auto_save_timer: float = 0.0
var _cooldown_timer:  float = SAVE_COOLDOWN  # start ready so first explicit save fires immediately


func _ready() -> void:
	if not GameState.debug_click_mode:
		load_game()
	else:
		print("[SaveManager] Debug mode — skipping save load.")


func _process(delta: float) -> void:
	_auto_save_timer += delta
	_cooldown_timer  += delta
	if _auto_save_timer >= AUTO_SAVE_INTERVAL:
		_auto_save_timer = 0.0
		_write_slot(SLOT_AUTO_PATH)  # autosave: no cooldown check, separate slot


# --- Public API (callers outside this file use only these) ---

func save_game() -> void:
	## Throttled manual save — silently skips if called within SAVE_COOLDOWN.
	if _cooldown_timer < SAVE_COOLDOWN:
		return
	_cooldown_timer = 0.0
	_write_slot(SLOT_MAIN_PATH)


func save_game_immediate() -> void:
	## Force save bypassing cooldown (pause menu, "Save & Quit").
	## Resets cooldown so the next regular save can still fire normally.
	_cooldown_timer = SAVE_COOLDOWN
	_write_slot(SLOT_MAIN_PATH)


func load_game() -> void:
	if not FileAccess.file_exists(SLOT_MAIN_PATH):
		print("[SaveManager] No save file — starting fresh.")
		return
	var payload := _read_slot(SLOT_MAIN_PATH)
	if not payload.is_empty():
		_apply_payload(payload)


func delete_save() -> void:
	for path in [SLOT_MAIN_PATH, SLOT_AUTO_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	print("[SaveManager] Save files deleted.")


func has_save() -> bool:
	return FileAccess.file_exists(SLOT_MAIN_PATH)


# --- Internal ---

func _write_slot(path: String) -> void:
	var payload := {
		"version":    SAVE_VERSION,
		"timestamp":  Time.get_unix_time_from_system(),
		"game_state": GameState.get_save_data(),
		"tech_tree":  TechTree.get_save_data(),
	}
	var json_str := JSON.stringify(payload, "\t")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()
		print("[SaveManager] Saved → %s" % path)
	else:
		push_warning("[SaveManager] Write failed for %s: %s" % [path, str(FileAccess.get_open_error())])


func _read_slot(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("[SaveManager] Cannot open %s." % path)
		return {}
	var json_str := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(json_str) != OK:
		push_warning("[SaveManager] JSON parse failed for %s." % path)
		return {}
	var data = json.data
	if not data is Dictionary:
		return {}
	return data as Dictionary


func _apply_payload(payload: Dictionary) -> void:
	var version: String = payload.get("version", "0.1")
	if version != SAVE_VERSION:
		push_warning("[SaveManager] Version mismatch (%s vs expected %s) — wiping save." % [version, SAVE_VERSION])
		delete_save()
		return
	if payload.has("game_state"):
		GameState.load_save_data(payload["game_state"])
	else:
		push_warning("[SaveManager] Payload missing 'game_state' key.")
	if payload.has("tech_tree"):
		TechTree.load_save_data(payload["tech_tree"])
	print("[SaveManager] Game loaded (v%s)." % version)
