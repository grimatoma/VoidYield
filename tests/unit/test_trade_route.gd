extends "res://tests/framework/test_case.gd"
## Unit tests for TradeRoute resource.

const TradeRouteScript = preload("res://data/trade_route.gd")


func test_trade_route_initializes() -> void:
	var route = TradeRouteScript.new()
	route.route_id = "route_a1_to_b"
	assert_eq(route.route_id, "route_a1_to_b", "Should store route_id")


func test_trade_route_tracks_planets() -> void:
	var route = TradeRouteScript.new()
	route.source_planet = "a1"
	route.destination_planet = "planet_b"
	assert_eq(route.source_planet, "a1", "Should store source planet")
	assert_eq(route.destination_planet, "planet_b", "Should store destination planet")


func test_trade_route_tracks_cargo_class() -> void:
	var route = TradeRouteScript.new()
	route.cargo_class = "bulk"
	assert_eq(route.cargo_class, "bulk", "Should store cargo class")


func test_trade_route_has_dispatch_mode() -> void:
	var route = TradeRouteScript.new()
	route.dispatch_mode = "MANUAL"
	assert_eq(route.dispatch_mode, "MANUAL", "Should store dispatch mode")


func test_trade_route_has_status() -> void:
	var route = TradeRouteScript.new()
	route.status = "ACTIVE"
	assert_eq(route.status, "ACTIVE", "Should store status")


func test_trade_route_tracks_cargo_amount() -> void:
	var route = TradeRouteScript.new()
	route.cargo_amount = 500
	assert_eq(route.cargo_amount, 500, "Should track cargo amount")
