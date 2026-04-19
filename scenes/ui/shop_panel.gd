extends PanelContainer
## ShopPanel — Side-sliding terminal for purchases.
## Modes:
##   shop      — Shop Terminal:  tabs UPGRADES / RESOURCES
##   sell      — Sell Terminal:  opens straight to RESOURCES tab
##   bay       — Drone Bay:     tabs DRONES / UPGRADES / ASSIGNMENTS
##
## Visual style mirrors design_mocks/13_shop_panel.svg — dark amber industrial CRT.

const ScoutDrone = preload("res://scenes/drones/scout_drone.gd")

signal item_purchased(item_id: String, item_type: String)

# --- Color palette (matches the SVG mock) ---
const COLOR_AMBER       = Color(0.831, 0.658, 0.270)
const COLOR_AMBER_DIM   = Color(0.658, 0.541, 0.290)
const COLOR_TEXT_DIM    = Color(0.290, 0.290, 0.313)
const COLOR_RED         = Color(0.545, 0.227, 0.164)
const COLOR_GREEN       = Color(0.486, 0.721, 0.486)
const COLOR_PANEL_DARK  = Color(0.101, 0.101, 0.113)
const COLOR_PANEL_DEEP  = Color(0.058, 0.058, 0.101)
const COLOR_BORDER      = Color(0.290, 0.290, 0.313)

@onready var item_list: VBoxContainer = $VBoxContainer/ScrollContainer/ItemList
@onready var title_label: Label = $VBoxContainer/HeaderPanel/HeaderMargin/TitleRow/TitleLabel
@onready var close_button: Button = $VBoxContainer/HeaderPanel/HeaderMargin/TitleRow/CloseButton
@onready var credits_label: Label = $VBoxContainer/CreditsPanel/CreditsMargin/CreditsRow/CreditsLabel
@onready var tabs_row: HBoxContainer = $VBoxContainer/TabsPanel/TabsRow
@onready var footer_hint: Label = $VBoxContainer/FooterPanel/FooterMargin/FooterHint

var is_open: bool = false
var shop_terminal_ref: Node2D = null
var fabricator_ref: Node2D = null
var _bay_mode: bool = false
var _current_tab: String = ""
var _tab_buttons: Dictionary = {}

# Resource catalogue for the RESOURCES tab.
const RESOURCE_CATALOGUE = [
	{"id": "common",    "name": "VORAX",     "color": Color(0.545, 0.353, 0.164)},
	{"id": "rare",      "name": "KRYSITE",   "color": Color(0.490, 0.341, 0.694)},
	{"id": "aethite",   "name": "AETHITE",   "color": Color(0.486, 0.721, 0.486)},
	{"id": "voidstone", "name": "VOIDSTONE", "color": Color(0.354, 0.560, 0.658)},
	{"id": "shards",    "name": "SHARDS",    "color": Color(0.831, 0.658, 0.270)},
]


func _ready() -> void:
	visible = false
	position.x = get_viewport_rect().size.x
	close_button.pressed.connect(close)
	GameState.credits_changed.connect(_on_credits_changed)
	GameState.drone_deployed.connect(func(_d): if is_open: _populate_items())
	GameState.upgrade_purchased.connect(func(_id): if is_open: _populate_items())
	GameState.inventory_changed.connect(func(_c, _m): if is_open and _current_tab == "resources": _populate_items())
	GameState.storage_changed.connect(func(_s, _c): if is_open and _current_tab == "resources": _populate_items())
	_on_credits_changed(GameState.credits)


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


# --- Open / Close ------------------------------------------------------------

func open(terminal: Node2D = null) -> void:
	_bay_mode = false
	_current_tab = "upgrades"
	shop_terminal_ref = terminal
	_open_panel()


func open_resources(terminal: Node2D = null) -> void:
	_bay_mode = false
	_current_tab = "resources"
	shop_terminal_ref = terminal
	_open_panel()


func open_drone_bay(bay: Node2D = null) -> void:
	_bay_mode = true
	_current_tab = "drones"
	shop_terminal_ref = bay
	_open_panel()


