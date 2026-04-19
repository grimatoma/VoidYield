class_name SurveyTool
extends Node2D

var is_scanning: bool = false
var _scanned_count: int = 0

signal scan_completed(deposit_count: int)


func scan_deposits(deposits: Array, survey_stage: int) -> void:
	is_scanning = true
	_scanned_count = 0

	for deposit in deposits:
		if deposit and deposit.has_method("advance_survey"):
			deposit.advance_survey(survey_stage)
			_scanned_count += 1
			AudioManager.play_survey_ping()

	scan_completed.emit(_scanned_count)


func complete_scan() -> void:
	is_scanning = false
	_scanned_count = 0
