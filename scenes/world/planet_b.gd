extends Node2D
## PlanetB — "Vortex Drift" — second location with high-value ore.
## Aethite (8 CR, cyan) and Voidstone (15 CR, near-black purple).

@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
@onready var launch_pad: Node2D = $Outpost/LaunchPad
@onready var drone_bay: Node2D = $Outpost/DroneBay


func _ready() -> void:
	call_deferred("_setup_navigation")
	await get_tree().process_frame

	# Connect launch pad → main scene transition
	if launch_pad:
		launch_pad.return_requested.connect(_on_return_requested)

	# Connect drone bay panel
	var shop_panel = get_tree().get_first_node_in_group("shop_panel")
	if drone_bay and shop_panel:
		drone_bay.bay_opened.connect(func(): shop_panel.open_drone_bay(drone_bay))
		drone_bay.bay_closed.connect(func(): shop_panel.close())


func _setup_navigation() -> void:
	var nav_poly = NavigationPolygon.new()
	nav_poly.add_outline(PackedVector2Array([
		Vector2(-150, -150), Vector2(2500, -150),
		Vector2(2500, 1700), Vector2(-150, 1700)
	]))
	nav_poly.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav_poly.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_ROOT_NODE_CHILDREN
	nav_poly.agent_radius = 5.0
	var source_geo = NavigationMeshSourceGeometryData2D.new()
	NavigationServer2D.parse_source_geometry_data(nav_poly, source_geo, self)
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_geo)
	navigation_region.navigation_polygon = nav_poly


func _on_return_requested() -> void:
	# Bubble up to main.gd via a group call
	var main = get_tree().get_first_node_in_group("main_scene")
	if main and main.has_method("return_to_a1"):
		main.return_to_a1()
