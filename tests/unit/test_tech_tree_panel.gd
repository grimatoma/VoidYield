extends "res://tests/framework/test_case.gd"
## TDD unit tests for TechTreePanel UI (M12).

const TechTreePanelScript = preload("res://scenes/ui/tech_tree_panel.gd")


func test_tech_tree_panel_initializes() -> void:
	var panel = TechTreePanelScript.new()
	assert_not_null(panel, "Tech Tree Panel should initialize without error")


func test_tech_tree_panel_has_branches() -> void:
	var panel = TechTreePanelScript.new()
	assert_true(panel.has_method("get_branch_nodes"), "Should have method to get branch nodes")


func test_tech_tree_panel_filters_by_branch() -> void:
	var panel = TechTreePanelScript.new()
	# Branches should be: 1 (Extraction), 2 (Processing), 3 (Expansion)
	assert_true(panel.has_method("get_nodes_for_branch"), "Should filter nodes by branch")


func test_tech_tree_panel_shows_node_state() -> void:
	var panel = TechTreePanelScript.new()
	# Node states: unlocked (filled), available (bright), locked (dim)
	assert_true(panel.has_method("get_node_display_state"), "Should return node display state")


func test_tech_tree_panel_displays_prerequisites() -> void:
	var panel = TechTreePanelScript.new()
	assert_true(panel.has_method("get_node_prerequisites"), "Should display node prerequisites")


func test_tech_tree_panel_shows_costs() -> void:
	var panel = TechTreePanelScript.new()
	assert_true(panel.has_method("get_node_costs"), "Should show RP and CR costs for nodes")


func test_tech_tree_panel_handles_unlock() -> void:
	var panel = TechTreePanelScript.new()
	assert_true(panel.has_method("unlock_node"), "Should handle node unlock requests")


func test_tech_tree_panel_shows_node_tooltips() -> void:
	var panel = TechTreePanelScript.new()
	assert_true(panel.has_method("get_node_tooltip"), "Should provide node tooltips with effect descriptions")
