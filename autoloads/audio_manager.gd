extends Node
## AudioManager — Central audio control for VoidYield.
##
## Named SFX (synthesized, no files required):
##   play_mine_sound()      — short thud when ore is collected
##   play_purchase_chime()  — bright two-tone ding on upgrade/purchase
##   play_sell_blip()       — ascending cash-register blip on sell
##   play_survey_ping()     — soft sine ping on survey stage advance
##   set_drone_hum(active)  — start/stop looping drone hum
##
## File-based API:
##   play_sfx(stream)          — one-shot from AudioStream resource
##   play_music(stream)        — background music
##   set_sfx_volume_linear(v)  — 0.0–1.0
##   set_music_volume_linear(v)— 0.0–1.0

const SFX_POOL_SIZE := 8
const BUS_SFX   := "SFX"
const BUS_MUSIC := "Music"
const SAMPLE_RATE := 22050

var _music_player: AudioStreamPlayer = null
var _hum_player: AudioStreamPlayer = null
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index: int = 0

var _stream_mine: AudioStreamWAV = null
var _stream_purchase: AudioStreamWAV = null
var _stream_sell: AudioStreamWAV = null
var _stream_survey: AudioStreamWAV = null
var _stream_hum: AudioStreamWAV = null

var _hum_active: bool = false


func _ready() -> void:
	_ensure_buses()
	_build_players()
	_generate_sounds()
	_connect_signals()
	print("[AudioManager] Ready — synthesized SFX loaded.")


func _process(_delta: float) -> void:
	# Auto-manage drone hum based on active drone count.
	var want_hum := GameState.active_drone_count > 0
	if want_hum and not _hum_active:
		_hum_player.play()
		_hum_active = true
	elif not want_hum and _hum_active:
		_hum_player.stop()
		_hum_active = false


# --- Named SFX ---------------------------------------------------------------

func play_mine_sound() -> void:
	play_sfx(_stream_mine)


func play_purchase_chime() -> void:
	play_sfx(_stream_purchase)


func play_sell_blip() -> void:
	play_sfx(_stream_sell)


func play_survey_ping() -> void:
	play_sfx(_stream_survey)


func set_drone_hum(active: bool) -> void:
	if active and not _hum_active:
		_hum_player.play()
		_hum_active = true
	elif not active and _hum_active:
		_hum_player.stop()
		_hum_active = false


# --- File-based API ----------------------------------------------------------

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
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_MUSIC
	_music_player.name = "MusicPlayer"
	add_child(_music_player)

	_hum_player = AudioStreamPlayer.new()
	_hum_player.bus = BUS_SFX
	_hum_player.volume_db = -12.0
	_hum_player.name = "HumPlayer"
	add_child(_hum_player)

	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = BUS_SFX
		p.name = "SFX_%d" % i
		add_child(p)
		_sfx_pool.append(p)


func _connect_signals() -> void:
	GameState.ore_sold.connect(func(_amt, _cr): play_sell_blip())
	GameState.upgrade_purchased.connect(func(_id): _play_sfx_path("res://assets/audio/sfx/upgrade.wav"))
	GameState.ship_part_crafted.connect(func(_id): _play_sfx_path("res://assets/audio/sfx/craft.wav"))
	GameState.building_constructed.connect(func(_id): _play_sfx_path("res://assets/audio/sfx/build.wav"))


func _play_sfx_path(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream := load(path) as AudioStream
	if stream:
		play_sfx(stream)


# --- Sound generation --------------------------------------------------------

func _generate_sounds() -> void:
	_stream_mine     = _gen_thud()
	_stream_purchase = _gen_chime()
	_stream_sell     = _gen_sell_blip()
	_stream_survey   = _gen_survey_ping()
	_stream_hum      = _gen_drone_hum()
	_hum_player.stream = _stream_hum


func _make_wav(data: PackedByteArray, loop: bool = false) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.stereo = false
	wav.mix_rate = SAMPLE_RATE
	wav.data = data
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = data.size() / 2
	return wav


func _write_sample(data: PackedByteArray, idx: int, value: float) -> void:
	var s := clampi(int(value * 32767.0), -32768, 32767)
	data[idx * 2]     = s & 0xFF
	data[idx * 2 + 1] = (s >> 8) & 0xFF


func _gen_thud() -> AudioStreamWAV:
	# Short low-frequency thud with noise transient — ore impact.
	var n := int(SAMPLE_RATE * 0.10)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / SAMPLE_RATE
		var env := exp(-t * 30.0)
		var s := sin(TAU * 90.0 * t) * 0.65
		s += randf_range(-0.35, 0.35)  # noise burst
		_write_sample(data, i, s * env)
	return _make_wav(data)


func _gen_chime() -> AudioStreamWAV:
	# Two-tone bright ding — purchase confirmation.
	var n := int(SAMPLE_RATE * 0.32)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / SAMPLE_RATE
		var env := exp(-t * 5.5)
		var s := sin(TAU * 880.0 * t) * 0.55
		s += sin(TAU * 1108.0 * t) * 0.40  # major third above
		_write_sample(data, i, s * env)
	return _make_wav(data)


func _gen_sell_blip() -> AudioStreamWAV:
	# Three ascending tones — cash-register blip.
	var n := int(SAMPLE_RATE * 0.21)
	var seg := n / 3
	var freqs := [440.0, 660.0, 880.0]
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var seg_i := mini(i / seg, 2)
		var t := float(i) / SAMPLE_RATE
		var t_local := float(i - seg_i * seg) / SAMPLE_RATE
		var env := exp(-t_local * 22.0)
		var s := sin(TAU * freqs[seg_i] * t) * env
		_write_sample(data, i, s)
	return _make_wav(data)


func _gen_survey_ping() -> AudioStreamWAV:
	# Pure C5 sine with gentle decay — survey stage advance.
	var n := int(SAMPLE_RATE * 0.42)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / SAMPLE_RATE
		var env := exp(-t * 4.2)
		var s := sin(TAU * 523.25 * t) * env
		_write_sample(data, i, s)
	return _make_wav(data)


func _gen_drone_hum() -> AudioStreamWAV:
	# Low looping hum with vibrato and harmonics — active drone ambience.
	# Use 70 Hz: 22050 / 70 = 315 samples/cycle. 63 cycles = 19845 samples.
	var cycles := 63
	var n := 315 * cycles  # 19845 samples — seamless loop at 70 Hz
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / SAMPLE_RATE
		var vib := sin(TAU * 4.5 * t) * 0.018
		var f := 70.0 * (1.0 + vib)
		var s := sin(TAU * f * t) * 0.55
		s += sin(TAU * f * 2.0 * t) * 0.28  # 2nd harmonic
		s += sin(TAU * f * 3.0 * t) * 0.12  # 3rd harmonic
		_write_sample(data, i, s * 0.28)
	return _make_wav(data, true)
