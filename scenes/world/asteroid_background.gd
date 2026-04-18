extends Node2D
## AsteroidBackground — Procedurally draws a rocky alien asteroid surface.
## Uses _draw() so no external texture import needed.
## Features: varied rock panels, glowing fissure cracks, crystal deposits, and craters.

const FIELD_W := 2800
const FIELD_H := 2000
const TILE := 32

# Base palette — dark purple-grey alien rock
const C_BASE   := Color(0.10, 0.09, 0.14, 1.0)   # deep dark rock
const C_ROCK   := Color(0.15, 0.14, 0.20, 1.0)   # medium rock panel
const C_ROCK2  := Color(0.07, 0.07, 0.11, 1.0)   # shadow rock
const C_LIGHT  := Color(0.20, 0.18, 0.28, 1.0)   # highlight rock slab
const C_LINE   := Color(0.06, 0.06, 0.09, 1.0)   # grid mortar line
const C_CRAT   := Color(0.04, 0.04, 0.07, 1.0)   # crater interior
const C_CRAT_RIM := Color(0.25, 0.22, 0.35, 0.9) # crater rim highlight

# Glowing fissures — subtle teal/cyan mineral veins
const C_FISS   := Color(0.15, 0.40, 0.45, 0.55)  # fissure glow
const C_FISS2  := Color(0.25, 0.55, 0.60, 0.35)  # fissure core

# Crystal deposits — rare bright mineral flecks
const C_CRYST  := Color(0.50, 0.80, 0.90, 0.7)   # crystal glint
const C_CRYST2 := Color(0.70, 0.45, 0.90, 0.6)   # purple crystal

var _rects: Array = []
var _craters: Array = []
var _fissures: Array = []
var _crystals: Array = []


func _ready() -> void:
	z_index = -10
	_generate()


func _generate() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42731

	# Rock panels — varied 32x32 tiles with richer distribution
	var cols := FIELD_W / TILE
	var rows := FIELD_H / TILE
	for r in rows:
		for c in cols:
			var v = rng.randf_range(0.0, 1.0)
			var col: Color
			if v < 0.45:
				col = C_BASE
			elif v < 0.72:
				col = C_ROCK
			elif v < 0.87:
				col = C_LIGHT
			else:
				col = C_ROCK2
			_rects.append({
				"rect": Rect2(c * TILE, r * TILE, TILE, TILE),
				"color": col
			})

	# Craters
	for _i in 55:
		var cx = rng.randi_range(60, FIELD_W - 60)
		var cy = rng.randi_range(60, FIELD_H - 60)
		var rad = rng.randi_range(10, 35)
		_craters.append({"x": cx, "y": cy, "r": rad})

	# Fissures — irregular multi-segment cracks across the rock
	for _i in 28:
		var sx = rng.randi_range(0, FIELD_W)
		var sy = rng.randi_range(0, FIELD_H)
		var segments: Array = []
		var px = sx
		var py = sy
		var seg_count = rng.randi_range(3, 7)
		for _j in seg_count:
			var nx = px + rng.randi_range(-80, 80)
			var ny = py + rng.randi_range(-60, 60)
			segments.append({"x1": px, "y1": py, "x2": nx, "y2": ny})
			px = nx
			py = ny
		_fissures.append(segments)

	# Crystal deposits — small bright mineral clusters
	for _i in 90:
		var kind = rng.randi_range(0, 1)  # 0=teal, 1=purple
		var cx = rng.randi_range(10, FIELD_W - 10)
		var cy = rng.randi_range(10, FIELD_H - 10)
		var size = rng.randf_range(1.0, 2.8)
		_crystals.append({"x": cx, "y": cy, "s": size, "kind": kind})


func _draw() -> void:
	# Fill base to cover any gaps
	draw_rect(Rect2(-200, -200, FIELD_W + 400, FIELD_H + 400), C_BASE)

	# Rock panels
	for r in _rects:
		draw_rect(r["rect"], r["color"])

	# Subtle mortar grid lines (every tile)
	for x in range(0, FIELD_W, TILE):
		draw_line(Vector2(x, 0), Vector2(x, FIELD_H), C_LINE, 0.8)
	for y in range(0, FIELD_H, TILE):
		draw_line(Vector2(0, y), Vector2(FIELD_W, y), C_LINE, 0.8)

	# Craters — dark pit with bright rim
	for c in _craters:
		var pos := Vector2(c.x, c.y)
		# Outer rim glow
		draw_arc(pos, c.r + 2, 0.0, TAU, int(c.r * 4), C_CRAT_RIM, 2.0)
		# Interior
		draw_circle(pos, c.r - 1, C_CRAT)
		# Inner highlight arc (top-left, simulates depth)
		draw_arc(pos, c.r - 3, PI * 1.1, PI * 1.8, 8, Color(0.30, 0.26, 0.42, 0.5), 1.5)

	# Fissures — glowing mineral cracks
	for fiss in _fissures:
		for seg in fiss:
			var p1 := Vector2(seg.x1, seg.y1)
			var p2 := Vector2(seg.x2, seg.y2)
			# Outer glow (wider, more transparent)
			draw_line(p1, p2, C_FISS, 3.0)
			# Core line (brighter, thinner)
			draw_line(p1, p2, C_FISS2, 1.2)

	# Crystal deposits
	for cryst in _crystals:
		var pos := Vector2(cryst.x, cryst.y)
		var col := C_CRYST if cryst.kind == 0 else C_CRYST2
		var s: float = cryst.s
		# Small diamond / cross shape
		draw_line(pos + Vector2(-s, 0), pos + Vector2(s, 0), col, 1.2)
		draw_line(pos + Vector2(0, -s), pos + Vector2(0, s), col, 1.2)
		# Center dot
		draw_circle(pos, s * 0.5, col)
