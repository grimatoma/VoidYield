class_name TradeRoute
extends Resource
## Data class for cargo trade routes between planets.

var route_id: String = ""
var source_planet: String = ""
var destination_planet: String = ""
var cargo_class: String = ""  # "bulk", "liquid", "container", "heavy"
var dispatch_mode: String = "MANUAL"  # MANUAL, AUTO
var status: String = "ACTIVE"  # ACTIVE, LOADING, DELAYED, STALLED, BREAKDOWN
var cargo_amount: int = 0
var ship_ref: Node = null
