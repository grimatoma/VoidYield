extends "res://scripts/interactable.gd"
class_name OreNode
## OreNode — A mineable resource node in the asteroid field.
## Has multiple charges, transitions through visual states, respawns after depletion.
## ore_type controls texture, sell value, display name, and crafting material drops.

enum State { FULL, CRACKED, DEPLETED }

signal survey_completed(ore_node: Node2D)

# --- Configuration ---
@export var min_ore: int = 3
@export var max_ore: int = 5
@export var respawn_time: float = 30.0
## Ore type string: "common" (vorax), "rare" (krysite), "aethite", "voidstone"
@export var ore_type: String = "common"

# --- State ---
var current_state: State = State.FULL
var ore_remaining: int = 0
var total_ore: int = 0
var is_claimed: bool = false
var claimed_by: Node2D = null
var respawn_timer: float = 0.0
var survey_stage: int = 0
var quality_grade: String = ""

# --- Node References ---
@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var particles: CPUParticles2D = $OreParticles

var stage_label: Label = null

# --- State modulates ---
const MOD_FULL     = Color(1.0, 1.0, 1.0, 1.0)   # normal
const MOD_CRACKED  = Color(0.65, 0.6, 0.55, 1.0)  # slightly dimmed / desaturated
const MOD_DEPLETED = Color(0.32, 0.32, 0.32, 1.0) # grey-out

# Scrap / shard drop chances per mine action (TODO: lower for production)
const DROP_SCRAP_CHANCE  = 0.7   # common → scrap_metal
const DROP_SHARD_CHANCE  = 0.6   # rare / aethite → crystal_shards
const DROP_VOID_SHARD    = 0.5   # voidstone → crystal_shards


func _ready() -> void:
	is_held_interaction = true
	_load_sprite_texture()
	_respawn()
	collision_layer = 4
	collision_mask = 0
	_update_hold_duration()
	_create_stage_label()
	add_to_group("ore_nodes")


func _load_sprite_texture() -> void:
	var path: String
	match ore_type:
		"rare":      path = "res://assets/sprites/ores/ore_krysite.png"
		"aethite":   path = "res://assets/sprites/ores/ore_aethite.png"
		"voidstone": path = "res://assets/sprites/ores/ore_voidstone.png"
		"shards":    path = "res://assets/sprites/ores/ore_shards.png"
		_:           path = "res://assets/sprites/ores/ore_vorax.png"
	if ResourceLoader.exists(path):
		sprite.texture = load(path)


func _process(delta: float) -> void:
	if current_state == State.DEPLETED:
		respawn_timer -= delta
		if respawn_timer <= 0:
			_respawn()


# --- Interaction Interface ---

func get_prompt_text() -> String:
	match current_state:
		State.FULL, State.CRACKED:
			if survey_stage < 4:
				var stage_names = ["Quick Read", "Deep Scan", "Analysis", "Full Mapping"]
				return "[E] Survey %s - Stage %d/4 (%s)" % [_ore_display_name(), survey_stage + 1, stage_names[survey_stage]]
			else:
				return "[E] Mine %s (%d)" % [_ore_display_name(), ore_remaining]
		State.DEPLETED:
			return ""
	return ""


func interact(player: Node2D) -> void:
	if current_state == State.DEPLETED:
		return
	if survey_stage >= 4:
		var added = GameState.add_to_inventory(1, ore_type)
		if added > 0:
			ore_remaining -= 1
			_try_drop_material()
			particles.restart()
			_spawn_number_pop(player)
		if ore_remaining <= 0:
			_set_state(State.DEPLETED)
		elif ore_remaining <= total_ore / 2.0:
			_set_state(State.CRACKED)


func is_interactable() -> bool:
	return current_state != State.DEPLETED


func cancel_interaction() -> void:
	set_meta("mining_progress", 0.0)


# --- Drone Claim System ---

func claim(drone: Node2D) -> bool:
	if is_claimed or current_state == State.DEPLETED:
		return false
	is_claimed = true
	claimed_by = drone
	return true


func release_claim() -> void:
	is_claimed = false
	claimed_by = null


