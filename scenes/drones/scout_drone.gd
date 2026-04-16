extends CharacterBody2D
class_name ScoutDrone
## ScoutDrone — Autonomous mining drone with state machine AI.
## Pathfinds to ore nodes, mines, hauls ore back to storage depot.

enum State {
	IDLE,       # Sitting at drone bay, waiting
	SEEKING,    # Pathfinding to a target ore node
	MINING,     # At the node, mining ore
	RETURNING,  # Hauling ore back to storage depot
	DEPOSITING, # At storage, dumping ore
}

# --- Configuration (set by DroneBay on spawn) ---
var move_speed: float = 60.0
var carry_capacity: int = 3
var mine_time: float = 3.0
var drone_bay_position: Vector2 = Vector2.ZERO
var storage_position: Vector2 = Vector2.ZERO

## Ore assignment filter. Values: "any", "common", "rare", "aethite", "voidstone"
var ore_assignment: String = "any"

# --- State ---
var current_state: State = State.IDLE
var carried_ore: int = 0
var carried_ore_type: String = "common"  # type of ore currently being carried
var target_node: OreNode = null
var mine_timer: float = 0.0
var deposit_timer: float = 0.0
const DEPOSIT_DURATION: float = 1.0
var idle_retry_timer: float = 0.0
var arrival_threshold: float = 12.0

# --- Stuck detection ---
var _stuck_timer: float = 0.0
var _last_position: Vector2 = Vector2.ZERO
var _seek_elapsed: float = 0.0
const STUCK_CHECK_INTERVAL: float = 1.5
const STUCK_DISTANCE_MIN: float = 4.0
const SEEK_TIMEOUT: float = 8.0

# --- Node References ---
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var mine_progress_bar: ProgressBar = $MineProgressBar

const IDLE_RETRY_INTERVAL: float = 2.0

# --- Animation state ---
# Cached facing angle (radians, Godot convention: 0=+X east, PI/2=+Y south).
# Remembered across IDLE so the drone doesn't snap to a default direction.
var _facing_angle: float = PI / 2.0  # default: face south
var _current_anim: String = ""
# Below this speed the drone is treated as stationary (walk anim pauses).
const _IDLE_SPEED_THRESHOLD: float = 6.0
# 8 compass directions, indexed by sector = round(angle * 8 / TAU) % 8
# starting from +X (east) and rotating clockwise (toward +Y = south).
const _DIR_SUFFIXES: Array[String] = ["e", "se", "s", "sw", "w", "nw", "n", "ne"]

## Human-readable assignment label for UI
static func assignment_display(assignment: String) -> String:
	match assignment:
		"common":    return "Mine Vorax"
		"rare":      return "Mine Krysite"
		"aethite":   return "Mine Aethite"
		"voidstone": return "Mine Voidstone"
		_:           return "Mine Any"

## Cycle to next assignment option
static func next_assignment(current: String) -> String:
	var cycle = ["any", "common", "rare", "aethite", "voidstone"]
	var idx = cycle.find(current)
	return cycle[(idx + 1) % cycle.size()]


func _ready() -> void:
	nav_agent.path_desired_distance = arrival_threshold
	nav_agent.target_desired_distance = arrival_threshold
	_change_state(State.IDLE)
	_update_animation()


func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:       _process_idle(delta)
		State.SEEKING:    _process_seeking(delta)
		State.MINING:     _process_mining(delta)
		State.RETURNING:  _process_returning(delta)
		State.DEPOSITING: _process_depositing(delta)
	_update_animation()


# --- State Processing ---

func _process_idle(delta: float) -> void:
	idle_retry_timer += delta
	if idle_retry_timer < IDLE_RETRY_INTERVAL:
		return
	idle_retry_timer = 0.0
	if GameState.is_storage_full():
		return
	var node = _find_nearest_unclaimed_node()
	if node and node.claim(self):
		target_node = node
		carried_ore_type = node.ore_type
		_change_state(State.SEEKING)


func _process_seeking(delta: float) -> void:
	if not is_instance_valid(target_node) or target_node.current_state == OreNode.State.DEPLETED:
		_release_target()
		_change_state(State.IDLE)
		return

	_seek_elapsed += delta
	if _seek_elapsed >= SEEK_TIMEOUT:
		_release_target()
		_change_state(State.IDLE)
		return

	var dist = global_position.distance_to(target_node.global_position)
	if nav_agent.is_navigation_finished() or dist <= arrival_threshold:
		_change_state(State.MINING)
		return

	_move_along_path(delta)


func _process_returning(delta: float) -> void:
	var dist = global_position.distance_to(storage_position)
	if nav_agent.is_navigation_finished() or dist <= arrival_threshold:
		_change_state(State.DEPOSITING)
		return
	_move_along_path(delta)