func open_processing_plant(plant: Node2D = null) -> void:
	_bay_mode = false
	_current_tab = "factory"
	shop_terminal_ref = plant
	fabricator_ref = null
	_open_panel()


func open_fabricator(fab: Node2D = null) -> void:
	_bay_mode = false
	_current_tab = "factory"
	fabricator_ref = fab
	shop_terminal_ref = null
	_open_panel()


func _open_panel() -> void:
	is_open = true
	position.x = get_viewport_rect().size.x
	visible = true
	if _bay_mode:
		title_label.text = "DRONE BAY"
	elif _current_tab == "factory":
		title_label.text = "FABRICATOR" if fabricator_ref else "PROCESSING PLANT"
	else:
		title_label.text = "SHOP TERMINAL"
	footer_hint.text = "[E] / CLICK ROW TO BUY    ESC CLOSE"
	_build_tabs()
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
	if shop_terminal_ref:
		if _current_tab == "factory" and shop_terminal_ref.has_method("close_plant"):
			shop_terminal_ref.close_plant()
		elif shop_terminal_ref.has_method("close_shop"):
			shop_terminal_ref.close_shop()
		elif shop_terminal_ref.has_method("close_bay"):
			shop_terminal_ref.close_bay()
		elif shop_terminal_ref.has_method("close_sell"):
			shop_terminal_ref.close_sell()
	if shop_terminal_ref and shop_terminal_ref.has_method("close_bay"):
		shop_terminal_ref.close_bay()
	if shop_terminal_ref and shop_terminal_ref.has_method("close_sell"):
		shop_terminal_ref.close_sell()


# --- Tabs --------------------------------------------------------------------

func _build_tabs() -> void:
	for child in tabs_row.get_children():
		child.queue_free()
	_tab_buttons.clear()

	var tabs: Array
	if _bay_mode:
		tabs = [
			{"id": "drones",      "label": "DRONES"},
			{"id": "upgrades",    "label": "UPGRADES"},
			{"id": "assignments", "label": "ASSIGN"},
		]
	else:
		tabs = [
			{"id": "upgrades",  "label": "UPGRADES"},
			{"id": "resources", "label": "RESOURCES"},
		]

	for t in tabs:
		var btn = _make_tab_button(t["id"], t["label"])
		tabs_row.add_child(btn)
		_tab_buttons[t["id"]] = btn

	_refresh_tab_styles()


func _make_tab_button(tab_id: String, label: String) -> Button:
	var btn = Button.new()
	btn.text = label
	btn.flat = true
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 28)
	btn.add_theme_font_size_override("font_size", 10)
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(func(): _select_tab(tab_id))
	return btn


func _select_tab(tab_id: String) -> void:
	if tab_id == _current_tab:
		return
	_current_tab = tab_id
	_refresh_tab_styles()
	_populate_items()


func _refresh_tab_styles() -> void:
	for tab_id in _tab_buttons:
		var btn: Button = _tab_buttons[tab_id]
		var active = (tab_id == _current_tab)
		btn.add_theme_color_override("font_color",
			COLOR_AMBER if active else COLOR_AMBER_DIM)
		btn.add_theme_color_override("font_hover_color", COLOR_AMBER)
		btn.add_theme_color_override("font_pressed_color", COLOR_AMBER)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		if active:
			sb.border_width_bottom = 2
			sb.border_color = COLOR_AMBER
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)
		btn.add_theme_stylebox_override("focus", sb)


# --- Content -----------------------------------------------------------------

func _populate_items() -> void:
	for child in item_list.get_children():
		child.queue_free()

	match _current_tab:
		"drones":
			for drone in ProducerData.get_shop_drones():
				_add_drone_card(drone)
		"upgrades":
			for upgrade in ProducerData.get_shop_upgrades():
				if _bay_mode:
					if upgrade.get("bay_only", false):
						_add_upgrade_card(upgrade)
				else:
					if not upgrade.get("bay_only", false):
						_add_upgrade_card(upgrade)
		"assignments":
			_add_drone_assignment_section()
		"resources":
			_add_resources_panel()
		"factory":
			if fabricator_ref:
				_add_fabricator_section()
			elif shop_terminal_ref:
				_add_processing_plant_section()


