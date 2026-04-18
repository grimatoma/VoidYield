extends Interactable
## LaunchPad — On-planet launch point. Opens the galaxy map so the player
## can pick a destination (including returning to A1).

signal return_requested  # legacy alias — still emitted for backward compatibility

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	is_held_interaction = false


func get_prompt_text() -> String:
	return "[E] Launch Pad — Open Galaxy Map"


func interact(_player: Node2D) -> void:
	# Preferred path: open the galaxy map directly through Main.
	var main := get_tree().get_first_node_in_group("main_scene")
	if main and main.has_method("open_galaxy_map"):
		main.open_galaxy_map()
	# Kept for any external listeners still wired to the old signal.
	return_requested.emit()


func is_interactable() -> bool:
	return true
