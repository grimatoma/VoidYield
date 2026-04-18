extends Control
## OptionsPanel — Settings overlay for VoidYield.
## Matches the amber CRT aesthetic of pause_menu.gd and main_menu.gd.
## Instantiate and add as a child; call show_panel() / hide_panel().

const C_OVERLAY  := Color(0.020, 0.020, 0.040, 0.88)
const C_AMBER    := Color(0.831, 0.658, 0.270)
const C_GREEN    := Color(0.486, 0.721, 0.486)
const C_PANEL    := Color(0.058, 0.058, 0.101)
const C_TEXT_DIM := Color(0.290, 0.290, 0.313)
const C_BORDER   := Color(0.250, 0.250, 0.280)
const C_BG_CARD  := Color(0.040, 0.040, 0.070)

signal closed

var _music_slider: HSlider = null
var _sfx_slider: HSlider   = null
var _fs_check: CheckButton  = null

# Resolved at runtime to avoid static-analysis errors when SettingsManager
# is registered in project.godot but not yet known to the editor's script parser.
var _sm: Node = null


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if Engine.has_singleton("SettingsManager"):
		_sm = Engine.get_singleton("SettingsManager")
	_build_ui()


func show_panel() -> void:
	# Sync sliders to current live values before showing
	if _sm:
		if _music_slider:
			_music_slider.value = _sm.music_volume
		if _sfx_slider:
			_sfx_slider.value = _sm.sfx_volume
		if _fs_check:
			_fs_check.button_pressed = _sm.fullscreen
	visible = true


func hide_panel() -> void:
	visible = false
	closed.emit()


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
	card.custom_minimum_size = Vector2(320.0, 0.0)
	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color = C_BG_CARD
	card_sb.border_color = C_AMBER
	card_sb.border_width_left  = 1; card_sb.border_width_right  = 1
	card_sb.border_width_top   = 1; card_sb.border_width_bottom = 1
	card_sb.content_margin_left  = 24.0; card_sb.content_margin_right  = 24.0
	card_sb.content_margin_top   = 20.0; card_sb.content_margin_bottom = 20.0
	card.add_theme_stylebox_override("panel", card_sb)
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	card.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "— OPTIONS —"
	title.add_theme_color_override("font_color", C_AMBER)
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(_make_sep())

	# --- Audio section ---
	_add_section_label(vbox, "AUDIO")

	var music_vol: float = _sm.music_volume if _sm else 0.8
	_music_slider = _add_slider_row(vbox, "MUSIC VOLUME", music_vol,
		func(v: float): if _sm: _sm.set_music(v))

	var sfx_vol: float = _sm.sfx_volume if _sm else 1.0
	_sfx_slider = _add_slider_row(vbox, "SFX VOLUME", sfx_vol,
		func(v: float): if _sm: _sm.set_sfx(v))

	vbox.add_child(_make_sep())

	# --- Display section ---
	_add_section_label(vbox, "DISPLAY")

	var fs_val: bool = _sm.fullscreen if _sm else false
	_fs_check = _add_checkbox_row(vbox, "FULLSCREEN", fs_val,
		func(v: bool): if _sm: _sm.set_fullscreen(v))

	vbox.add_child(_make_sep())

	# --- Close button ---
	var close_btn := _make_button("[ CLOSE ]", C_AMBER)
	close_btn.pressed.connect(hide_panel)
	vbox.add_child(close_btn)


# --- Helpers ---

func _add_section_label(parent: VBoxContainer, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", C_TEXT_DIM)
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	parent.add_child(lbl)


func _add_slider_row(parent: VBoxContainer, label_text: String, init_val: float, on_change: Callable) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(140.0, 0.0)
	lbl.add_theme_color_override("font_color", C_AMBER)
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = init_val
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(0.0, 24.0)
	_style_slider(slider)
	slider.value_changed.connect(on_change)
	row.add_child(slider)

	return slider


func _add_checkbox_row(parent: VBoxContainer, label_text: String, init_val: bool, on_toggle: Callable) -> CheckButton:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(140.0, 0.0)
	lbl.add_theme_color_override("font_color", C_AMBER)
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl)

	var check := CheckButton.new()
	check.button_pressed = init_val
	check.add_theme_color_override("font_color", C_GREEN)
	check.add_theme_font_size_override("font_size", 12)
	check.toggled.connect(on_toggle)
	row.add_child(check)

	return check


func _style_slider(slider: HSlider) -> void:
	var grabber_sb := StyleBoxFlat.new()
	grabber_sb.bg_color = C_AMBER
	grabber_sb.set_corner_radius_all(3)
	slider.add_theme_stylebox_override("grabber_area", grabber_sb)

	var bg_sb := StyleBoxFlat.new()
	bg_sb.bg_color = C_PANEL
	bg_sb.border_color = C_BORDER
	bg_sb.border_width_top = 1; bg_sb.border_width_bottom = 1
	slider.add_theme_stylebox_override("slider", bg_sb)


func _make_button(lbl: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = lbl
	btn.custom_minimum_size = Vector2(272.0, 36.0)
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
