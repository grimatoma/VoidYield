class_name LogisticsManager
extends RefCounted
## Manages cargo trade routes between planets.

var routes: Dictionary = {}
var _next_route_id: int = 1

signal route_created(route_id: String)
signal route_dispatched(route_id: String)
signal route_completed(route_id: String)


func create_route(source: String, destination: String, cargo_class: String) -> TradeRoute:
	var route = TradeRoute.new()
	route.route_id = "route_%d" % _next_route_id
	_next_route_id += 1
	
	route.source_planet = source
	route.destination_planet = destination
	route.cargo_class = cargo_class
	route.status = "LOADING"
	
	routes[route.route_id] = route
	route_created.emit(route.route_id)
	
	return route


func dispatch_route(route_id: String) -> bool:
	if not route_id in routes:
		return false
	
	var route = routes[route_id]
	
	# Cannot dispatch empty route
	if route.cargo_amount <= 0:
		return false
	
	route.status = "ACTIVE"
	route_dispatched.emit(route_id)
	return true


func get_route(route_id: String) -> TradeRoute:
	if route_id in routes:
		return routes[route_id]
	return null


func get_active_routes() -> Array:
	var active = []
	for route in routes.values():
		if route.status == "ACTIVE":
			active.append(route)
	return active
