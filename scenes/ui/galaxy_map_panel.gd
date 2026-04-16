extends Control
## GalaxyMapPanel — Full-screen galaxy map shown when launching from a ship
## or launch pad. Lets the player select a known body and travel to it.

signal travel_requested(destination_id: String)
signal closed

# --- Palette (from ui_mocks/_shared.md) ---
const COL_AMBER     := Color("d4a843")
const COL_AMBER_DIM := Color("a88a4a")
const COL_GOOD      := Color("7cb87c")
const COL_WARN      := Color("8b3a2a")
const COL_INFO      := Color("5a8fa8")
const COL_RIM       := Color("4a4a50")
const COL_BG_DEEP   := Color("06060a")
const COL_BG_PANEL  := Color("1a1a1d")
const COL_SHADOW    := Color("15151a")

# --- Planet registry ---
# Ordered list; indices map to the A1/A2/A3 display slots in the mock.
const PLANETS := [
	{
		"id": "asteroid_a1",
		"display_id": "A1",
		"name": "IRON ROCK",
		"scene_path": "res://scenes/world/asteroid_field.tscn",
		"spawn": Vector2(280, 420),
		"pos": Vector2(250, 320),
		"status": "known",
		"tagline": "VORAX · KRYSITE",
		"color": Color("8b5a2a"),
	},
	{
		"id": "planet_b",
		"display_id": "A2",
		"name": "VORTEX DRIFT",
		"scene_path": "res://scenes/world/planet_b.tscn",
		"spawn": Vector2(280, 330),
		"pos": Vector2(540, 220),
		"status": "known",
		"tagline": "AETHITE · VOIDSTONE",
		"color": Color("5a8fa8"),
	},
	{
		"id": "unknown_a3",
		"display_id": "A3",
		"name": "UNKNOWN",
		"scene_path": "",
		"spawn": Vector2.ZERO,
		"pos": Vector2(810, 380),
		"status": "locked",
		"tagline": "REQUIRES A2 SCAN",
		"color": Color("1e1a2a"),
	},
]

# Routes between planets by index. status: "travelable" | "locked"
const ROUTES := [
	{"from": 0, "to": 1, "status": "travelable"},
	{"from": 1, "to": 2, "status": "locked"},
]

const BODY_RADIUS := 30.0
const CURRENT_RING_RADIUS := 48.0

var is_open: bool = false
var _selected_index: int = -1
var _body_buttons: Array[Button] = []
var _sector_label: Label
var _selected_name_label: Label
var _selected_status_label: Label
var _travel_button: Button


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func _input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	if is_open:
		return
	is_open = true
	visible = true
	_selected_index = -1
	_refresh_bodies()
	_refresh_action_panel()
	# Fade in
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.18)


func close() -> void:
	if not is_open:
		return
	is_open = false
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.15)
	tween.tween_callback(func(): visible = false)
	closed.emit()


# ---------- UI construction ----------

func _build_ui() -> void:
	# Deep-space background
	var bg := ColorRect.new()
	bg.color = COL_BG_DEEP
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Starfield dots (static, decorative)
	_add_stars()

	# Header bar
	_build_header()

	# Bodies + routes are drawn in _draw(); overlay clickable buttons for bodies
	_build_body_buttons()

	# Legend box (bottom-left)
	_build_legend()

	# Action panel (bottom-right)
	_build_action_panel()


func _add_stars() -> void:
	var stars := Control.new()
	stars.set_anchors_preset(Control.PRESET_FULL_RECT)
	stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stars.set_script(preload("res://scenes/ui/galaxy_map_starfield.gd"))
	add_child(stars)


