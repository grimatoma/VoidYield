extends Interactable
## Spaceship — Craftable launch vehicle. Open the shipyard panel to craft parts.
## Once all parts are built, the LAUNCH button sends the player to Planet B.

signal ship_opened(spaceship: Node2D)
signal ship_closed

@onready var sprite: ColorRect = $Sprite
@onready var ready_indicator: ColorRect = $ReadyIndicator

const COLOR_INCOMPLETE = Color(0.2, 0.25, 0.4)   # Dim blue-grey
const COLOR_READY      = Color(0.3, 0.55, 0.85)  # Bright blue when launch-ready

var is_panel_open: bool = false


func _ready() -> void:
	is_held_interaction = false
	sprite.color = COLOR_INCOMPLETE
	GameState.ship_part_crafted.connect(_on_ship_part_crafted)
	_update_visuals()


func get_prompt_text() -> String:
	var built = GameState.parts_built_count()
	var total = GameState.spaceship_parts_crafted.size()
	if GameState.is_ship_ready():
		return "[E] Spaceship — READY TO LAUNCH"
	return "[E] Shipyard (%d/%d parts)" % [built, total]


func interact(_player: Node2D) -> void:
	if not is_panel_open:
		is_panel_open = true
		ship_opened.emit(self)


func close_ship() -> void:
	if is_panel_open:
		is_panel_open = false
		ship_closed.emit()


func on_player_left() -> void:
	close_ship()


func is_interactable() -> bool:
	return not is_panel_open


func _on_ship_part_crafted(_part_id: String) -> void:
	_update_visuals()


func _update_visuals() -> void:
	if GameState.is_ship_ready():
		sprite.color = COLOR_READY
		ready_indicator.visible = true
	else:
		sprite.color = COLOR_INCOMPLETE
		ready_indicator.visible = false
