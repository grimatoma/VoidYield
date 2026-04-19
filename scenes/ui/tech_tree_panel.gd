class_name TechTreePanel
extends Control
## Full tech tree UI panel with 50+ nodes across 3 branches (M12).

signal node_unlock_requested(node_id: String)

var _branch_nodes: Dictionary = {}
var _node_states: Dictionary = {}
var _selected_node: String = ""


func _ready() -> void:
	_initialize_branch_structure()


func _initialize_branch_structure() -> void:
	_branch_nodes = {
		1: [],  # Extraction branch
		2: [],  # Processing & Crafting branch
		3: [],  # Expansion branch
	}
	_populate_branch_nodes()


func _populate_branch_nodes() -> void:
	# Extraction branch (Branch 1)
	_branch_nodes[1] = [
		"1.1", "1.2", "1.3", "1.4", "1.A", "1.B", "1.C", "1.D", "1.E", "1.F",
		"1.G", "1.H", "1.P", "1.Q", "1.R", "1.S", "1.T", "1.U", "1.X", "1.Y"
	]

	# Processing & Crafting branch (Branch 2)
	_branch_nodes[2] = [
		"2.1", "2.A", "2.B", "2.C", "2.P", "2.Q", "2.R", "2.S", "2.V", "2.W",
		"2.X", "2.Y", "2.Z"
	]

	# Expansion branch (Branch 3)
	_branch_nodes[3] = [
		"3.1", "3.2", "3.3", "3.4", "3.5", "3.A", "3.B", "3.C", "3.P", "3.Q",
		"3.R", "3.S", "3.T", "3.X", "3.Y", "3.Z"
	]


func get_branch_nodes(branch: int) -> Array:
	if branch in _branch_nodes:
		return _branch_nodes[branch]
	return []


func get_nodes_for_branch(branch: int) -> Array:
	return get_branch_nodes(branch)


func get_node_display_state(node_id: String) -> String:
	if TechTree.is_unlocked(node_id):
		return "unlocked"
	elif TechTree.can_unlock(node_id):
		return "available"
	else:
		return "locked"


func get_node_prerequisites(node_id: String) -> Array:
	var node_data = TechTree.get_node_data(node_id)
	if node_data and "prerequisites" in node_data:
		return node_data["prerequisites"]
	return []


func get_node_costs(node_id: String) -> Dictionary:
	var node_data = TechTree.get_node_data(node_id)
	if node_data:
		return {
			"rp": node_data.get("rp_cost", 0),
			"cr": node_data.get("cr_cost", 0),
		}
	return {"rp": 0, "cr": 0}


func get_node_tooltip(node_id: String) -> String:
	var node_data = TechTree.get_node_data(node_id)
	if not node_data:
		return "Unknown node"

	var tooltip = "%s\n" % node_data.get("name", "Unknown")
	tooltip += "Effect: %s\n" % node_data.get("effect_description", "")

	var costs = get_node_costs(node_id)
	if costs["rp"] > 0:
		tooltip += "Cost: %d RP" % costs["rp"]
	if costs["cr"] > 0:
		tooltip += " + %d CR" % costs["cr"]

	var prereqs = get_node_prerequisites(node_id)
	if prereqs.size() > 0:
		tooltip += "\nRequires: " + ", ".join(prereqs)

	return tooltip


func unlock_node(node_id: String) -> bool:
	if TechTree.can_unlock(node_id):
		node_unlock_requested.emit(node_id)
		return TechTree.unlock(node_id)
	return false


func select_node(node_id: String) -> void:
	_selected_node = node_id
	_node_states[node_id] = true
