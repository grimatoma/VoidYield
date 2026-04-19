extends Node2D
class_name DepositNode
## A surveyable, harvestable deposit of ore.
## Distinct from OreNode (hand-minable surface rocks).
## Contains quality attributes, concentration, survey progression state.

const OreQualityLot = preload("res://data/ore_quality_lot.gd")

@export var ore_type: String = "common"
@export var deposit_size: String = "medium"

var concentration: float = 50.0
var quality = null
var survey_stage: int = 0
var is_revealed: bool = false

var harvester_slots: int:
	get:
		return _get_harvester_slots_for_size(deposit_size)

signal survey_advanced(stage: int)


func advance_survey(stage: int) -> void:
	survey_stage = stage

	if stage >= 2 and quality == null:
		var tier = _concentration_to_tier(concentration)
		quality = OreQualityLot.generate(tier)

	survey_advanced.emit(stage)


func get_slot_limit() -> int:
	return harvester_slots


func _get_harvester_slots_for_size(size: String) -> int:
	match size:
		"small":
			return 1
		"medium":
			return 2
		"large":
			return 3
		"motherlode":
			return 3
		_:
			return 2  # default to medium


func _concentration_to_tier(conc: float) -> String:
	if conc >= 90:
		return "motherlode"
	elif conc >= 60:
		return "rich"
	elif conc >= 30:
		return "average"
	else:
		return "poor"
