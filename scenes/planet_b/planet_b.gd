extends Node
## PlanetBStub — Placeholder scene for Planet B (Krysos System).
## Loaded via GameState.launch_to_planet_b() / change_scene_to_file.

func _ready() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.02, 0.14)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "PLANET B — KRYSOS SYSTEM\n[Under Construction]"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.3, 0.85, 0.8))
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "You escaped the void. A new world awaits..."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", Color(0.55, 0.45, 0.75))
	sub.add_theme_font_size_override("font_size", 13)
	vbox.add_child(sub)