func _build_header() -> void:
	var header := ColorRect.new()
	header.color = COL_BG_PANEL
	header.position = Vector2(0, 0)
	header.size = Vector2(960, 40)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)

	# Bottom-border hairline
	var border := ColorRect.new()
	border.color = COL_RIM
	border.position = Vector2(0, 40)
	border.size = Vector2(960, 1)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(border)

	var title := Label.new()
	title.text = "GALAXY MAP"
	title.position = Vector2(16, 10)
	title.add_theme_color_override("font_color", COL_AMBER)
	title.add_theme_font_size_override("font_size", 14)
	add_child(title)

	_sector_label = Label.new()
	_sector_label.text = "SECTOR: UNNAMED · %d KNOWN BODIES" % _known_body_count()
	_sector_label.position = Vector2(160, 14)
	_sector_label.add_theme_color_override("font_color", COL_AMBER_DIM)
	_sector_label.add_theme_font_size_override("font_size", 10)
	add_child(_sector_label)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.flat = false
	close_btn.position = Vector2(930, 10)
	close_btn.size = Vector2(22, 22)
	close_btn.add_theme_color_override("font_color", COL_WARN)
	close_btn.add_theme_font_size_override("font_size", 11)
	close_btn.pressed.connect(close)
	add_child(close_btn)


func _build_body_buttons() -> void:
	_body_buttons.clear()
	for i in PLANETS.size():
		var planet: Dictionary = PLANETS[i]
		var btn := Button.new()
		btn.flat = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.size = Vector2(120, 110)
		var center: Vector2 = planet["pos"]
		btn.position = center - Vector2(60, 50)
		var idx := i
		btn.pressed.connect(func(): _on_body_pressed(idx))
		# Tooltip for quick identification
		btn.tooltip_text = "%s · %s" % [planet["display_id"], planet["name"]]
		add_child(btn)
		_body_buttons.append(btn)


func _build_legend() -> void:
	var panel := ColorRect.new()
	panel.color = COL_BG_PANEL
	panel.position = Vector2(16, 430)
	panel.size = Vector2(280, 92)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	_add_rect_border(panel.position, panel.size, COL_RIM)

	var title := Label.new()
	title.text = "LEGEND"
	title.position = Vector2(24, 434)
	title.add_theme_color_override("font_color", COL_AMBER_DIM)
	title.add_theme_font_size_override("font_size", 9)
	add_child(title)

	# Legend rows are drawn via small labels + color swatches
	_add_legend_row(Vector2(26, 456), "TRAVEL ROUTE", COL_AMBER)
	_add_legend_row(Vector2(26, 472), "LOCKED / UNSCANNED", COL_RIM)
	_add_legend_row_circle(Vector2(26, 490), "CURRENT LOCATION", COL_GOOD)


func _add_legend_row(pos: Vector2, text: String, line_color: Color) -> void:
	var line := ColorRect.new()
	line.color = line_color
	line.position = pos
	line.size = Vector2(30, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)
	var lbl := Label.new()
	lbl.text = text
	lbl.position = pos + Vector2(40, -7)
	lbl.add_theme_color_override("font_color", line_color)
	lbl.add_theme_font_size_override("font_size", 9)
	add_child(lbl)


func _add_legend_row_circle(pos: Vector2, text: String, col: Color) -> void:
	# Use a small Control with a _draw callback (via dedicated script) — or
	# cheap alternative: draw a small colored square.
	var dot := ColorRect.new()
	dot.color = col
	dot.position = pos - Vector2(3, 3)
	dot.size = Vector2(6, 6)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dot)
	var lbl := Label.new()
	lbl.text = text
	lbl.position = pos + Vector2(14, -10)
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_font_size_override("font_size", 9)
	add_child(lbl)


func _add_rect_border(pos: Vector2, size: Vector2, col: Color) -> void:
	# 1px frame made of four ColorRects (cheap alternative to StyleBoxFlat)
	var top := ColorRect.new()
	top.color = col
	top.position = pos
	top.size = Vector2(size.x, 1)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)
	var bottom := ColorRect.new()
	bottom.color = col
	bottom.position = pos + Vector2(0, size.y - 1)
	bottom.size = Vector2(size.x, 1)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom)
	var left := ColorRect.new()
	left.color = col
	left.position = pos
	left.size = Vector2(1, size.y)
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left)
	var right := ColorRect.new()
	right.color = col
	right.position = pos + Vector2(size.x - 1, 0)
	right.size = Vector2(1, size.y)
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(right)


