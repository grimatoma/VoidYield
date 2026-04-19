class_name ZoneManager
extends Node
## Manages mining zones: groups of deposits assigned to drone circuits

var zones: Dictionary = {}

signal zone_created(zone_id: String)
signal zone_drone_assigned(zone_id: String, drone: Node)


func create_zone(zone_id: String, depot: Node) -> void:
	zones[zone_id] = {
		"deposits": [],
		"depot": depot,
		"drones": [],
	}
	zone_created.emit(zone_id)


func add_deposit_to_zone(zone_id: String, deposit: Node) -> void:
	if not zones.has(zone_id):
		return
	zones[zone_id].deposits.append(deposit)


func assign_drone_to_zone(zone_id: String, drone: Node) -> void:
	if not zones.has(zone_id):
		return

	var zone = zones[zone_id]
	if zone.deposits.is_empty():
		return

	var first_deposit = zone.deposits[0]
	drone.assign_circuit(first_deposit, zone.depot)
	zone.drones.append(drone)
	zone_drone_assigned.emit(zone_id, drone)


func get_zone(zone_id: String) -> Dictionary:
	if zones.has(zone_id):
		return zones[zone_id]
	return {}


func zone_count() -> int:
	return zones.size()


func drones_in_zone(zone_id: String) -> Array:
	if zones.has(zone_id):
		return zones[zone_id].drones
	return []
