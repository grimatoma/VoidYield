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

	# Fissures — irregular multi-segment cracks acr