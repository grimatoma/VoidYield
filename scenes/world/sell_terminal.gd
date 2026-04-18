extends Interactable
## SellTerminal — Opens the shop panel's RESOURCES tab for buying / selling ore.
## Was instant-sell; now shows a proper trade menu.

signal sell_opened
signal sell_closed

@onready var sprite: Sprite2D = $Sprite

var is_sell_open: bool = false


func _ready() -> void:
	is_held_interaction = false


func get_prompt_text() -> String:
	var total = GameState.player_carried_ore + GameState.storage_ore
	if total <= 0:
		return "[E] Trade Terminal"
	return "[E] Trade Terminal — %d ore" % total


func interact(_player: Node2D) -> void:
	if not is_sell_open:
		is_sell_open = true
		sell_opened.emit()


func close_sell() -> void:
	if is_sell_open:
		is_sell_open = false
		sell_closed.emit()


func on_player_left() -> void:
	close_sell()


func is_interactable() -> bool:
	return not is_sell_open
