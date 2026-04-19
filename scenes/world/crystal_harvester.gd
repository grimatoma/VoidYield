class_name CrystalHarvester
extends Node2D
## Crystal Harvester — cracks Resonance Crystals with consumable charges (M13).

var formation_position: Vector2 = Vector2.ZERO
var charges_available: int = 0
var remaining_crack_cycles: int = 0
var resonance_shards_collected: int = 0


func use_charge() -> bool:
	if charges_available > 0:
		charges_available -= 1
		return true
	return false


func crack_formation() -> int:
	if remaining_crack_cycles <= 0:
		return 0

	if not use_charge():
		return 0

	var shards = randi_range(1, 5)
	remaining_crack_cycles -= 1
	resonance_shards_collected += shards

	return shards


func get_remaining_cycles() -> int:
	return remaining_crack_cycles


func is_depleted() -> bool:
	return remaining_crack_cycles <= 0


func get_shards_collected() -> int:
	return resonance_shards_collected