func _build_action_panel() -> void:
	var pos := Vector2(600, 438)
	var panel_size := Vector2(344, 84)

	var panel := ColorRect.new()
	panel.color = COL_BG_PANEL
	panel.position = pos
	panel.size = panel_size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	_add_rect_border(pos, panel_size, COL_RIM)

	_selected_name_label = Label.new()
	_selected_name_label.position = pos + Vector2(10, 6)
	_selected_name_label.add_theme_color_override("font_color", COL_AMBER_DIM)
	_selected_name_label.add_theme_font_size_override("font_size", 10)
	add_child(_selected_name_label)

	_selected_status_label = Label.new()
	_selected_status_label.position = pos + Vector2(10, 22)
	_selected_status_label.add_theme_color_override("font_color", COL_AMBER_DIM)
	_selected_status_label.add_theme_font_size_override("font_size", 9)
	add_child(_selected_status_label)

	_travel_button = Button.new()
	_travel_button.text = "TRAVEL"
	_travel_button.position = pos + Vector2(10, 42)
	_travel_button.size = Vector2(160, 34)
	_travel_button.add_theme_color_override("font_color", COL_GOOD)
	_travel_button.add_theme_font_size_override("font_size", 12)
	_travel_button.pressed.connect(_on_travel_pressed)
	add_child(_travel_button)

	var close_btn := Button.new()
	close_btn.text = "CLOSE"
	close_btn.position = pos + Vector2(180, 42)
	close_btn.size = Vector2(154, 34)
	close_btn.add_theme_color_override("font_color", COL_AMBER)
	close_btn.add_theme_font_size_override("font_size", 12)
	close_btn.pressed.connect(close)
	add_child(close_btn)


# ---------- Drawing (routes + bodies) ----------

func _draw() -> void:
	# Routes first (so bodies draw on top)
	for route in ROUTES:
		var a: Vector2 = PLANETS[route["from"]]["pos"]
		var b: Vector2 = PLANETS[route["to"]]["pos"]
		if route["status"] == "travelable":
			_draw_dashed_line(a, b, COL_AMBER, 2.0, 6.0, 4.0)
		else:
			_draw_dashed_line(a, b, COL_RIM, 1.0, 4.0, 4.0)

	# Bodies
	for i in PLANETS.size():
		var p: Dictionary = PLANETS[i]
		var center: Vector2 = p["pos"]
		var is_current := p["id"] == GameState.current_planet
		var is_locked := p["status"] == "locked"
		var is_selected := i == _selected_index

		# Current-location dashed ring
		if is_current:
			_draw_dashed_arc(center, CURRENT_RING_RADIUS, COL_GOOD, 1.0, 32, 2.0, 3.0)

		# Selection ring
		if is_selected and not is_current:
			draw_arc(center, BODY_RADIUS + 6.0, 0.0, TAU, 48, COL_AMBER, 1.5)

		# Body fill
		var fill: Color = p["color"]
		draw_circle(center, BODY_RADIUS, fill)

		# Locked bodies: dashed outline + "???" glyph
		if is_locked:
			_draw_dashed_arc(center, BODY_RADIUS, COL_RIM, 1.0, 32, 3.0, 3.0)

		# Simple decorative specks (iron ore nuggets / crystal hints)
		match p["id"]:
			"asteroid_a1":
				draw_circle(center + Vector2(-8, -10), 5, Color("2a1a10"))
				draw_circle(center + Vector2(10, 8), 7, Color("4a3020"))
				draw_circle(center + Vector2(-16, 12), 3, Color("2a1a10"))
			"planet_b":
				# Crystal shards
				draw_colored_polygon(
					PackedVector2Array([
						center + Vector2(-8, -10),
						center + Vector2(6, -20),
						center + Vector2(12, -4),
						center + Vector2(-2, 2),
					]),
					Color("8fc0d8")
				)

	# Labels drawn as text (after circles, above)
	var font := ThemeDB.fallback_font
	for i in PLANETS.size():
		var p: Dictionary = PLANETS[i]
		var center: Vector2 = p["pos"]
		var is_current := p["id"] == GameState.current_planet
		var is_locked := p["status"] == "locked"
		var name_col: Color = COL_RIM if is_locked else COL_AMBER
		var tagline_col: Color = COL_RIM if is_locked else (COL_GOOD if is_current else COL_AMBER_DIM)

		var label_text := "%s · %s" % [p["display_id"], p["name"]]
		var label_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
		draw_string(font, center + Vector2(-label_size.x * 0.5, BODY_RADIUS + 18),
			label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, name_col)

		var sub_text: String = "YOU ARE HERE" if is_current else p["tagline"]
		var sub_size := font.get_string_size(sub_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 9)
		draw_string(font, center + Vector2(-sub_size.x * 0.5, BODY_RADIUS + 32),
			sub_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, tagline_col)

		# "???" inside locked body
		if is_locked:
			var glyph := "???"
			var glyph_size := font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
			draw_string(font, center + Vector2(-glyph_size.x * 0.5, 6),
				glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, COL_RIM)


