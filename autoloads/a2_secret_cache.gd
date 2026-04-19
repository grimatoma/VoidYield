class_name A2SecretCache
extends RefCounted
## Secret cache on A2. One-time reward: 500 CR + Grade A Krysite sample.

var is_discovered: bool = false


func open() -> Dictionary:
	if is_discovered:
		return null
	
	is_discovered = true
	return {
		"credits": 500,
		"krysite_sample": {
			"ore_type": "krysite",
			"grade": "A",
			"oq": 820,
			"fl": 750,
			"quantity": 15,
		}
	}
