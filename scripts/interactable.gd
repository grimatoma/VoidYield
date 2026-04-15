class_name Interactable
extends Area2D
## Base class for all interactable objects in the world.
## Subclasses override interact() and get_prompt_text().

## Whether this interactable requires holding (like mining) vs instant (like selling)
@export var is_held_interaction: bool = false
## Duration of held interaction in seconds (only used if is_held_interaction = true)
@export var hold_duration: float = 1.5


func get_prompt_text() -> String:
	return "[E] Interact"


func interact(_player: Node2D) -> void:
	pass


func get_interaction_progress() -> float:
	return 0.0


func cancel_interaction() -> void:
	pass


func is_interactable() -> bool:
	return true


