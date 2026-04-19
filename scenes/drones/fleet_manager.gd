class_name FleetManager
extends Node
## Orchestrates all drones — auto-assigns idle drones to zones needing coverage

var drone_bay = null  # DroneBay
var zone_manager = null  # ZoneManager

signal fleet_dispatched(drone_count: int)


func setup(bay, zone_mgr) -> void:
	drone_bay = bay
	zone_manager = zone_mgr


func tick(delta: float) -> void:
	auto_dispatch()


func get_utilization() -> float:
	if not drone_bay or drone_bay.drone_count() == 0:
		return 0.0

	var busy_count = drone_bay.drone_count() - drone_bay.idle_count()
	return float(busy_count) / float(drone_bay.drone_count())


func auto_dispatch() -> int:
	if not drone_bay or not zone_manager:
		return 0

	var idle_drones = drone_bay.get_idle_drones()
	var dispatched = 0

	for drone in idle_drones:
		if not drone.has_method("execute_circuit"):
			continue

		var zones = zone_manager.zones
		for zone_id in zones:
			var zone = zones[zone_id]
			if zone.deposits.is_empty():
				continue

			zone_manager.assign_drone_to_zone(zone_id, drone)
			dispatched += 1
			break

	fleet_dispatched.emit(dispatched)
	return dispatched
