extends Node
## SaveManager — Handles serialization to/from user://save.json.
## Auto-saves every 60 seconds. Cooldown prevents saves more often than every 5 seconds.

const SAVE_PATH = "user://save.json"
const AUTO_SAVE_INTERVAL = 60.0
const SAVE_COOLDOWN = 5.0

var _auto_save_timer: float = 0.0
var _cooldown_timer: float = SAVE_COOLDOWN  # start ready so the first explicit save fires immediately


func _ready() -> void:
	load_game()


func _process(delta: float) -> void:
	_auto_save_timer += delta
	_cooldown_timer  += delta
	if _auto_save_timer >= AUTO_SAVE_INTERVAL:
		_auto_save_timer = 0.0
		save_game()


func save_game() -> void:
	if _cooldown_timer < SAVE_COOLDOWN:
		return
	_cooldown_timer = 0.0

	var save_data = {
		"version": "0.1",
		"timestamp": Time.get_unix_time_from_system(),
		"game_state": GameState.get_save_data(),
	}

	var json_string = JSON.stringify(save_data, "\t")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("[SaveManager] Game saved.")
	else:
		push_warning("[SaveManager] Failed to save game: " + str(FileAccess.get_open_error()))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveManager] No save file found, starting fresh.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_warning("[SaveManager] Failed to open save file.")
		return

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_warning("[SaveManager] Failed to parse save file.")
		return

	var save_data = json.data
	if save_data is Dictionary and save_data.has("game_state"):
		GameState.load_save_data(save_data["game_state"])
		print("[SaveManager] Game loaded.")
	else:
		push_warning("[SaveManager] Save file has invalid structure.")


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("[SaveManager] Save file deleted.")
