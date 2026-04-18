extends Node
## SettingsManager — Persists audio volumes and display settings to user://settings.cfg.
## Loaded at startup; call apply() to push values to AudioManager and DisplayServer.

const CONFIG_PATH := "user://settings.cfg"

const DEFAULT_MUSIC   := 0.8
const DEFAULT_SFX     := 1.0
const DEFAULT_FULLSCREEN := true

var music_volume: float = DEFAULT_MUSIC
var sfx_volume: float   = DEFAULT_SFX
var fullscreen: bool    = DEFAULT_FULLSCREEN

var _cfg := ConfigFile.new()


func _ready() -> void:
	load_settings()
	apply()


func load_settings() -> void:
	if _cfg.load(CONFIG_PATH) != OK:
		return
	music_volume = _cfg.get_value("audio", "music_volume", DEFAULT_MUSIC)
	sfx_volume   = _cfg.get_value("audio", "sfx_volume",   DEFAULT_SFX)
	fullscreen   = _cfg.get_value("display", "fullscreen",  DEFAULT_FULLSCREEN)


func save_settings() -> void:
	_cfg.set_value("audio", "music_volume", music_volume)
	_cfg.set_value("audio", "sfx_volume",   sfx_volume)
	_cfg.set_value("display", "fullscreen",  fullscreen)
	_cfg.save(CONFIG_PATH)


func apply() -> void:
	AudioManager.set_music_volume_linear(music_volume)
	AudioManager.set_sfx_volume_linear(sfx_volume)
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen \
		else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)


func set_music(linear: float) -> void:
	music_volume = clampf(linear, 0.0, 1.0)
	AudioManager.set_music_volume_linear(music_volume)
	save_settings()


func set_sfx(linear: float) -> void:
	sfx_volume = clampf(linear, 0.0, 1.0)
	AudioManager.set_sfx_volume_linear(sfx_volume)
	save_settings()


func set_fullscreen(enabled: bool) -> void:
	fullscreen = enabled
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if enabled \
		else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	save_settings()
