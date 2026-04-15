extends Node2D
## AsteroidField — The A1 world scene containing the outpost and ore field.

@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
@onready var outpost: Node2D = $Outpost
@onready var shop_terminal: Node2D = $Outpost/ShopTerminal
@onready var drone_bay: Node2D = $Outpost/DroneBay
@onready var spaceship: Node2D = $Outpost/Spaceship

var shop_panel: Node = null
var spaceship_panel: Node = null


func _ready() -> void:
	call_deferred("_setup_navigation")
	await get_tree().process_frame
	shop_panel = get_tree().get_first_node_in_group("shop_panel")
	spaceship_panel = get_tree().get_first_node_in_group("spaceship_panel")

	if shop_terminal and shop_panel:
		shop_terminal.shop_opened.connect(func(): shop_panel.open(shop_terminal))
		shop_terminal.shop_closed.connect(func(): shop_panel.close())

	if drone_bay and shop_panel:
		drone_bay.bay_opened.connect(func(): shop_panel.open_drone_bay(drone_bay))
		drone_bay.bay_closed.connect(func(): shop_panel.close())

	if spaceship and spaceship_panel:
		spaceship.ship_opened.connect(func(s): spaceship_panel.open(s))
		spaceship.ship_closed.connect(func(): spaceship_panel.close())


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
