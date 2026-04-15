extends Interactable
## ShopTerminal — Opens the shop panel for purchasing drones and upgrades.
## Instant interaction — opens UI.

signal shop_opened
signal shop_closed

@onready var sprite: ColorRect = $Sprite

const COLOR_ACTIVE = Color(0.65, 0.45, 0.25)  # Rust brown
var is_shop_open: bool = false


func _ready() -> void:
	is_held_interaction = false
	sprite.color = COLOR_ACTIVE


func get_prompt_text() -> String:
	return "[E] Shop"


func interact(_player: Node2D) -> void:
	if not is_shop_open:
		is_shop_open = true
		shop_opened.emit()
		# TODO: Play UI panel open sound (hydraulic hiss)


func close_shop() -> void:
	if is_shop_open:
		is_shop_open = false
		shop_closed.emit()
		# TODO: Play UI panel close sound


func on_player_left() -> void:
	close_shop()


func is_interactable() -> bool:
	return not is_shop_open
