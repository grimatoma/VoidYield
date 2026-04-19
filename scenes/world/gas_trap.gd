class_name GasTrap
extends Node2D
## Gas Trap — captures dark gas from geysers via burst eruption events (M13).

var dark_gas_stored: int = 0
var geyser_position: Vector2 = Vector2.ZERO
var capture_radius: float = 40.0


func capture_eruption(amount: int) -> int:
	var captured = mini(amount, 200 - dark_gas_stored)  # Cap at 200 storage
	dark_gas_stored += captured
	return captured


func get_continuous_rate() -> float:
	return 0.0  # No continuous rate, only burst collection


func empty() -> int:
	var collected = dark_gas_stored
	dark_gas_stored = 0
	return collected


func is_full() -> bool:
	return dark_gas_stored >= 200