# --- Cards (mock-styled bordered rows) ---------------------------------------

func _make_card(border_color: Color = COLOR_BORDER) -> PanelContainer:
	var card = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = COLOR_PANEL_DARK
	sb.border_color = border_color
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	card.add_theme_stylebox_override("panel", sb)
	return card


func _make_icon(icon_color: Color, icon_size: Vector2 = Vector2(28, 28)) -> PanelContainer:
	var box = PanelContainer.new()
	box.custom_minimum_size = icon_size
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = COLOR_PANEL_DARK
	sb.border_color = COLOR_BORDER
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	box.add_theme_stylebox_override("panel", sb)
	var inner = ColorRect.new()
	inner.color = icon_color
	inner.custom_minimum_size = icon_size - Vector2(8, 8)
	inner.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	inner.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(inner)
	return box


func _make_price_button(text: String, enabled: bool, owned: bool, on_press: Callable) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.disabled = not enabled and not owned
	btn.custom_minimum_size = Vector2(74, 24)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 11)
	btn.focus_mode = Control.FOCUS_NONE

	var border: Color
	var fg: Color
	if owned:
		border = COLOR_GREEN
		fg = COLOR_GREEN
	elif enabled:
		border = COLOR_AMBER
		fg = COLOR_AMBER
	else:
		border = COLOR_RED
		fg = COLOR_RED

	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.164, 0.164, 0.180, 1)
		sb.border_color = border
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		btn.add_theme_stylebox_override(state, sb)
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_color_override("font_disabled_color", fg)
	btn.add_theme_color_override("font_hover_color", COLOR_AMBER)
	btn.add_theme_color_override("font_pressed_color", COLOR_AMBER)
	if on_press.is_valid():
		btn.pressed.connect(on_press)
	return btn


