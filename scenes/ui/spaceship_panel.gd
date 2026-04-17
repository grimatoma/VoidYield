extends PanelContainer
## SpaceshipPanel — Crafting panel for spaceship parts.
## Shows materials inventory, per-part requirements, and the LAUNCH button.

signal launch_requested

@onready var item_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/ItemList
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleRow/TitleLabel
@onready var close_button: Button = $MarginContainer/VBoxContainer/TitleRow/CloseButton
@onready var launch_button: Button = $MarginContainer/VBoxContainer/LaunchButton

var is_open: bool = false
var spaceship_ref: Node2D = null

# Part display order
const PART_ORDER = ["hull_plating", "ion_drive", "navigation_core", "fuel_cell"]


func _ready() -> void:
	visible = false
	position.x = get_viewport_rect().size.x
	close_button.pressed.connect(close)
	launch_button.pressed.connect(_on_launch_pressed)
	GameState.credits_changed.connect(func(_a): if is_open: _populate())
	GameState.storage_changed.connect(func(_s, _c): if is_open: _populate())
	GameState.ship_part_crafted.connect(func(_id): if is_open: _populate())


func _process(_delta: float) -> void:
	if not is_open or not is_instance_valid(spaceship_ref):
		return
	var player = get_tree().get_first_node_in_group("player")
	if player and player.global_position.distance_to(spaceship_ref.global_position) > 90.0:
		close()


func _input(event: InputEvent) -> void:
	if not is_open: return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open(ship: Node2D = null) -> void:
	spaceship_ref = ship
	is_open = true
	position.x = get_viewport_rect().size.x
	visible = true
	_populate()
	var panel_width: float = max(size.x, custom_minimum_size.x)
	var target_x: float = get_viewport_rect().size.x - panel_width
	var tween = create_tween()
	tween.tween_property(self, "position:x", target_x, 0.2).set_ease(Tween.EASE_OUT)


func close() -> void:
	if not is_open: return
	is_open = false
	var tween = create_tween()
	tween.tween_property(self, "position:x", get_viewport_rect().size.x, 0.2).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): visible = false)
	if spaceship_ref and spaceship_ref.has_method("close_ship"):
		spaceship_ref.close_ship()


func _populate() -> void:
	for child in item_list.get_children():
		child.queue_free()

	title_label.text = "SHIPYARD"

	# Materials header
	_add_header("MATERIALS")
	_add_materials_row()

	# Parts
	_add_header("SHIP PARTS")
	for part_id in PART_ORDER:
		_add_part_row(part_id)

	# Launch button state — when ready, the button opens the Galaxy Map so the
	# player can choose a destination.
	launch_button.disabled = not GameState.is_ship_ready()
	launch_button.text = "LAUNCH → GALAXY MAP" if GameState.is_ship_ready() else "LAUNCH (incomplete)"
	launch_button.modulate = Color(0.3, 0.8, 0.4) if GameState.is_ship_ready() else Color(0.5, 0.5, 0.5)


func _add_header(text: String) -> void:
	var lbl = Label.new()
	lbl.text = "— %s —" % text
	lbl.add_theme_color_override("font_color", Color(0.6, 0.5, 0.3))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_list.add_child(lbl)


func _add_materials_row() -> void:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)

	var common_stored = GameState.storage_ore - GameState.storage_rare_ore \
		- GameState.storage_aethite - GameState.storage_voidstone - GameState.storage_shards

	var ore_lbl = Label.new()
	ore_lbl.text = "▪ Vorax: %d" % common_stored
	ore_lbl.add_theme_color_override("font_color", Color(0.85, 0.65, 0.4))
	hbox.add_child(ore_lbl)

	var rare_lbl = Label.new()
	rare_lbl.text = "◆ Krysite: %d" % GameState.storage_rare_ore
	rare_lbl.add_theme_color_override("font_color", Color(0.65, 0.4, 1.0))
	hbox.add_child(rare_lbl)

	item_list.add_child(hbox)

	# Divider
	var sep = HSeparator.new()
	item_list.add_child(sep)


func _add_part_row(part_id: String) -> void:
	var part = ProducerData.get_ship_part(part_id)
	if part.is_empty(): return

	var crafted = GameState.spaceship_parts_crafted.get(part_id, false)
	var can_craft = GameState.can_craft_ship_part(part_id)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)

	# Part name row
	var title_row = HBoxContainer.new()
	var name_lbl = Label.new()
	name_lbl.text = part["name"]
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_color_override("font_color",
		Color(0.4, 0.85, 0.5) if crafted else Color(0.83, 0.66, 0.27))
	title_row.add_child(name_lbl)

	if crafted:
		var done_lbl = Label.new()
		done_lbl.text = "✓ BUILT"
		done_lbl.add_theme_color_override("font_color", Color(0.35, 0.8, 0.45))
		done_lbl.add_theme_font_size_override("font_size", 10)
		title_row.add_child(done_lbl)
	else:
		var craft_btn = Button.new()
		craft_btn.text = "CRAFT"
		craft_btn.disabled = not can_craft
		craft_btn.custom_minimum_size = Vector2(52, 0)
		craft_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var pid = part_id
		craft_btn.pressed.connect(func(): _craft_part(pid))
		title_row.add_child(craft_btn)

	vbox.add_child(title_row)

	# Requirements line
	if not crafted:
		var req_parts = []
		var common_stored = GameState.storage_ore - GameState.storage_rare_ore \
			- GameState.storage_aethite - GameState.storage_voidstone - GameState.storage_shards
		if part.get("requires_ore", 0) > 0:
			var have = common_stored
			var need = part["requires_ore"]
			var color = "green" if have >= need else "red"
			req_parts.append("[color=%s]%d/%d Vorax[/color]" % [color, have, need])
		if part.get("requires_rare", 0) > 0:
			var have = GameState.storage_rare_ore
			var need = part["requires_rare"]
			var color = "green" if have >= need else "red"
			req_parts.append("[color=%s]%d/%d Krysite[/color]" % [color, have, need])
		if part.get("credits_cost", 0) > 0:
			var have = GameState.credits
			var need = part["credits_cost"]
			var color = "green" if have >= need else "red"
			req_parts.append("[color=%s]%d/%d CR[/color]" % [color, have, need])

		var req_lbl = RichTextLabel.new()
		req_lbl.bbcode_enabled = true
		req_lbl.text = part["description"] + "  |  " + "  ".join(req_parts)
		req_lbl.add_theme_font_size_override("normal_font_size", 9)
		req_lbl.fit_content = true
		req_lbl.scroll_active = false
		req_lbl.custom_minimum_size = Vector2(0, 24)
		vbox.add_child(req_lbl)

	item_list.add_child(vbox)


func _craft_part(part_id: String) -> void:
	GameState.craft_ship_part(part_id)
	_populate()


func _on_launch_pressed() -> void:
	if GameState.is_ship_ready():
		launch_requested.emit()
		close()
