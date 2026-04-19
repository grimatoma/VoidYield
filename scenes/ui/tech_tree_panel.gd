extends PanelContainer
## TechTreePanel — Side-sliding panel for tech tree research and node unlocking.

signal node_unlock_requested(node_id: String)

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
@onready var rp_label: Label = $VBoxContainer/RPPanel/RPMargin/RPRow/RPLabel
@onready var tabs_row: HBoxContainer = $VBoxContainer/TabsPanel/TabsRow
@onready var footer_hint: Label = $VBoxContainer/FooterPanel/FooterMargin/FooterHint

var is_open: bool = false
var _current_tab: String = ""
var _tab_buttons: Dictionary = {}


func _ready() -> void:
	visible = false
	position.x = get_viewport_rect().size.x
	close_button.pressed.connect(close)
	TechTree.rp_changed.connect(_on_rp_changed)
	TechTree.node_unlocked.connect(_on_node_unlocked)
	_on_rp_changed(TechTree.research_points)


func _process(_delta: float) -> void:
	if not is_open:
		return


func _input(event: InputEvent) -> void:
	if not is_open: return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


# --- Open / Close ---

func open() -> void:
	_current_tab = "all"
	_open_panel()


func _open_panel() -> void:
	is_open = true
	position.x = get_viewport_rect().size.x
	visible = true
	title_label.text = "TECH TREE"
	footer_hint.text = "RESEARCH POINTS: %s" % TechTree.research_points
	_populate_items()
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


# --- Item List Population ---

func _populate_items() -> void:
	for child in item_list.get_children():
		child.queue_free()
	var unlockable_nodes = _get_unlockable_nodes()

	for node_id in unlockable_nodes:
		var node_data = TechTree.get_node_data(node_id)
		if node_data.is_empty():
			continue

		var card = PanelContainer.new()
		card.add_theme_stylebox_override("panel", StyleBoxFlat.new() if not _is_unlocked(node_id) else _create_unlocked_style())
		var vbox = VBoxContainer.new()
		card.add_child(vbox)

		var name_label = Label.new()
		name_label.text = node_data.get("name", node_id)
		name_label.add_theme_color_override("font_color", COLOR_AMBER)
		vbox.add_child(name_label)

		var cost_label = Label.new()
		var rp_cost = node_data.get("rp_cost", 0)
		var cr_cost = node_data.get("cr_cost", 0)
		cost_label.text = "RP: %d | CR: %d" % [rp_cost, cr_cost]
		cost_label.add_theme_color_override("font_color", COLOR_TEXT_DIM)
		cost_label.add_theme_font_size_override("font_size", 10)
		vbox.add_child(cost_label)

		var hbox = HBoxContainer.new()
		vbox.add_child(hbox)

		var unlock_btn = Button.new()
		unlock_btn.text = "UNLOCK" if not _is_unlocked(node_id) else "✓ UNLOCKED"
		unlock_btn.disabled = _is_unlocked(node_id) or not TechTree.can_unlock(node_id)
		unlock_btn.add_theme_color_override("font_color", COLOR_AMBER)
		unlock_btn.custom_minimum_size = Vector2(80, 24)
		var btn_ref = unlock_btn
		var node_id_ref = node_id
		unlock_btn.pressed.connect(func(): _on_unlock_pressed(node_id_ref))
		hbox.add_child(unlock_btn)

		item_list.add_child(card)


func _get_unlockable_nodes() -> Array:
	var nodes = []
	var all_nodes = TechTree.TechTreeData.NODES if TechTree.TechTreeData else {}
	var count = 0

	for node_id in all_nodes:
		nodes.append(node_id)
		count += 1
		if count >= 10:
			break

	return nodes


func _is_unlocked(node_id: String) -> bool:
	return TechTree.is_unlocked(node_id)


func _create_unlocked_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL_DEEP
	return style


# --- Callbacks ---

func _on_unlock_pressed(node_id: String) -> void:
	if TechTree.unlock(node_id):
		_populate_items()
		node_unlock_requested.emit(node_id)


func _on_rp_changed(new_rp: float) -> void:
	rp_label.text = "Research Points: %.1f" % new_rp
	if is_open:
		footer_hint.text = "RESEARCH POINTS: %s" % new_rp
		_populate_items()


func _on_node_unlocked(_node_id: String) -> void:
	if is_open:
		_populate_items()