func _add_drone_card(drone: Dictionary) -> void:
	var can_afford = GameState.can_afford(drone["cost"])
	var can_deploy = GameState.can_deploy_drone()
	var enabled = can_afford and can_deploy

	var card = _make_card()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	row.add_child(_make_icon(Color(0.486, 0.721, 0.486)))

	var col = VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)

	var name_lbl = Label.new()
	name_lbl.text = String(drone["name"]).to_upper()
	name_lbl.add_theme_color_override("font_color", COLOR_AMBER if enabled else COLOR_AMBER_DIM)
	name_lbl.add_theme_font_size_override("font_size", 11)
	col.add_child(name_lbl)

	var stats_lbl = Label.new()
	stats_lbl.text = "%dpx/s · %d ore · %.1fs" % [drone["speed"], drone["carry_capacity"], drone["mine_time"]]
	stats_lbl.add_theme_color_override("font_color", COLOR_AMBER_DIM)
	stats_lbl.add_theme_font_size_override("font_size", 9)
	col.add_child(stats_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = drone["description"]
	desc_lbl.add_theme_color_override("font_color", COLOR_AMBER_DIM)
	desc_lbl.add_theme_font_size_override("font_size", 9)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(desc_lbl)

	var price_text = "%d CR" % drone["cost"]
	var btn = _make_price_button(price_text, enabled, false, func(): _purchase_drone(drone["id"]))
	if not can_deploy and can_afford:
		btn.tooltip_text = "Fleet full — buy Fleet License"
	row.add_child(btn)

	if not can_afford:
		card.modulate = Color(1, 1, 1, 0.55)
	elif not can_deploy:
		card.modulate = Color(1, 0.9, 0.9, 0.85)

	item_list.add_child(card)


func _add_upgrade_card(upgrade: Dictionary) -> void:
	if not upgrade["can_purchase"]:
		_add_owned_upgrade_card(upgrade)
		return
	var cost = upgrade["actual_cost"]
	var can_afford = GameState.can_afford(cost)

	var card = _make_card()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	var col = VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)

	var name_lbl = Label.new()
	name_lbl.text = String(upgrade["name"]).to_upper()
	name_lbl.add_theme_color_override("font_color", COLOR_AMBER if can_afford else COLOR_AMBER_DIM)
	name_lbl.add_theme_font_size_override("font_size", 11)
	col.add_child(name_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = upgrade["description"]
	desc_lbl.add_theme_color_override("font_color", COLOR_AMBER_DIM)
	desc_lbl.add_theme_font_size_override("font_size", 9)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(desc_lbl)

	var max_purchases = upgrade.get("max_purchases", 1)
	if max_purchases > 1:
		col.add_child(_make_level_dots(GameState.get_upgrade_count(upgrade["id"]), max_purchases))

	var btn = _make_price_button("%d CR" % cost, can_afford, false, func(): _purchase_upgrade(upgrade["id"]))
	row.add_child(btn)

	if not can_afford:
		card.modulate = Color(1, 1, 1, 0.55)

	item_list.add_child(card)


func _add_owned_upgrade_card(upgrade: Dictionary) -> void:
	var card = _make_card()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	var col = VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)

	var name_lbl = Label.new()
	name_lbl.text = String(upgrade["name"]).to_upper()
	name_lbl.add_theme_color_override("font_color", COLOR_AMBER)
	name_lbl.add_theme_font_size_override("font_size", 11)
	col.add_child(name_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = upgrade["description"]
	desc_lbl.add_theme_color_override("font_color", COLOR_AMBER_DIM)
	desc_lbl.add_theme_font_size_override("font_size", 9)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(desc_lbl)

	var btn = _make_price_button("INSTALLED", false, true, Callable())
	btn.disabled = true
	row.add_child(btn)

	item_list.add_child(card)


func _make_level_dots(filled: int, total: int) -> HBoxContainer:
	var box = HBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	for i in total:
		var dot = ColorRect.new()
		dot.custom_minimum_size = Vector2(10, 10)
		dot.color = COLOR_AMBER if i < filled else COLOR_BORDER
		box.add_child(dot)
	var lbl = Label.new()
	lbl.text = "  LV %d / %d" % [filled, total]
	lbl.add_theme_color_override("font_color", COLOR_AMBER_DIM)
	lbl.add_theme_font_size_override("font_size", 9)
	box.add_child(lbl)
	return box


# --- RESOURCES tab -----------------------------------------------------------

func _add_resources_panel() -> void:
	_add_resources_summary()
	for res in RESOURCE_CATALOGUE:
		_add_resource_trade_row(res)


func _add_resources_summary() -> void:
	var card = _make_card(COLOR_AMBER)
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var col = VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	margin.add_child(col)

	var pool_row = HBoxContainer.new()
	pool_row.add_theme_constant_override("separation", 6)
	col.add_child(pool_row)

	var pool_prefix = Label.new()
	pool_prefix.text = "POOL"
	pool_prefix.add_theme_color_override("font_color", COLOR_AMBER_DIM)
	pool_prefix.add_theme_font_size_override("font_size", 9)
	pool_row.add_child(pool_prefix)

	var pool_value = Label.new()
	pool_value.text = "%03d / %03d" % [GameState.storage_ore, GameState.storage_capacity]
	pool_value.add_theme_color_override("font_color", COLOR_AMBER)
	pool_value.add_theme_font_size_override("font_size", 14)
	pool_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pool_row.add_child(pool_value)

	var rate_lbl = Label.new()
	var carried = GameState.player_carried_ore
	rate_lbl.text = "CARRIED %d / %d" % [carried, GameState.player_max_carry]
	rate_lbl.add_theme_color_override("font_color", COLOR_AMBER_DIM)
	rate_lbl.add_theme_font_size_override("font_size", 9)
	pool_row.add_child(rate_lbl)

	# Segmented progress bar
	var bar = ProgressBar.new()
	bar.max_value = max(1, GameState.storage_capacity)
	bar.value = GameState.storage_ore
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 8)
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = COLOR_PANEL_DEEP
	bar_bg.border_color = COLOR_BORDER
	bar_bg.border_width_left = 1
	bar_bg.border_width_top = 1
	bar_bg.border_width_right = 1
	bar_bg.border_width_bottom = 1
	var bar_fg := StyleBoxFlat.new()
	bar_fg.bg_color = COLOR_AMBER
	bar.add_theme_stylebox_override("background", bar_bg)
	bar.add_theme_stylebox_override("fill", bar_fg)
	col.add_child(bar)

	var sell_all_btn = Button.new()
	sell_all_btn.text = "SELL ALL"
	sell_all_btn.custom_minimum_size = Vector2(0, 28)
	sell_all_btn.add_theme_font_size_override("font_size", 12)
	sell_all_btn.add_theme_color_override("font_color", COLOR_AMBER)
	sell_all_btn.add_theme_color_override("font_hover_color", COLOR_AMBER)
	sell_all_btn.add_theme_color_override("font_disabled_color", COLOR_TEXT_DIM)
	sell_all_btn.disabled = (GameState.storage_ore <= 0 and GameState.player_carried_ore <= 0)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = COLOR_PANEL_DARK
		sb.border_color = COLOR_AMBER if not sell_all_btn.disabled else COLOR_BORDER
		sb.border_width_left = 2
		sb.border_width_top = 2
		sb.border_width_right = 2
		sb.border_width_bottom = 2
		sell_all_btn.add_theme_stylebox_override(state, sb)
	sell_all_btn.pressed.connect(_on_sell_all_pressed)
	col.add_child(sell_all_btn)

	item_list.add_child(card)


