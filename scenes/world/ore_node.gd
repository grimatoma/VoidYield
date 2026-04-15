extends Interactable
class_name OreNode
## OreNode — A mineable resource node in the asteroid field.
## Has multiple charges, transitions through visual states, respawns after depletion.
## ore_type controls colour, sell value, display name, and crafting material drops.

enum State { FULL, CRACKED, DEPLETED }

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

# --- Node References ---
@onready var sprite: ColorRect = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

# --- Colors ---
const COLOR_FULL         = Color(0.85, 0.45, 0.15)   # Rust orange  (vorax)
const COLOR_CRACKED      = Color(0.55, 0.35, 0.15)   # Darker orange
const COLOR_RARE_FULL    = Color(0.45, 0.15, 0.85)   # Deep purple  (krysite)
const COLOR_RARE_CRACKED = Color(0.3,  0.1,  0.6)
const COLOR_AETH_FULL    = Color(0.2,  0.75, 0.85)   # Bright cyan  (aethite)
const COLOR_AETH_CRACKED = Color(0.12, 0.5,  0.6)
const COLOR_VOID_FULL    = Color(0.08, 0.0,  0.18)   # Near-void purple (voidstone)
const COLOR_VOID_CRACKED = Color(0.06, 0.0,  0.12)
const COLOR_DEPLETED     = Color(0.3,  0.3,  0.3)    # Grey

# Scrap / shard drop chances per mine action (TODO: lower for production)
const DROP_SCRAP_CHANCE  = 0.7   # common → scrap_metal
const DROP_SHARD_CHANCE  = 0.6   # rare / aethite → crystal_shards
const DROP_VOID_SHARD    = 0.5   # voidstone → crystal_shards


func _ready() -> void:
	is_held_interaction = true
	hold_duration = GameState.player_mine_time
	_respawn()
	collision_layer = 4
	collision_mask = 0


func _process(delta: float) -> void:
	if current_state == State.DEPLETED:
		respawn_timer -= delta
		if respawn_timer <= 0:
			_respawn()


# --- Interaction Interface ---

func get_prompt_text() -> String:
	match current_state:
		State.FULL, State.CRACKED:
			return "[E] Mine %s (%d)" % [_ore_display_name(), ore_remaining]
		State.DEPLETED:
			return ""
	return ""


func interact(player: Node2D) -> void:
	if current_state == State.DEPLETED:
		return
	var added = GameState.add_to_inventory(1, ore_type)
	if added > 0:
		ore_remaining -= 1
		_try_drop_material()
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
			sprite.color = _full_color()
			collision.disabled = false
		State.CRACKED:
			sprite.color = _cracked_color()
		State.DEPLETED:
			sprite.color = COLOR_DEPLETED
			collision.disabled = true
			release_claim()
			respawn_timer = respawn_time


func _full_color() -> Color:
	match ore_type:
		"rare":      return COLOR_RARE_FULL
		"aethite":   return COLOR_AETH_FULL
		"voidstone": return COLOR_VOID_FULL
		_:           return COLOR_FULL


func _cracked_color() -> Color:
	match ore_type:
		"rare":      return COLOR_RARE_CRACKED
		"aethite":   return COLOR_AETH_CRACKED
		"voidstone": return COLOR_VOID_CRACKED
		_:           return COLOR_CRACKED


func _ore_display_name() -> String:
	match ore_type:
		"rare":      return "Krysite"
		"aethite":   return "Aethite"
		"voidstone": return "Voidstone"
		_:           return "Vorax"


func _respawn() -> void:
	total_ore = randi_range(min_ore, max_ore)
	ore_remaining = total_ore
	_set_state(State.FULL)


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
