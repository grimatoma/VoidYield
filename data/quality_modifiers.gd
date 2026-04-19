class_name QualityModifiers
extends RefCounted
## Given an OreQualityLot, compute production modifiers


static func get_speed_modifier(lot: OreQualityLot) -> float:
	# Higher PE (Potential Energy) = faster processing
	# Returns 0.5 to 2.0 range
	if lot == null:
		return 1.0
	return clampf(lot.pe / 500.0, 0.5, 2.0)


static func get_yield_modifier(lot: OreQualityLot) -> float:
	# Higher UT (Unit Toughness) = better yield (more output per input)
	# Returns 0.5 to 1.5 range
	if lot == null:
		return 1.0
	return clampf(lot.ut / 667.0, 0.5, 1.5)


static func get_quality_tier(lot: OreQualityLot) -> String:
	# Returns "premium", "standard", or "low" based on overall grade
	if lot == null:
		return "standard"
	var grade = lot.grade
	if grade in ["A", "B"]:
		return "premium"
	if grade in ["C"]:
		return "standard"
	return "low"