func _draw_dashed_line(a: Vector2, b: Vector2, col: Color, width: float,
		dash_len: float, gap_len: float) -> void:
	var dir := (b - a).normalized()
	var total := a.distance_to(b)
	var travelled := 0.0
	while travelled < total:
		var start := a + dir * travelled
		var end_len := min(dash_len, total - travelled)
		var end_pt := a + dir * (travelled + end_len)
		draw_line(start, end_pt, col, width)
		travelled += dash_len + gap_len


func _draw_dashed_arc(center: Vector2, radius: float, col: Color, width: float,
		segments: int, dash_seg: float, gap_seg: float) -> void:
	# Approximate by drawing chords around a circle, skipping gaps
	var step := TAU / float(segments)
	var dash_count := int(round(dash_seg))
	var gap_count := int(round(gap_seg))
	var cycle := dash_count + gap_count
	for s in segments:
		if (s % cycle) < dash_count:
			var a0 := center + Vector2(radius, 0).rotated(step * float(s))
			var a1 := center + Vector2(radius, 0).rotated(step * float(s + 1))
			draw_line(a0, a1, col, width)


# ---------- Interaction ----------

func _on_body_pressed(index: int) -> void:
	_selected_index = index
	_refresh_action_panel()
	queue_redraw()


func _on_travel_pressed() -> void:
	if _selected_index < 0:
		return
	var p: Dictionary = PLANETS[_selected_index]
	if p["status"] == "locked":
		return
	if p["id"] == GameState.current_planet:
		return
	travel_requested.emit(String(p["id"]))
	close()


func _refresh_bodies() -> void:
	queue_redraw()


func _refresh_action_panel() -> void:
	if _selected_index < 0:
		_selected_name_label.text = "SELECT A BODY"
		_selected_status_label.text = "Click a known destination on the map."
		_selected_name_label.add_theme_color_override("font_color", COL_AMBER_DIM)
		_travel_button.disabled = true
		_travel_button.add_theme_color_override("font_color", COL_RIM)
		return

	var p: Dictionary = PLANETS[_selected_index]
	_selected_name_label.text = "SELECTED: %s · %s" % [p["display_id"], p["name"]]

	if p["id"] == GameState.current_planet:
		_selected_status_label.text = "YOU ARE HERE"
		_selected_name_label.add_theme_color_override("font_color", COL_GOOD)
		_travel_button.disabled = true
		_travel_button.add_theme_color_override("font_color", COL_RIM)
	elif p["status"] == "locked":
		_selected_status_label.text = "LOCKED — %s" % p["tagline"]
		_selected_name_label.add_theme_color_override("font_color", COL_RIM)
		_travel_button.disabled = true
		_travel_button.add_theme_color_override("font_color", COL_RIM)
	else:
		_selected_status_label.text = "FUEL: N/A (FIRST LAUNCH FREE) · %s" % p["tagline"]
		_selected_name_label.add_theme_color_override("font_color", COL_AMBER)
		_travel_button.disabled = false
		_travel_button.add_theme_color_override("font_color", COL_GOOD)


func _known_body_count() -> int:
	var n := 0
	for p in PLANETS:
		if p["status"] != "hidden":
			n += 1
	return n


# Expose rect for main.gd's click-through blocker
func get_global_rect() -> Rect2:
	return Rect2(global_position, size)
