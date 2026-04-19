class_name TechTree
extends Node
## TechTree — Tech tree progression system managing RP accumulation and node unlocks.

var research_points: float = 0.0
var unlocked_nodes: Array[String] = []

signal rp_changed(new_rp: float)
signal node_unlocked(node_id: String)


func _ready() -> void:
	pass


# --- RP Management ---

func add_rp(amount: float) -> void:
	research_points += amount
	rp_changed.emit(research_points)


# --- Unlock Logic ---

func can_unlock(node_id: String) -> bool:
	# Check node exists
	if not TechTreeData.NODES.has(node_id):
		return false

	# Check not already unlocked
	if node_id in unlocked_nodes:
		return false

	var node_data = TechTreeData.NODES[node_id]
	var rp_cost = node_data.get("rp_cost", 0)
	var cr_cost = node_data.get("cr_cost", 0)
	var requires = node_data.get("requires", [])

	# Check RP and CR
	if research_points < rp_cost:
		return false
	if GameState.credits < cr_cost:
		return false

	# Check prerequisites
	for prereq_id in requires:
		if prereq_id not in unlocked_nodes:
			return false

	return true


func unlock(node_id: String) -> bool:
	if not can_unlock(node_id):
		return false

	var node_data = TechTreeData.NODES[node_id]
	var rp_cost = node_data.get("rp_cost", 0)
	var cr_cost = node_data.get("cr_cost", 0)

	# Deduct costs
	research_points -= rp_cost
	GameState.spend_credits(cr_cost)

	# Add to unlocked list
	unlocked_nodes.append(node_id)

	# Emit signal
	node_unlocked.emit(node_id)

	return true


func is_unlocked(node_id: String) -> bool:
	return node_id in unlocked_nodes


func get_node_data(node_id: String) -> Dictionary:
	if TechTreeData.NODES.has(node_id):
		return TechTreeData.NODES[node_id].duplicate()
	return {}


# --- Persistence ---

func get_save_data() -> Dictionary:
	return {
		"rp": research_points,
		"unlocked": unlocked_nodes.duplicate(),
	}


func load_save_data(data: Dictionary) -> void:
	research_points = data.get("rp", 0.0)
	var raw_unlocked = data.get("unlocked", [])
	unlocked_nodes.clear()
	for node_id in raw_unlocked:
		unlocked_nodes.append(str(node_id))
