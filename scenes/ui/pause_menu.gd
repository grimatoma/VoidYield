extends CanvasLayer
## PauseMenu — In-game pause overlay.
## Added to main.tscn as a child node. Toggled by pressing Escape in main.gd.
## PROCESS_MODE_ALWAYS so buttons remain clickable while the tree is paused.

const C_OVERLAY  := Color(0.020, 0.020, 0.040, 0.82)
const C_AMBER    := Color(0.831, 0.658, 0.270)
const C_GREEN    := Color(0.486, 0.721, 0.486)
const C_PANEL    := Color(0.058, 0.058, 0.101)
const C_TEXT_DIM := Color(0.290, 0.290, 0.313)
const C_BORDER   := Color(0.250, 0.250, 0.280)
const C_BG_CARD  := Color(0.040, 0.040, 0.070)

var _saved_label: Label = null


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()


func toggle() -> void:
	if visible:
		_do_hide()
	else:
		_do_show()


func _do_show() -> void:
	visible = true
	if _saved_label:
		_saved_label.visible = false


func _do_hide() -> void:
	visible = false


func _build_ui() -> void:
	# Full-screen dim overlay
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = C_OVERLAY
	add_child(overlay)

	# Centred card
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(260.0, 0.0)
	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color = C_BG_CARD
	card_sb.border_color = C_AMBER
	card_sb.border_width_left  = 1; card_sb.border_width_right  = 1
	card_sb.border_width_top   = 1; card_sb.border_width_bottom = 1
	card_sb.content_margin_left  = 20.0; card_sb.content_margin_right  = 20.0
	card_sb.content_margin_top   = 20.0; card_sb.content_margin_bottom = 20.0
	card.add_theme_stylebox_override("panel", card_sb)
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	card.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "— PAUSED —"
	title.add_theme_color_override("font_color", C_AMBER)
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(_make_sep())

	var resume_btn := _make_button("[ RESUME ]", C_AMBER)
	resume_btn.pressed.connect(_on_resume)
	vbox.add_child(resume_btn)

	var save_btn := _make_button("[ SAVE GAME ]", C_GREEN)
	save_btn.pressed.connect(_on_save)
	vbox.add_child(save_btn)

	vbox.add_child(_make_sep())

	var quit_btn := _make_button("[ SAVE & QUIT ]", C_TEXT_DIM)
	quit_btn.pressed.connect(_on_save_and_quit)
	vbox.add_child(quit_btn)

	# Confirmation label (shown briefly after saving)
	_saved_label = Label.new()
	_saved_label.text = "SAVED."
	_saved_label.add_theme_color_override("font_color", C_GREEN)
	_saved_label.add_theme_font_size_override("font_size", 10)
	_saved_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_saved_label.visible = false
	vbox.add_child(_saved_label)


# --- Helpers ---

func _make_button(lbl: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = lbl
	btn.custom_minimum_size = Vector2(220.0, 36.0)
	btn.add_theme_color_override("font_color", color)
	btn.add_theme_color_override("font_hover_color", C_BG_CARD)
	btn.add_theme_font_size_override("font_size", 13)
	btn.add_theme_stylebox_override("normal", _flat_box(C_PANEL, color.darkened(0.3), 1))
	btn.add_theme_stylebox_override("hover",  _flat_box(color,   color, 1))
	return btn


func _flat_box(bg: Color, border: Color, bw: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_left  = bw; sb.border_width_right  = bw
	sb.border_width_top   = bw; sb.border_width_bottom = bw
	sb.content_margin_left = 8.0; sb.content_margin_right  = 8.0
	sb.content_margin_top  = 4.0; sb.content_margin_bottom = 4.0
	return sb


func _make_sep() -> HSeparator:
	var sep := HSeparator.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_BORDER
	sep.add_theme_stylebox_override("separator", sb)
	return sep


# --- Actions ---

func _on_resume() -> void:
	_do_hide()
	get_tree().paused = false


func _on_save() -> void:
	SaveManager.save_game_immediate()
	if _saved_label:
		_saved_label.visible = true
		# Timer must process while paused — pass process_always = true
		get_tree().create_timer(2.0, true).timeout.connect(
			func(): if is_instance_valid(_saved_label): _saved_label.visible = false
		)


func _on_save_and_quit() -> void:
	SaveManager.save_game_immediate()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