func _add_resource_trade_row(res: Dictionary) -> void:
	var rid: String = res["id"]
	var carried = GameState.get_carried_of(rid)
	var stored = GameState.get_storage_of(rid)
	var sell_price = GameState.get_resource_sell_price(rid)
	var buy_price = GameState.get_resource_buy_price(rid)

	var card = _make_card()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	row.add_child(_make_icon(res["color"], Vector2(26, 26)))

	var col = VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)

	var name_lbl = Label.new()
	name_lbl.text = String(res["name"])
	name_lbl.add_theme_color_override("font_color", COLOR_AMBER)
	name_lbl.add_theme_font_size_override("font_size", 11)
	col.add_child(name_lbl)

	var stock_lbl = Label.new()
	stock_lbl.text = "carried %d · pool %d" % [carried, stored]
	stock_lbl.add_theme_color_override("font_color", COLOR_AMBER_DIM)
	stock_lbl.add_theme_font_size_override("font_size", 9)
	col.add_child(stock_lbl)

	var price_lbl = Label.new()
	price_lbl.text = "sell %d CR  ·  buy %d CR" % [sell_price, buy_price]
	price_lbl.add_theme_color_override("font_color", COLOR_AMBER_DIM)
	price_lbl.add_theme_font_size_override("font_size", 9)
	col.add_child(price_lbl)

	# Trade buttons column
	var btn_col = VBoxContainer.new()
	btn_col.add_theme_constant_override("separation", 4)
	btn_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(btn_col)

	# SELL row
	var sell_row = HBoxContainer.new()
	sell_row.add_theme_constant_override("separation", 2)
	btn_col.add_child(sell_row)
	var sell_total = carried + stored
	sell_row.add_child(_make_trade_button("-1", sell_total > 0, false,
		func(): _sell_resource(rid, 1)))
	sell_row.add_child(_make_trade_button("-10", sell_total > 0, false,
		func(): _sell_resource(rid, 10)))

	# BUY row
	var buy_row = HBoxContainer.new()
	buy_row.add_theme_constant_override("separation", 2)
	btn_col.add_child(buy_row)
	var space = GameState.storage_capacity - GameState.storage_ore
	var can_buy_one = GameState.can_afford(buy_price) and space > 0
	var can_buy_ten = GameState.can_afford(buy_price * 10) and space >= 10
	buy_row.add_child(_make_trade_button("+1", can_buy_one, true,
		func(): _buy_resource(rid, 1)))
	buy_row.add_child(_make_trade_button("+10", can_buy_ten, true,
		func(): _buy_resource(rid, 10)))

	item_list.add_child(card)


