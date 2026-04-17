extends PanelContainer
## ShopPanel — Side-sliding purchase panel for drones and upgrades.
## Opened by ShopTerminal (DRONES tab default) or DroneBay interaction.
## Layout matches ui_mocks/03_shop_panel.svg.

signal item_purchased(item_id: String, item_type: String)

enum Tab { DRONES, UPGRADES, BUILD }

@onready var item_list:           VBoxContainer = $VBoxContainer/ScrollContainer/ItemList
@onready var title_label:         Label         = $VBoxContainer/Header/HeaderRow/TitleLabel
@onready var close_button:        Button        = $VBoxContainer/Header/HeaderRow/CloseButton
@onready var panel_credits_label: Label         = $VBoxContainer/CreditsRow/CreditsHBox/PanelCreditsLabel
@onready var drones_tab:          Button        = $VBoxContainer/TabRow/TabHBox/DronesTab
@onready var upgrades_tab:        Button        = $VBoxContainer/TabRow/TabHBox/UpgradesTab
@onready var build_tab:           Button        = $VBoxContainer/TabRow/TabHBox/BuildTab

var is_open: bool = false
var shop_terminal_ref: Node2D = null
var _active_tab: Tab = Tab.DRONES

# Amber / dimmed colors for tab active state
const COLOR_ACTIVE  = Color(0.831, 0.659, 0.263, 1)  # #d4a843
const COLOR_DIMMED  = Color(0.659, 0.541, 0.290, 1)  # #a88a4a


func _ready() -> void:
	visible = false
	position.x = get_viewport_rect().size.x
	close_button.pressed.connect(close)
	drones_tab.pressed.connect(func(): _set_tab(Tab.DRONES))
	upgrades_tab.pressed.connect(func(): _set_tab(Tab.UPGRADES))
	build_tab.pressed.connect(func(): _set_tab(Tab.BUILD))

	GameState.credits_changed.connect(func(amt):
		panel_credits_label.text = NumberFormat.format_number(amt)
		if is_open: _populate_items())
	GameState.drone_deployed.connect(func(_d): if is_open: _populate_items())
	GameState.upgrade_purchased.connect(func(_id): if is_open: _populate_items())

	panel_credits_label.text = NumberFormat.format_number(GameState.credits)


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
	shop_terminal_ref = terminal
	title_label.text = "SHOP TERMINAL"
	_set_tab(Tab.DRONES)
	_open_panel()


func open_drone_bay(bay: Node2D = null) -> void:
	shop_terminal_ref = bay
	title_label.text = "DRONE BAY"
	_set_tab(Tab.DRONES)
	_open_panel()


func _open_panel() -> void:
	is_open = true
	position.x = get_viewport_rect().size.x
	visible = true
	_populate_items()
	var panel_width: float = max(size.x, custom_minimum_size.x)
	var target_x: float = get_viewport_rect().size.x - panel_width
	var tween = create_tween()
	tween.tween_property(self, "position:x", target_x, 0.18).set_ease(Tween.EASE_OUT)


func close() -> void:
	if not is_open: return
	is_open = false
	var tween = create_tween()
	tween.tween_property(self, "position:x", get_viewport_rect().size.x, 0.18).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): visible = false)
	if shop_terminal_ref and shop_terminal_ref.has_method("close_shop"):
		shop_terminal_ref.close_shop()
	if shop_terminal_ref and shop_terminal_ref.has_method("close_bay"):
		shop_terminal_ref.close_bay()


func _set_tab(tab: Tab) -> void:
	_active_tab = tab
	drones_tab.add_theme_color_override("font_color",
		COLOR_ACTIVE if tab == Tab.DRONES else COLOR_DIMMED)
	upgrades_tab.add_theme_color_override("font_color",
		COLOR_ACTIVE if tab == Tab.UPGRADES else COLOR_DIMMED)
	build_tab.add_theme_color_override("font_color",
		COLOR_ACTIVE if tab == Tab.BUILD else COLOR_DIMMED)
	if is_open:
		_populate_items()


