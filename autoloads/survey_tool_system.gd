class_name SurveyToolSystem
extends RefCounted
## Survey Tool upgrade system. Tier I (30px), Tier II (60px + Deep Scan), Tier III (120px).

const TIER_SPECS = {
	1: {"radius": 30.0, "can_deep_scan": false},
	2: {"radius": 60.0, "can_deep_scan": true},
	3: {"radius": 120.0, "can_deep_scan": true},
}

var upgrade_level: int = 1


func get_scan_radius() -> float:
	if upgrade_level in TIER_SPECS:
		return TIER_SPECS[upgrade_level]["radius"]
	return 30.0


func can_deep_scan() -> bool:
	if upgrade_level in TIER_SPECS:
		return TIER_SPECS[upgrade_level]["can_deep_scan"]
	return false


func upgrade(new_level: int) -> bool:
	if new_level <= upgrade_level or new_level > 3:
		return false
	
	upgrade_level = new_level
	return true
