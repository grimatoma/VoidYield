class_name OfflineEventLog
extends RefCounted
## Offline Event Log — simulates game progress during offline periods (M14).

const MAX_SIM_DURATION: float = 28800.0  # 8 hours max
const SIM_STEP: float = 30.0  # 30-second steps

var events: Array = []
var last_save_timestamp: float = 0.0
var total_credits_gained: int = 0
var total_ore_extracted: int = 0
var harvesters_stalled: int = 0


func _ready() -> void:
	last_save_timestamp = Time.get_ticks_msec() / 1000.0


func simulate_offline_progress(current_time: float) -> bool:
	var elapsed = current_time - last_save_timestamp

	if elapsed < 300.0:  # Less than 5 minutes offline
		return false

	var sim_duration = minf(elapsed, MAX_SIM_DURATION)
	var step_count = int(sim_duration / SIM_STEP)

	for step in range(step_count):
		_simulate_step()

	return step_count > 0


func _simulate_step() -> void:
	# Simulate harvesters, factories, and production during this 30-second step
	_simulate_harvester_output()
	_simulate_factory_output()
	_simulate_drone_tasks()


func _simulate_harvester_output() -> void:
	# Estimate harvester outputs based on active harvesters and BER
	# For now, simplified: assume 5 units per step per active harvester
	var estimated_output = 5  # Base estimate
	total_ore_extracted += estimated_output
	events.append({
		"type": "harvester_output",
		"amount": estimated_output,
		"timestamp": Time.get_ticks_msec() / 1000.0
	})


func _simulate_factory_output() -> void:
	# Simulate factory conversions
	var factory_output = 2  # Simplified estimate
	total_ore_extracted += factory_output
	events.append({
		"type": "factory_output",
		"amount": factory_output,
		"timestamp": Time.get_ticks_msec() / 1000.0
	})


func _simulate_drone_tasks() -> void:
	# Simulate drone carry/deposit tasks
	var cargo_delivered = 3  # Simplified
	total_credits_gained += cargo_delivered * 2  # Rough credit value


func get_events() -> Array:
	return events


func get_empire_dispatch_summary() -> Dictionary:
	return {
		"total_credits_gained": total_credits_gained,
		"total_ore_extracted": total_ore_extracted,
		"harvesters_stalled": harvesters_stalled,
		"event_count": events.size(),
		"simulation_successful": events.size() > 0,
	}


func clear_events() -> void:
	events.clear()
	total_credits_gained = 0
	total_ore_extracted = 0
	harvesters_stalled = 0
	last_save_timestamp = Time.get_ticks_msec() / 1000.0
