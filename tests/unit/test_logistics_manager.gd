extends "res://tests/framework/test_case.gd"
## Unit tests for LogisticsManager autoload.

const LogisticsManagerScript = preload("res://autoloads/logistics_manager.gd")
const TradeRouteScript = preload("res://data/trade_route.gd")


func test_logistics_manager_initializes_empty() -> void:
	var manager = LogisticsManagerScript.new()
	assert_eq(manager.routes.size(), 0, "Should start with no routes")


func test_logistics_manager_can_create_route() -> void:
	var manager = LogisticsManagerScript.new()
	var route = manager.create_route("a1", "planet_b", "bulk")
	assert_not_null(route, "Should create route")
	assert_eq(route.source_planet, "a1", "Route should have correct source")
	assert_eq(route.destination_planet, "planet_b", "Route should have correct destination")


func test_logistics_manager_tracks_routes() -> void:
	var manager = LogisticsManagerScript.new()
	var route = manager.create_route("a1", "planet_b", "bulk")
	assert_eq(manager.routes.size(), 1, "Should track created route")


func test_logistics_manager_can_dispatch_route() -> void:
	var manager = LogisticsManagerScript.new()
	var route = manager.create_route("a1", "planet_b", "bulk")
	route.cargo_amount = 500
	
	var success = manager.dispatch_route(route.route_id)
	assert_true(success, "Should dispatch route")
	assert_eq(route.status, "ACTIVE", "Route should be ACTIVE after dispatch")


func test_logistics_manager_cannot_dispatch_empty_route() -> void:
	var manager = LogisticsManagerScript.new()
	var route = manager.create_route("a1", "planet_b", "bulk")
	route.cargo_amount = 0
	
	var success = manager.dispatch_route(route.route_id)
	assert_false(success, "Should not dispatch empty route")
