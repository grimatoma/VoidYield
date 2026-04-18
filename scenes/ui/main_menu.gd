extends Control
## MainMenu — Boot scene. CRT-styled title screen for VoidYield.
## Builds all UI in code to match the game's industrial amber aesthetic.

# Colour palette — matches shop_panel.gd
const C_BG        := Color(0.040, 0.040, 0.070)
const C_AMBER     := Color(0.831, 0.658, 0.270)
const C_GREEN     := Color(0.486, 0.721, 0.486)
const C_PANEL     := Color(0.058, 0.058, 0.101)
const C_TEXT_DIM  := Color(0.290, 0.290, 0.313)
const C_BORDER    := Color(0.250, 0.250, 0.280)

var _stars: Array[Dictionary] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_generate_stars()
	_build_ui()


func _draw() -> void:
	var sz := get_rect().size
	draw_rect(Rect2(Vector2.ZERO, sz), C_BG)
	for s in _stars:
		draw_circle(s["pos"], s["size"], Color(1.0, 1.0, 1.0, s["alpha"]))
	# Subtle CRT scanlines
	for y in range(0, int(sz.y), 4):
		draw_line(Vector2(0.0, float(y)), Vector2(sz.x, float(y)), Color(0.0, 0.0, 0.0, 0.06))


func _generate_stars() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 0xDEADF00D
	var sz := Vector2(960.0, 540.0)
	for _i in 80:
		_stars.append({
			"pos":   Vector2(rng.randf() * sz.x, rng.randf() * sz.y),
			"size":  rng.randf_range(0.5, 1.5),
			"alpha": rng.randf_range(0.2, 0.85),
		})


func _build_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(280.0, 0.0)
	vbox.add_theme_constant_override("separation", 10)
	center.add_child(vbox)

	# --- Logo / Title ---
	var title := Label.new()
	title.text = "VOID YIELD"
	title.add_theme_color_override("font_color", C_AMBER)
	title.add_theme_font_size_override("font_size", 44)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "DEEP CORE EXTRACTION SYSTEM"
	subtitle.add_theme_color_override("font_color", C_TEXT_DIM)
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)

	vbox.add_child(_make_separator())
	vbox.add_child(_make_spacer(8.0))

	# --- Buttons ---
	var new_btn := _make_button("[ NEW GAME ]", C_AMBER)
	new_btn.pressed.connect(_on_new_game)
	vbox.add_child(new_btn)

	var has_save := SaveManager.has_save()
	var cont_btn := _make_button("[ CONTINUE ]", C_GREEN)
	cont_btn.disabled = not has_save
	if not has_save:
		cont_btn.modulate.a = 0.35
	cont_btn.pressed.connect(_on_continue)
	vbox.add_child(cont_btn)

	vbox.add_child(_make_separator())

	var quit_btn := _make_button("[ QUIT ]", C_TEXT_DIM)
	quit_btn.pressed.connect(_on_quit)
	vbox.add_child(quit_btn)

	# --- Version stamp ---
	var ver := Label.new()
	ver.text = "v0.1-alpha"
	ver.add_theme_color_override("font_color", C_TEXT_DIM)
	ver.add_theme_font_size_override("font_size", 9)
	ver.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	ver.offset_left = -80.0; ver.offset_top = -24.0
	ver.offset_right = -8.0; ver.offset_bottom = -8.0
	add_child(ver)


# --- Helpers ---

func _make_button(label_text: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(260.0, 38.0)
	btn.add_theme_color_override("font_color", color)
	btn.add_theme_color_override("font_hover_color", C_BG)
	btn.add_theme_color_override("font_focus_color", color)
	btn.add_theme_color_override("font_disabled_color", color.darkened(0.6))
	btn.add_theme_font_size_override("font_size", 14)

	btn.add_theme_stylebox_override("normal",   _flat_box(C_PANEL, color.darkened(0.3), 1))
	btn.add_theme_stylebox_override("hover",    _flat_box(color, color, 1))
	btn.add_theme_stylebox_override("pressed",  _flat_box(color.darkened(0.2), color, 1))
	btn.add_theme_stylebox_override("disabled", _flat_box(C_PANEL, C_BORDER, 1))
	btn.add_theme_stylebox_override("focus",    _flat_box(C_PANEL, color, 2))
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


func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_BORDER
	sep.add_theme_stylebox_override("separator", sb)
	return sep


func _make_spacer(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0.0, h)
	return c


# --- Actions ---

func _on_new_game() -> void:
	if not GameState.debug_click_mode:
		GameState.reset_to_defaults()
		SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_continue() -> void:
	# SaveManager.load_game() already ran at startup (if not debug mode).
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit() -> void:
	get_tree().quit()