func drone_mine(_drone: Node2D) -> int:
	if current_state == State.DEPLETED:
		release_claim()
		return 0
	var mined = mini(1, ore_remaining)
	ore_remaining -= mined
	if mined > 0:
		_try_drop_material()
		particles.restart()
	if ore_remaining <= 0:
		_set_state(State.DEPLETED)
		release_claim()
	elif ore_remaining <= total_ore / 2.0:
		_set_state(State.CRACKED)
	return mined


# --- Crafting Material Drops ---

func _try_drop_material() -> void:
	match ore_type:
		"common":
			if randf() < DROP_SCRAP_CHANCE:
				GameState.add_material("scrap_metal", 1)
		"rare":
			if randf() < DROP_SHARD_CHANCE:
				GameState.add_to_inventory(1, "shards")
		"aethite":
			if randf() < DROP_SHARD_CHANCE:
				GameState.add_to_inventory(1, "shards")
		"voidstone":
			if randf() < DROP_VOID_SHARD:
				GameState.add_to_inventory(1, "shards")


# --- State Management ---

func _set_state(new_state: State) -> void:
	current_state = new_state
	match new_state:
		State.FULL:
			sprite.modulate = MOD_FULL
			collision.disabled = false
		State.CRACKED:
			sprite.modulate = MOD_CRACKED
		State.DEPLETED:
			sprite.modulate = MOD_DEPLETED
			collision.disabled = true
			release_claim()
			respawn_timer = respawn_time
			EventLog.add("Ore node depleted — respawning in %.1fs" % respawn_time, "MINING")


func _ore_display_name() -> String:
	match ore_type:
		"rare":      return "Krysite"
		"aethite":   return "Aethite"
		"voidstone": return "Voidstone"
		_:           return "Vorax"


func _respawn() -> void:
	total_ore = randi_range(min_ore, max_ore)
	ore_remaining = total_ore
	survey_stage = 0
	quality_grade = ""
	_set_state(State.FULL)


func advance_survey(current_stage: int) -> void:
	survey_stage = mini(survey_stage + 1, 4)
	if survey_stage >= 2 and quality_grade == "":
		var tier = "average"
		match ore_type:
			"rare": tier = "rich"
			"aethite": tier = "rich"
			"voidstone": tier = "motherlode"
		var lot = OreQualityLot.generate(tier)
		quality_grade = lot.grade
	if survey_stage >= 4:
		survey_completed.emit(self)


func _update_hold_duration() -> void:
	if survey_stage < 4:
		hold_duration = 2.0
	else:
		hold_duration = GameState.player_mine_time
	_update_stage_label()


func _create_stage_label() -> void:
	stage_label = Label.new()
	stage_label.position = Vector2(-12, -24)
	add_child(stage_label)
	_update_stage_label()


func _update_stage_label() -> void:
	if not stage_label:
		return

	if survey_stage == 0:
		stage_label.text = ""
		return

	var stage_names = ["Quick Read", "Deep Scan", "Analysis", "Full Mapping"]
	var text = ""

	if survey_stage < 4:
		text = "Stage %d/4\n%s" % [survey_stage, stage_names[survey_stage - 1]]
	else:
		text = "[%s]" % quality_grade
		stage_label.add_theme_color_override("font_color", Color(0.831, 0.658, 0.270))

	stage_label.text = text


# --- Juice ---

func _spawn_number_pop(_player: Node2D) -> void:
	var label = Label.new()
	var is_exotic = ore_type in ["rare", "aethite", "voidstone"]
	label.text = "+1 %s" % _ore_display_name() if is_exotic else "+1"
	var pop_color = Color(0.7, 0.4, 1.0) if ore_type == "rare" \
				  else Color(0.2, 0.85, 0.95) if ore_type == "aethite" \
				  else Color(0.55, 0.35, 0.9) if ore_type == "voidstone" \
				  else Color(0.85, 0.65, 0.2)
	label.add_theme_color_override("font_color", pop_color)
	label.position = Vector2(-8, -24)
	add_child(label)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 20, 0.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.chain().tween_callback(label.queue_free)
