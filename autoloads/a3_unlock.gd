class_name A3Unlock
extends RefCounted
## Tracks A3 unlock conditions: a2_visited AND void_cores >= 10.

var a2_visited: bool = false
var void_cores_produced: int = 0


func is_unlocked() -> bool:
	return a2_visited and void_cores_produced >= 10


func get_progress() -> Dictionary:
	return {
		"a2_visited": a2_visited,
		"void_cores": "%d/10" % void_cores_produced,
	}


func add_void_core_progress(count: int) -> void:
	void_cores_produced += count


func visit_a2() -> void:
	a2_visited = true
