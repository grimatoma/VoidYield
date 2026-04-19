extends "res://tests/framework/test_case.gd"
## Unit tests for Planet A2 (transit asteroid).

const A2DepotScript = preload("res://autoloads/a2_depot.gd")
const A2CacheScript = preload("res://autoloads/a2_secret_cache.gd")


func test_a2_depot_stores_fuel() -> void:
	var depot = A2DepotScript.new()
	assert_eq(depot.rocket_fuel_current, 200.0, "Should store 200 RF")


func test_a2_depot_regenerates_fuel() -> void:
	var depot = A2DepotScript.new()
	depot.rocket_fuel_current = 100.0
	depot.tick(3600.0)  # 1 hour
	assert_eq(depot.rocket_fuel_current, 105.0, "Should regen 5 RF/hr")


func test_a2_cache_provides_reward() -> void:
	var cache = A2CacheScript.new()
	var reward = cache.open()
	assert_has(reward, "credits", "Should include credits")
	assert_has(reward, "krysite_sample", "Should include krysite sample")
	assert_eq(reward["credits"], 500, "Should reward 500 CR")


func test_a2_cache_only_opens_once() -> void:
	var cache = A2CacheScript.new()
	cache.open()
	var second = cache.open()
	assert_null(second, "Cache should only open once")
