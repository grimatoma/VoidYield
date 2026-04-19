extends "res://tests/framework/test_case.gd"
## TDD unit tests for MainScene orchestration.
## Covers: component setup, ticking, harvester registration.

const MainSceneScript = preload("res://scenes/main/main_scene.gd")
const HarvesterBaseScript = preload("res://scenes/world/harvester_base.gd")

var main_scene


func before_each() -> void:
	main_scene = MainSceneScript.new()
	add_child(main_scene)


func after_each() -> void:
	if main_scene and main_scene.is_inside_tree():
		main_scene.queue_free()


func test_setup_initializes_all_systems() -> void:
	main_scene.setup()

	assert_not_null(main_scene.storage, "Should initialize storage depot")
	assert_not_null(main_scene.game_loop, "Should initialize game loop")
	assert_not_null(main_scene.drone_bay, "Should initialize drone bay")
	assert_not_null(main_scene.drone_queue, "Should initialize drone task queue")


func test_process_ticks_game_loop() -> void:
	main_scene.setup()

	var initial_ticks = main_scene._game_loop_ticks
	main_scene._process(0.016)

	assert_gt(main_scene._game_loop_ticks, initial_ticks, "Should tick game loop")


func test_register_harvester_links_to_systems() -> void:
	main_scene.setup()

	var harvester = HarvesterBaseScript.new()
	main_scene.register_harvester(harvester)

	assert_eq(harvester.linked_depot, main_scene.storage, "Should link harvester to storage")
	assert_gt(main_scene._harvesters.size(), 0, "Should register harvester")
