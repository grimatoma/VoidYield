extends Interactable
## SellTerminal — Converts ore from the storage pool into Credits.
## Instant interaction.

@onready var sprite: ColorRect = $Sprite

const COLOR_ACTIVE = Color(0.83, 0.66, 0.27)  # Dirty amber


func _ready() -> void:
	is_held_interaction = false
	sprite.color = COLOR_ACTIVE


func get_prompt_text() -> String:
	var total = GameState.player_carried_ore + GameState.storage_ore
	if total <= 0:
		return "[E] Sell (nothing)"
	var rare = GameState.player_rare_ore + GameState.storage_rare_ore
	if rare > 0:
		return "[E] Sell All — %d ore (%d krysite)" % [total, rare]
	return "[E] Sell All — %d ore" % total


func interact(_player: Node2D) -> void:
	var earned = GameState.sell_all_ore()
	if earned > 0:
		# TODO: Play sell sound (cash register ding)
		_spawn_credits_pop(earned)


func is_interactable() -> bool:
	return true  # Always interactable, even if empty (shows feedback)


func _spawn_credits_pop(amount: int) -> void:
	var label = Label.new()
	label.text = "+%d CR" % amount
	label.add_theme_color_override("font_color", Color(0.5, 0.85, 0.5))
	label.position = Vector2(-16, -32)
	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 24, 0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.chain().tween_callback(label.queue_free)
