extends "res://scripts/interactable.gd"
## ShopTerminal — Opens the shop panel for purchasing drones and upgrades.
## Instant interaction — opens UI.

signal shop_opened
signal shop_closed

@onready var sprite: Sprite2D = $Sprite

var is_shop_open: bool = false


func _ready() -> void:
	is_held_interaction = false


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