func _make_trade_button(text: String, enabled: bool, is_buy: bool, on_press: Callable) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.disabled = not enabled
	btn.custom_minimum_size = Vector2(36, 22)
	btn.add_theme_font_size_override("font_size", 10)
	btn.focus_mode = Control.FOCUS_NONE
	var border = COLOR_AMBER if enabled else COLOR_BORDER
	var fg = COLOR_AMBER if enabled else COLOR_TEXT_DIM
	if is_buy and enabled:
		border = COLOR_GREEN
		fg = COLOR_GREEN
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = COLOR_PANEL_DARK
		sb.border_color = border
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		btn.add_theme_stylebox_override(state, sb)
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_color_override("font_disabled_color", fg)
	btn.add_theme_color_override("font_hover_color", COLOR_AMBER)
	if on_press.is_valid():
		btn.pressed.connect(on_press)
	return btn


# --- FABRICATOR tab ---------------------------------------------------------

func _add_fabricator_section() -> void:
	if not fabricator_ref:
		return

	var recipes = {"craft_drill": "Basic Drill", "craft_surveyor": "Surveyor Kit", "craft_fuel_cell": "Fuel Cell"}

	# Recipe selection card
	var recipe_card = _make_card()
	var recipe_margin = MarginContainer.new()
	recipe_margin.add_theme_constant_override("margin_left", 8)
	recipe_margin.add_theme_constant_override("margin_top", 6)
	recipe_margin.add_theme_constant_override("margin_right", 8)
	recipe_margin.add_theme_constant_override("margin_bottom", 6)
	recipe_card.add_child(recipe_margin)

	var recipe_vbox = VBoxContainer.new()
	recipe_margin.add_child(recipe_vbox)

	var recipe_label = Label.new()
	recipe_label.text = "RECIPE:"
	recipe_label.add_theme_color_override("font_color", COLOR_AMBER)
	recipe_label.add_theme_font_size_override("font_size", 10)
	recipe_vbox.add_child(recipe_label)

	var recipe_btn = Button.new()
	recipe_btn.text = recipes.get(fabricator_ref.current_recipe_id, "None Selected")
	recipe_btn.custom_minimum_size = Vector2(0, 24)
	recipe_btn.add_theme_color_override("font_color", COLOR_AMBER)
	recipe_vbox.add_child(recipe_btn)

	recipe_btn.pressed.connect(func():
		fabricator_ref.current_recipe_id = recipes.keys()[0]
		_populate_items()
	)

	item_list.add_child(recipe_card)

	# Control buttons
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	item_list.add_child(spacer)

	var controls_card = _make_card()
	var controls_margin = MarginContainer.new()
	controls_margin.add_theme_constant_override("margin_left", 8)
	controls_margin.add_theme_constant_override("margin_top", 6)
	controls_margin.add_theme_constant_override("margin_right", 8)
	controls_margin.add_theme_constant_override("margin_bottom", 6)
	controls_card.add_child(controls_margin)

	var controls_hbox = HBoxContainer.new()
	controls_hbox.add_theme_constant_override("separation", 4)
	controls_margin.add_child(controls_hbox)

	var start_btn = Button.new()
	start_btn.text = "START"
	start_btn.custom_minimum_size = Vector2(64, 24)
	start_btn.add_theme_color_override("font_color", COLOR_AMBER)
	start_btn.pressed.connect(func(): fabricator_ref.start())
	controls_hbox.add_child(start_btn)

	var stop_btn = Button.new()
	stop_btn.text = "STOP"
	stop_btn.custom_minimum_size = Vector2(64, 24)
	stop_btn.add_theme_color_override("font_color", COLOR_AMBER)
	stop_btn.pressed.connect(func(): fabricator_ref.stop())
	controls_hbox.add_child(stop_btn)

	item_list.add_child(controls_card)


func _add_processing_plant_section() -> void:
	var lbl = Label.new()
	lbl.text = "Processing Plant\n(Not yet implemented)"
	lbl.add_theme_color_override("font_color", COLOR_TEXT_DIM)
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_list.add_child(lbl)


# --- ASSIGNMENTS tab (drone bay) ---------------------------------------------

