extends Node
## AudioManager — Central audio control for VoidYield.
##
## Provides:
##   play_sfx(stream)          — plays a one-shot sound effect (round-robin pool)
##   play_music(stream)        — starts/swaps background music
##   set_sfx_volume_linear(v)  — 0.0–1.0 volume for SFX bus
##   set_music_volume_linear(v)— 0.0–1.0 volume for Music bus
##   get_sfx_volume_linear()   — returns current SFX linear volume
##   get_music_volume_linear() — returns current Music linear volume
##
## SFX files: drop AudioStream resources into res://assets/audio/sfx/
## Music files: drop AudioStream resources into res://assets/audio/music/

const SFX_POOL_SIZE := 8
const BUS_SFX   := "SFX"
const BUS_MUSIC := "Music"

var _music_player: AudioStreamPlayer = null
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index: int = 0


func _ready() -> void:
	_ensure_buses()
	_build_players()
	_connect_signals()
	print("[AudioManager] Ready. SFX pool: %d players." % SFX_POOL_SIZE)


# --- Public API --------------------------------------------------------------

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var player := _sfx_pool[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % SFX_POOL_SIZE
	player.stream = stream
	player.play()


func play_music(stream: AudioStream) -> void:
	if _music_player == null:
		return
	if stream == null:
		_music_player.stop()
		return
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	if _music_player:
		_music_player.stop()


func set_sfx_volume_linear(linear: float) -> void:
	linear = clampf(linear, 0.0, 1.0)
	var db: float = linear_to_db(linear) if linear > 0.0 else -80.0
	var idx := AudioServer.get_bus_index(BUS_SFX)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, db)


func set_music_volume_linear(linear: float) -> void:
	linear = clampf(linear, 0.0, 1.0)
	var db: float = linear_to_db(linear) if linear > 0.0 else -80.0
	var idx := AudioServer.get_bus_index(BUS_MUSIC)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, db)


func get_sfx_volume_linear() -> float:
	var idx := AudioServer.get_bus_index(BUS_SFX)
	if idx < 0:
		return 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(idx))


func get_music_volume_linear() -> float:
	var idx := AudioServer.get_bus_index(BUS_MUSIC)
	if idx < 0:
		return 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(idx))


# --- Internal ----------------------------------------------------------------

func _ensure_buses() -> void:
	## Creates SFX and Music buses if they don't already exist.
	## Safe to call even if buses were already configured in the editor.
	if AudioServer.get_bus_index(BUS_MUSIC) < 0:
		AudioServer.add_bus()
		var idx := AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(idx, BUS_MUSIC)
		AudioServer.set_bus_send(idx, "Master")

	if AudioServer.get_bus_index(BUS_SFX) < 0:
		AudioServer.add_bus()
		var idx := AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(idx, BUS_SFX)
		AudioServer.set_bus_send(idx, "Master")


func _build_players() -> void:
	# Music player (looping, single stream)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_MUSIC
	_music_player.name = "MusicPlayer"
	add_child(_music_player)

	# SFX pool (round-robin for polyphony)
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = BUS_SFX
		p.name = "SFX_%d" % i
		add_child(p)
		_sfx_pool.append(p)


func _connect_signals() -> void:
	## Wire GameState signals to SFX hooks.
	## All sound paths are placeholders — drop in real files to activate.
	GameState.ore_sold.connect(func(_amt, _cr): _play_sfx_path("res://assets/audio/sfx/sell.wav"))
	GameState.upgrade_purchased.connect(func(_id): _play_sfx_path("res://assets/audio/sfx/upgrade.wav"))
	GameState.inventory_changed.connect(func(_c, _m): pass)  # mine chunk — too frequent for now
	GameState.ship_part_crafted.connect(func(_id): _play_sfx_path("res://assets/audio/sfx/craft.wav"))
	GameState.building_constructed.connect(func(_id): _play_sfx_path("res://assets/audio/sfx/build.wav"))


func _play_sfx_path(path: String) -> void:
	## Tries to load and play a sound file. Fails silently if missing.
	if not ResourceLoader.exists(path):
		return
	var stream := load(path) as AudioStream
	if stream:
		play_sfx(stream)
