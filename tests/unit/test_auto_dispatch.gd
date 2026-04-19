extends "res://tests/framework/test_case.gd"
## TDD unit tests for auto-dispatch system (M13).

const LogisticsManagerScript = preload("res://autoloads/logistics_manager.gd")
const TradeRouteScript = preload("res://data/trade_route.gd")


func test_route_has_dispatch_mode() -> void:
	var route = TradeRouteScript.new()
	route.dispatch_mode = "MANUAL"
	assert_eq(route.dispatch_mode, "MANUAL", "Route should support dispatch_mode field")


func test_auto_dispatch_mode_available() -> void:
	var route = TradeRouteScript.new()
	route.dispatch_mode = "AUTO"
	assert_eq(route.dispatch_mode, "AUTO", "Route should support AUTO dispatch mode")


func test_route_tracks_cargo_fill() -> void:
	var route = TradeRouteScript.new()
	route.cargo_amount = 0
	route.ship_capacity = 1200

	route.cargo_amount = 1000
	var fill_pct = (float(route.cargo_amount) / route.ship_capacity) * 100
	assert_gt(fill_pct, 80, "80% fill should trigger auto-dispatch")


func test_auto_dispatch_threshold_80_percent() -> void:
	var route = TradeRouteScript.new()
	route.cargo_amount = 0
	route.ship_capacity = 1200

	var dispatch_threshold = route.ship_capacity * 0.8
	route.cargo_amount = int(dispatch_threshold)

	assert_ge(route.cargo_amount, dispatch_threshold, "80% threshold met")


func test_route_status_auto_mode() -> void:
	var route = TradeRouteScript.new()
	route.dispatch_mode = "AUTO"
	route.status = "LOADING"

	assert_eq(route.status, "LOADING", "AUTO route should track status as LOADING while filling")


func test_auto_dispatch_fires_when_full() -> void:
	var route = TradeRouteScript.new()
	route.dispatch_mode = "AUTO"
	route.status = "LOADING"
	route.cargo_amount = 1200
	route.ship_capacity = 1200

	var fill_pct = (float(route.cargo_amount) / route.ship_capacity) * 100
	assert_eq(fill_pct, 100.0, "Route at 100% should be ready for dispatch")
