class_name OreQualityLot
## Placeholder OreQualityLot for testing. Full implementation in later phase.
## Stores quality attributes for a batch of ore from a specific deposit.

var ore_type: String
var quantity: int = 0
var attributes: Dictionary = {}  # attribute_name -> value (1-1000)

func _init(p_ore_type: String = "") -> void:
	ore_type = p_ore_type
	# Initialize with placeholder attributes
	attributes["ER"] = randi_range(1, 1000)  # Extraction Rate for testing


static func generate(ore_type: String = "", concentration: float = 50.0) -> OreQualityLot:
	var lot = OreQualityLot.new(ore_type)
	lot.attributes["ER"] = randi_range(int(concentration), minf(1000, int(concentration * 2)))
	return lot