func _add_drone_assignment_section() -> void:
	var drone_bay = get_tree().get_first_node_in_group("drone_bay")
	if not drone_bay:
		return
	var drones = drone_bay.get_active_drones()
	if drones.is_empty():
		var lbl = Label.new()
		lbl.text = "No drones deployed"
		lbl.add_theme_color_override("font_color", COLOR_TEXT_DIM)
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_list.add_child(lbl)
		return

	for i in drones.size():
		var drone = drones[i]
		if not is_instance_valid(drone): continue
		_add_assignment_row(drone, i + 1)

	# Add RECALL ALL button
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	item_list.add_child(spacer)

	var recall_card = _make_card()
	var recall_margin = MarginContainer.new()
	recall_margin.add_theme_constant_override("margin_left", 8)
	recall_margin.add_theme_constant_override("margin_top", 6)
	recall_margin.add_theme_constant_override("margin_right", 8)
	recall_margin.add_theme_constant_override("margin_bottom", 6)
	recall_card.add_child(recall_margin)

	var recall_btn = Button.new()
	recall_btn.text = "RECALL ALL"
	recall_btn.custom_minimum_size = Vector2(0, 28)
	recall_btn.add_theme_color_override("font_color", COLOR_AMBER)
	recall_btn.add_theme_font_size_override("font_size", 12)
	recall_margin.add_child(recall_btn)
	recall_btn.pressed.connect(func():
		for drone in drones:
			if is_instance_valid(drone):
				drone.current_state = 0
	)
	item_list.add_child(recall_card)


func _add_assignment_row(drone: Node, index: int) -> void:
	var card = _make_card()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	card.add_child(margin)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	margin.add_child(row)

	var lbl = Label.new()
	lbl.text = "DRONE %d" % index
	lbl.add_theme_color_override("font_color", COLOR_AMBER)
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)

	var btn = Button.new()
	btn.text = ScoutDrone.assignment_display(drone.ore_assignment) if drone is ScoutDrone else "Mine Any"
	btn.custom_minimum_size = Vector2(96, 0)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.add_theme_color_override("font_color", COLOR_AMBER)
	btn.focus_mode = Control.FOCUS_NONE
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = COLOR_PANEL_DARK
		sb.border_color = COLOR_AMBER
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		btn.add_theme_stylebox_override(state, sb)
	var drone_ref = drone
	btn.pressed.connect(func():
		drone_ref.ore_assignment = ScoutDrone.next_assignment(drone_ref.ore_assignment)
		btn.text = ScoutDrone.assignment_display(drone_ref.ore_assignment)
	)
	row.add_child(btn)
	item_list.add_child(card)


# --- Actions -----------------------------------------------------------------

func _purchase_drone(drone_id: String) -> void:
	var drone = ProducerData.get_drone(drone_id)
	if drone.is_empty(): return
	if not GameState.spend_credits(drone["cost"]): return
	var drone_bay = get_tree().get_first_node_in_group("drone_bay")
	if drone_bay:
		drone_bay.deploy_drone(drone_id)
		AudioManager.play_purchase_chime()
		item_purchased.emit(drone_id, "drone")
		_populate_items()


func _purchase_upgrade(upgrade_id: String) -> void:
	if GameState.purchase_upgrade(upgrade_id):
		AudioManager.play_purchase_chime()
		item_purchased.emit(upgrade_id, "upgrade")
		_populate_items()


func _sell_resource(resource_type: String, amount: int) -> void:
	# Sell carried first, then drain pool.
	var carried = GameState.get_carried_of(resource_type)
	var sold = 0
	if carried > 0:
		sold = min(carried, amount)
		GameState.sell_resource(resource_type, sold)
	var remainder = amount - sold
	if remainder > 0:
		GameState.sell_from_storage(resource_type, remainder)
	_populate_items()


func _buy_resource(resource_type: String, amount: int) -> void:
	GameState.buy_resource_to_storage(resource_type, amount)
	_populate_items()


func _on_sell_all_pressed() -> void:
	GameState.sell_all_ore()
	_populate_items()


# --- Signal Handlers ---------------------------------------------------------

func _on_credits_changed(amount: int) -> void:
	if credits_label:
		credits_label.text = _format_credits(amount)
	if is_open:
		_populate_items()


func _format_credits(amount: int) -> String:
	var raw = str(absi(amount)).pad_zeros(6)
	var formatted = ""
	var count = 0
	for i in range(raw.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			formatted = "," + formatted
		formatted = raw[i] + formatted
		count += 1
	if amount < 0:
		formatted = "-" + formatted
	return formatted
