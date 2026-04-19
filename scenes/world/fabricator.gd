class_name Fabricator
extends Node2D

const FACTORY_TIER = 2
const SLOT_COST = 2

var current_recipe_id: String = ""
var is_running: bool = false
var _progress: float = 0.0
var _input_buffers: Dictionary = {}
var _output_buffer: Dictionary = {}

signal cycle_completed(recipe_id: String)


func set_recipe(id: String) -> void:
	if not id in Recipes.ALL:
		current_recipe_id = ""
		return
	
	var recipe = Recipes.ALL[id]
	if recipe.get("factory_tier") != FACTORY_TIER:
		current_recipe_id = ""
		return
	
	current_recipe_id = id
	_progress = 0.0
	_input_buffers.clear()
	_output_buffer.clear()


func load_input(type: String, amount: int) -> int:
	var current = _input_buffers.get(type, 0)
	var space_available = 20 - current
	var to_load = min(amount, space_available)
	_input_buffers[type] = current + to_load
	return to_load


func can_run() -> bool:
	if current_recipe_id.is_empty():
		return false

	if not Recipes.ALL.has(current_recipe_id):
		return false

	var recipe = Recipes.ALL[current_recipe_id]
	for input_type in recipe.inputs:
		if _input_buffers.get(input_type, 0) < recipe.inputs[input_type]:
			return false

	return true


func tick(delta: float) -> void:
	if not is_running or not can_run():
		return

	var recipe = Recipes.ALL[current_recipe_id]
	var duration = recipe.time

	_progress += delta
	if _progress >= duration:
		_complete_cycle()


func _complete_cycle() -> void:
	var recipe = Recipes.ALL[current_recipe_id]

	# Consume inputs
	for input_type in recipe.inputs:
		_input_buffers[input_type] -= recipe.inputs[input_type]

	# Add to output (capped at 10 per type)
	for output_type in recipe.outputs:
		var current = _output_buffer.get(output_type, 0)
		var to_add = recipe.outputs[output_type]
		_output_buffer[output_type] = min(current + to_add, 10)

	_progress = 0.0
	cycle_completed.emit(current_recipe_id)


func collect_output(type: String, amount: int) -> int:
	var current = _output_buffer.get(type, 0)
	var to_collect = min(amount, current)
	_output_buffer[type] = current - to_collect
	return to_collect


func start() -> void:
	is_running = true


func stop() -> void:
	is_running = false
