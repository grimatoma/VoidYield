class_name ResourceQualityInspector
extends Node
## Exposes ore quality lot data in a structured way for the UI to consume

var current_lot: OreQualityLot = null

signal lot_updated(lot: OreQualityLot)


func inspect(lot: OreQualityLot) -> void:
	current_lot = lot
	lot_updated.emit(lot)


func get_grade() -> String:
	if current_lot == null:
		return "—"
	return current_lot.grade


func get_attribute(attr: String) -> float:
	if current_lot == null:
		return 0.0
	return current_lot.get(attr, 0.0)


func get_summary() -> Dictionary:
	if current_lot == null:
		return {}

	return {
		"grade": current_lot.grade,
		"er": current_lot.er,
		"cr": current_lot.cr,
		"cd": current_lot.cd,
		"dr": current_lot.dr,
		"fl": current_lot.fl,
		"hr": current_lot.hr,
		"ma": current_lot.ma,
		"pe": current_lot.pe,
		"sr": current_lot.sr,
		"ut": current_lot.ut,
	}


func clear() -> void:
	current_lot = null
