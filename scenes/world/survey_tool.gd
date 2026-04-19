class_name SurveyTool
extends Node2D
## Survey Tool with tier system supporting radius upgrades and deep scan (M12).

var is_scanning: bool = false
var _scanned_count: int = 0
var tier: int = 1

signal scan_completed(deposit_count: int)
signal tier_upgraded(new_tier: int)


func _ready() -> void:
	if SurveyToolSystem:
		tier = SurveyToolSystem.upgrade_level


func get_scan_radius() -> float:
	if SurveyToolSystem:
		return SurveyToolSystem.get_scan_radius()
	return 30.0


func can_deep_scan() -> bool:
	if SurveyToolSystem:
		return SurveyToolSystem.can_deep_scan()
	return false


func upgrade_tier(new_tier: int) -> bool:
	if SurveyToolSystem and SurveyToolSystem.upgrade(new_tier):
		tier = new_tier
		tier_upgraded.emit(new_tier)
		return true
	return false


func scan_deposits(deposits: Array, survey_stage: int) -> void:
	is_scanning = true
	_scanned_count = 0

	for deposit in deposits:
		if deposit and deposit.has_method("advance_survey"):
			deposit.advance_survey(survey_stage)
			_scanned_count += 1

	scan_completed.emit(_scanned_count)


func complete_scan() -> void:
	is_scanning = false
	_scanned_count = 0