func _move_along_path(delta: float) -> void:
	var next_pos = nav_agent.get_next_path_position()
	var to_next = next_pos - global_position
	if to_next.length_squared() > 1.0:
		velocity = to_next.normalized() * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	_stuck_timer += delta
	if _stuck_timer >= STUCK_CHECK_INTERVAL:
		var moved = global_position.distance_to(_last_position)
		_last_position = global_position
		_stuck_timer = 0.0
		if moved < STUCK_DISTANCE_MIN:
			_release_target()
			_change_state(State.IDLE)


func _process_mining(delta: float) -> void:
	if not is_instance_valid(target_node) or target_node.current_state == OreNode.State.DEPLETED:
		_release_target()
		mine_progress_bar.visible = false
		_change_state(State.RETURNING if carried_ore > 0 else State.IDLE)
		return

	mine_timer += delta
	mine_progress_bar.value = mine_timer / mine_time
	if mine_timer >= mine_time:
		mine_timer = 0.0
		var mined = target_node.drone_mine(self)
		carried_ore += mined
		if carried_ore >= carry_capacity or target_node.current_state == OreNode.State.DEPLETED:
			_release_target()
			_change_state(State.RETURNING)


func _process_depositing(delta: float) -> void:
	deposit_timer += delta
	mine_progress_bar.value = deposit_timer / DEPOSIT_DURATION
	if deposit_timer < DEPOSIT_DURATION:
		return

	var deposited = GameState.deposit_to_storage(carried_ore, carried_ore_type)
	carried_ore -= deposited
	if carried_ore > 0 and GameState.is_storage_full():
		_change_state(State.IDLE)
		return

	GameState.on_drone_returned(self, deposited)
	carried_ore = 0
	_change_state(State.IDLE)


# --- State Changes ---

func _change_state(new_state: State) -> void:
	current_state = new_state
	match new_state:
		State.IDLE:
			velocity = Vector2.ZERO
			idle_retry_timer = 0.0
			nav_agent.target_position = drone_bay_position

		State.SEEKING:
			_seek_elapsed = 0.0
			_stuck_timer = 0.0
			_last_position = global_position
			if target_node:
				nav_agent.target_position = target_node.global_position

		State.MINING:
			velocity = Vector2.ZERO
			mine_timer = 0.0
			mine_progress_bar.value = 0.0
			mine_progress_bar.visible = true

		State.RETURNING:
			mine_progress_bar.visible = false
			_stuck_timer = 0.0
			_last_position = global_position
			nav_agent.target_position = storage_position

		State.DEPOSITING:
			deposit_timer = 0.0
			mine_progress_bar.value = 0.0
			mine_progress_bar.visible = true
			velocity = Vector2.ZERO


# --- Animation ---

## Map a facing angle (radians, Godot convention) to one of 8 compass suffixes.
func _dir_suffix(angle: float) -> String:
	var a: float = fposmod(angle, TAU)
	var sector: int = int(round(a * 8.0 / TAU)) % 8
	return _DIR_SUFFIXES[sector]


## Pick and play the right animation for the current state + facing.
## Refreshes _facing_angle from velocity or the active target when it matters.
func _update_animation() -> void:
	var anim: String = ""
	match current_state:
		State.MINING:
			# Face the ore node so the mining drill animation reads correctly.
			if is_instance_valid(target_node):
				_facing_angle = (target_node.global_position - global_position).angle()
			anim = "mining"
		State.DEPOSITING:
			# Face the storage depot while unloading.
			_facing_angle = (storage_position - global_position).angle()
			anim = "unloading"
		_:
			if velocity.length() > _IDLE_SPEED_THRESHOLD:
				_facing_angle = velocity.angle()
			anim = "walk_" + _dir_suffix(_facing_angle)

	if anim != _current_anim:
		sprite.play(anim)
		_current_anim = anim

	# Pause the walk cycle on frame 0 when the drone isn't actually moving,
	# so IDLE drones don't look like they're jogging in place.
	if anim.begins_with("walk_"):
		var moving: bool = velocity.length() > _IDLE_SPEED_THRESHOLD
		if moving:
			if not sprite.is_playing():
				sprite.play(anim)
		else:
			sprite.pause()
			sprite.frame = 0


# --- Utility ---

func _find_nearest_unclaimed_node() -> OreNode:
	var nodes = get_tree().get_nodes_in_group("ore_nodes")
	var closest: OreNode = null
	var closest_dist: float = INF
	var fallback: OreNode = null
	var fallback_dist: float = INF

	for node in nodes:
		if not node is OreNode: continue
		if node.current_state == OreNode.State.DEPLETED: continue
		if node.is_claimed: continue
		var dist = global_position.distance_to(node.global_position)
		if ore_assignment == "any" or node.ore_type == ore_assignment:
			if dist < closest_dist:
				closest_dist = dist
				closest = node
		else:
			# Keep as fallback if no matching nodes found
			if dist < fallback_dist:
				fallback_dist = dist
				fallback = node

	return closest if closest != null else fallback


func _release_target() -> void:
	if is_instance_valid(target_node):
		target_node.release_claim()
	target_node = null
