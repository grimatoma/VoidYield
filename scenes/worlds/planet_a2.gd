extends Node2D
## Planet A2 (Transit Asteroid). Small 600x400px scene with ore deposits and secret cache.

const WORLD_WIDTH = 600
const WORLD_HEIGHT = 400


func _ready() -> void:
	# Background
	var background = ColorRect.new()
	background.color = Color("#4a4a5e")  # Grey-purple asteroid color
	background.size = Vector2(WORLD_WIDTH, WORLD_HEIGHT)
	add_child(background)
	
	# Krysite vein marker
	var krysite = Node2D.new()
	krysite.name = "Krysite_Vein"
	var krysite_rect = ColorRect.new()
	krysite_rect.color = Color.LIGHT_BLUE.with_alpha(0.7)
	krysite_rect.size = Vector2(48, 48)
	krysite_rect.position = Vector2(150, 150)
	krysite.add_child(krysite_rect)
	add_child(krysite)
	
	# Vorax cluster marker
	var vorax = Node2D.new()
	vorax.name = "Vorax_Cluster"
	var vorax_rect = ColorRect.new()
	vorax_rect.color = Color.ORANGE.with_alpha(0.7)
	vorax_rect.size = Vector2(40, 40)
	vorax_rect.position = Vector2(420, 280)
	vorax.add_child(vorax_rect)
	add_child(vorax)
	
	# Secret cache location (hidden marker)
	var cache = Node2D.new()
	cache.name = "SecretCache"
	cache.position = Vector2(300, 200)
	add_child(cache)
