extends Interactable
## LaunchPad — Planet B return point. Sends the player back to Asteroid A1.

signal return_requested

@onready var sprite: ColorRect = $Sprite

const COLOR_PAD = Color(0.3, 0.55, 0.85)  # Same blue as the spaceship when ready


func _ready() -> void:
	is_held_interaction = false
	sprite.color = COLOR_PAD


func get_prompt_text() -> String:
	return "[E] Launch Pad — Return to A1"


func interact(_player: Node2D) -> void:
	return_requested.emit()


func is_interactable() -> bool:
	return true