func _populate_items() -> void:
	for child in item_list.get_children():
		child.queue_free()

	match _active_tab:
		Tab.DRONES:
			_add_section_header("DRONES")
			for drone in ProducerData.get_shop_drones():
				_add_drone_item(drone)
			_add_section_header("FLEET LICENSE")
			for upgrade in ProducerData.get_shop_upgrades():
				if upgrade.get("id") == "fleet_license":
					_add_upgrade_item(upgrade)
			_add_section_header("ASSIGNMENTS")
			_add_drone_assignment_section()

		Tab.UPGRADES:
			_add_section_header("PLAYER")
			for upgrade in ProducerData.get_shop_upgrades():
				if upgrade.get("category") == "player" or upgrade.get("category") == "outpost":
					_add_upgrade_item(upgrade)
			_add_section_header("DRONE MODS")
			for upgrade in ProducerData.get_shop_upgrades():
				if upgrade.get("bay_only", false) and upgrade.get("id") != "fleet_license":
					_add_upgrade_item(upgrade)
			_add_section_header("AUTOMATION")
			for upgrade in ProducerData.get_shop_upgrades():
				if upgrade.get("category") == "automation":
					_add_upgrade_item(upgrade)

		Tab.BUILD:
			_add_section_header("BUILD")
			var placeholder = Label.new()
			placeholder.text = "Coming soon — build outpost structures."
			placeholder.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			placeholder.add_theme_font_size_override("font_size", 10)
			placeholder.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			item_list.add_child(placeholder)


func _add_section_header(text: String) -> void:
	var label = Label.new()
	label.text = "— %s —" % text
	label.add_theme_color_override("font_color", Color(0.659, 0.541, 0.290))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_list.add_child(label)


func _add_drone_item(drone: Dictionary) -> void:
	var can_afford = GameState.can_afford(drone["cost"])
	var can_deploy = GameState.can_deploy_drone()
	var enabled = can_afford and can_deploy
	var row = _make_item_row(
		drone["name"],
		drone["description"],
		"%d CR" % drone["cost"],
		can_afford,
		enabled,
		func(): _purchase_drone(drone["id"])
	)
	if not can_deploy and can_afford:
		row.modulate = Color(0.75, 0.55, 0.55)
		row.tooltip_text = "Fleet full — buy Fleet License"
	item_list.add_child(row)


func _add_upgrade_item(upgrade: Dictionary) -> void:
	if not upgrade["can_purchase"]: return
	var cost = upgrade["actual_cost"]
	var can_afford = GameState.can_afford(cost)
	var row = _make_item_row(
		upgrade["name"],
		upgrade["description"],
		"%d CR" % cost,
		can_afford,
		can_afford,
		func(): _purchase_upgrade(upgrade["id"])
	)
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


func _make_item_row(
	title_text: String,
	desc_text: String,
	cost_text: String,
	_can_afford: bool,
	enabled: bool,
	on_press: Callable
) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var text_col = VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label = Label.new()
	name_label.text = title_text
	name_label.add_theme_color_override("font_color",
		Color(0.831, 0.659, 0.263) if enabled else Color(0.659, 0.541, 0.290))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_col.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = desc_text
	desc_label.add_theme_color_override("font_color", Color(0.659, 0.541, 0.290))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 8)
	text_col.add_child(desc_label)

	row.add_child(text_col)

	# Cost pill — amber stroke if affordable, rust-red if not
	var cost_vbox = VBoxContainer.new()
	cost_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var cost_label = Label.new()
	cost_label.text = cost_text
	cost_label.add_theme_color_override("font_color",
		Color(0.831, 0.659, 0.263) if enabled else Color(0.545, 0.227, 0.165))
	cost_label.add_theme_font_size_override("font_size", 11)
	cost_vbox.add_child(cost_label)

	var btn = Button.new()
	btn.text = "BUY"
	btn.disabled = not enabled
	btn.custom_minimum_size = Vector2(40, 0)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(on_press)
	cost_vbox.add_child(btn)

	row.add_child(cost_vbox)
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
