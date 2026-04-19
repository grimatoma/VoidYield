extends Node
## ColonyManager — Manages Pioneer population, needs, and growth.

const GROWTH_INTERVAL: float = 90.0
const NEEDS = ["water", "food", "power"]
const HABITATION_CAPACITY = {"basic": 8, "standard": 16, "advanced": 30}

signal pioneer_count_changed(new_count: int)
signal needs_changed(need: String, met: bool)
signal morale_changed(new_morale: float)
signal pioneer_left(count_lost: int)

var pioneer_count: int = 4
var housing_capacity: int = 8
var needs_met: Dictionary = {"water": false, "food": false, "power": false, "luxury_goods": false}
var morale: float = 0.0

var _growth_timer: float = 0.0


func _ready() -> void:
	pass


func tick(delta: float) -> void:
	_growth_timer += delta
	if _growth_timer >= GROWTH_INTERVAL:
		if _all_basic_needs_met() and pioneer_count < housing_capacity:
			pioneer_count += 1
			pioneer_count_changed.emit(pioneer_count)
		_growth_timer = 0.0


func set_need(need: String, met: bool) -> void:
	needs_met[need] = met
	needs_changed.emit(need, met)
	_recalculate_morale()


func _recalculate_morale() -> void:
	var unmet_count = 0
	for need in NEEDS:
		if not needs_met[need]:
			unmet_count += 1

	match unmet_count:
		0:
			morale = 1.0
		1:
			morale = 0.6
		2:
			morale = 0.3
		3:
			morale = 0.0

	if needs_met["luxury_goods"]:
		morale = minf(morale + 0.1, 1.0)

	morale_changed.emit(morale)


func _all_basic_needs_met() -> bool:
	return needs_met["water"] and needs_met["food"] and needs_met["power"]


func add_housing(module_type: String) -> void:
	var capacity_to_add = HABITATION_CAPACITY.get(module_type, 0)
	housing_capacity += capacity_to_add


func get_save_data() -> Dictionary:
	return {
		"pioneer_count": pioneer_count,
		"housing_capacity": housing_capacity,
		"needs_met": needs_met.duplicate(),
		"morale": morale,
	}


func load_save_data(data: Dictionary) -> void:
	pioneer_count = data.get("pioneer_count", 4)
	housing_capacity = data.get("housing_capacity", 8)
	needs_met = data.get("needs_met", {"water": false, "food": false, "power": false, "luxury_goods": false}).duplicate()
	morale = data.get("morale", 0.0)
