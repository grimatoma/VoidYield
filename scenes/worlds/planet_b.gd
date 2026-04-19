extends Node2D
## Planet B world scene. Teal-purple ambience, 14 Industrial Sites, cave entrances.

const WORLD_WIDTH = 3200
const WORLD_HEIGHT = 2400


func _ready() -> void:
	# Set world size
	var background = ColorRect.new()
	background.color = Color("#2A1F4F")  # Teal-purple from spec 13
	background.size = Vector2(WORLD_WIDTH, WORLD_HEIGHT)
	add_child(background)
	
	# Create Industrial Site markers (14 total)
	for i in range(14):
		var site = Node2D.new()
		site.name = "IndustrialSite_%d" % (i + 1)
		var rect = ColorRect.new()
		rect.color = Color.YELLOW.with_alpha(0.5)
		rect.size = Vector2(32, 32)
		rect.position = Vector2(
			randf_range(100, WORLD_WIDTH - 100),
			randf_range(100, WORLD_HEIGHT - 100)
		)
		site.add_child(rect)
		add_child(site)
