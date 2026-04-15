extends PanelContainer
## ShopPanel — Side-sliding purchase panel for drones and upgrades.
## Opened by ShopTerminal or DroneBay interaction.

signal item_purchased(item_id: String, item_type: String)

@onready var item_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/ItemList
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleRow/TitleLabel
@onready var close_button: Button = $MarginContainer/VBoxContainer/TitleRow/CloseButton

var is_open: bool = false
var shop_terminal_ref: Node2D = null
var _bay_mode: bool = false


func _ready() -> void:
	visible = false
	position.x = get_viewport_rect().size.x
	close_button.pressed.connect(close)
	GameState.credits_changed.connect(func(_amt): if is_open: _populate_items())
	GameState.drone_deployed.connect(func(_d): if is_open: _populate_items())
	GameState.upgrade_purchased.connect(func(_id): if is_open: _populate_items())


func _process(_delta: float) -> void:
	if not is_open or not is_instance_valid(shop_terminal_ref):
		return
	var player = get_tree().get_first_node_in_group("player")
	if player and player.global_position.distance_to(shop_terminal_ref.global_position) > 80.0:
		close()


func _input(event: InputEvent) -> void:
	if not is_open: return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open(terminal: Node2D = null) -> void:
	_bay_mode = false
	shop_terminal_ref = terminal
	_open_panel()


func open_drone_bay(bay: Node2D = null) -> void:
	_bay_mode = true
	shop_terminal_ref = bay
	_open_panel()


func _open_panel() -> void:
	is_open = true
	position.x = get_viewport_rect().size.x
	visible = true
	_populate_items()
	var panel_width: float = max(size.x, custom_minimum_size.x)
	var target_x: float = get_viewport_rect().size.x - panel_width
	var tween = create_tween()
	tween.tween_property(self, "position:x", target_x, 0.2).set_ease(Tween.EASE_OUT)


func close() -> void:
	if not is_open: return
	is_open = false
	_bay_mode = false
	var tween = create_tween()
	tween.tween_property(self, "position:x", get_viewport_rect().size.x, 0.2).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): visible = false)
	if shop_terminal_ref and shop_terminal_ref.has_method("close_shop"):
		shop_terminal_ref.close_shop()
	if shop_terminal_ref and shop_terminal_ref.has_method("close_bay"):
		shop_terminal_ref.close_bay()


func _populate_items() -> void:
	for child in item_list.get_children():
		child.queue_free()

	if _bay_mode:
		title_label.text = "DRONE BAY"
		_add_section_header("DRONES")
		for drone in ProducerData.get_shop_drones():
			_add_drone_item(drone)
		_add_section_header("DRONE UPGRADES")
		for upgrade in ProducerData.get_shop_upgrades():
			if upgrade.get("bay_only", false):
				_add_upgrade_item(upgrade)
		_add_section_header("ASSIGNMENTS")
		_add_drone_assignment_section()
	else:
		title_label.text = "SHOP"
		_add_section_header("UPGRADES")
		for upgrade in ProducerData.get_shop_upgrades():
			if not upgrade.get("bay_only", false):
				_add_upgrade_item(upgrade)


func _add_section_header(text: String) -> void:
	var label = Label.new()
	label.text = "— %s —" % text
	label.add_theme_color_override("font_color", Color(0.6, 0.5, 0.3))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_list.add_child(label)


func _add_drone_item(drone: Dictionary) -> void:
	var can_afford = GameState.can_afford(drone["cost"])
	var can_deploy = GameState.can_deploy_drone()
	var enabled = can_afford and can_deploy
	var row = _make_item_row(
		"%s  —  %d CR" % [drone["name"], drone["cost"]],
		drone["description"],
		enabled,
		func(): _purchase_drone(drone["id"])
	)
	if not can_afford:
		row.modulate = Color(0.55, 0.55, 0.55)
	elif not can_deploy:
		row.modulate = Color(0.75, 0.55, 0.55)
		row.tooltip_text = "Fleet full — buy Fleet License"
	item_list.add_child(row)


func _add_upgrade_item(upgrade: Dictionary) -> void:
	if not upgrade["can_purchase"]: return
	var cost = upgrade["actual_cost"]
	var can_afford = GameState.can_afford(cost)
	var row = _make_item_row(
		"%s  —  %d CR" % [upgrade["name"], cost],
		upgrade["description"],
		can_afford,
		func(): _purchase_upgrade(upgrade["id"])
	)
	if not can_afford:
		row.modulate = Color(0.55, 0.55, 0.55)
	item_list.add_child(row)


func _add_drone_assignment_section() -> void:
	var drone_bay = get_tree().get_first_node_in_group("drone_bay")
	if not drone_bay:
		return
	var drones = drone_bay.get_active_drones()
	if drones.is_empty():
		var lbl = Label.new()
		lbl.text = "No drones deployed"
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_list.add_child(lbl)
		return

	for i in drones.size():
		var drone = drones[i]
		if not is_instance_valid(drone): continue
		_add_assignment_row(drone, i + 1)


func _add_assignment_row(drone: Node, index: int) -> void:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var lbl = Label.new()
	lbl.text = "Drone %d" % index
	lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)

	var btn = Button.new()
	btn.text = ScoutDrone.assignment_display(drone.ore_assignment) if drone is ScoutDrone else "Mine Any"
	btn.custom_minimum_size = Vector2(90, 0)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var drone_ref = drone
	btn.pressed.connect(func():
		drone_ref.ore_assignment = ScoutDrone.next_assignment(drone_ref.ore_assignment)
		btn.text = ScoutDrone.assignment_display(drone_ref.ore_assignment)
	)
	row.add_child(btn)
	item_list.add_child(row)


func _make_item_row(title: String, description: String, enabled: bool, on_press: Callable) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var text_col = VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label = Label.new()
	name_label.text = title
	name_label.add_theme_color_override("font_color", Color(0.83, 0.66, 0.27))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_col.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = description
	desc_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 10)
	text_col.add_child(desc_label)

	row.add_child(text_col)

	var btn = Button.new()
	btn.text = "BUY"
	btn.disabled = not enabled
	btn.custom_minimum_size = Vector2(40, 0)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(on_press)
	row.add_child(btn)

	return row


func _purchase_drone(drone_id: String) -> void:
	var drone = ProducerData.get_drone(drone_id)
	if drone.is_empty(): return
	if not GameState.spend_credits(drone["cost"]): return
	var drone_bay = get_tree().get_first_node_in_group("drone_bay")
	if drone_bay:
		drone_bay.deploy_drone(drone_id)
		item_purchased.emit(drone_id, "drone")
		_populate_items()


func _purchase_upgrade(upgrade_id: String) -> void:
	if GameState.purchase_upgrade(upgrade_id):
		item_purchased.emit(upgrade_id, "upgrade")
		_populate_items()
