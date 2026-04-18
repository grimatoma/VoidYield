extends Interactable
## StorageDepot — The shared ore pool. Player deposits carried ore here.
## Also handles auto-sell when that upgrade is purchased.

@onready var sprite: Sprite2D = $Sprite
@onready var fill_indicator: ColorRect = $FillIndicator

const COLOR_FILL = Color(0.85, 0.45, 0.15)    # Ore orange
const COLOR_FULL = Color(0.7, 0.2, 0.15)      # Warning red

var auto_sell_threshold: float = 0.8  # Sell at 80% capacity


func _ready() -> void:
	is_held_interaction = false
	GameState.storage_changed.connect(_on_storage_changed)
	_update_fill_display()


func _process(_delta: float) -> void:
	# Auto-sell check
	if GameState.has_upgrade("auto_sell"):
		var fill_ratio = float(GameState.storage_ore) / float(GameState.storage_capacity)
		if fill_ratio >= auto_sell_threshold:
			GameState.sell_all_ore()


func get_prompt_text() -> String:
	if GameState.player_carried_ore <= 0:
		return "[E] Storage (%d/%d)" % [GameState.storage_ore, GameState.storage_capacity]
	return "[E] Deposit %d ore" % GameState.player_carried_ore


func interact(_player: Node2D) -> void:
	var deposited = GameState.dump_inventory_to_storage()
	if deposited > 0:
		# TODO: Play deposit sound (clatter of rocks into metal)
		_spawn_deposit_pop(deposited)


func is_interactable() -> bool:
	return true


func _on_storage_changed(_stored: int, _capacity: int) -> void:
	_update_fill_display()


func _update_fill_display() -> void:
	if not is_instance_valid(fill_indicator):
		return
	var ratio = float(GameState.storage_ore) / float(maxi(GameState.storage_capacity, 1))
	# Scale the fill indicator height
	fill_indicator.scale.y = ratio
	# Change color when near full
	if ratio >= 0.9:
		fill_indicator.color = COLOR_FULL
	else:
		fill_indicator.color = COLOR_FILL


func _spawn_deposit_pop(amount: int) -> void:
	var label = Label.new()
	label.text = "+%d" % amount
	label.add_theme_color_override("font_color", Color(0.85, 0.65, 0.2))
	label.position = Vector2(-8, -32)
	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 20, 0.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.chain().tween_callback(label.queue_free)
