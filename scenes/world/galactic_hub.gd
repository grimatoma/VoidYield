class_name GalacticHub
extends Node2D
## Galactic Hub — endgame building with passive bonuses and sector completion requirement (M14).

const build_cost_cr: int = 30000
const build_cost_steel: int = 200
const build_cost_alloy: int = 100
const build_cost_void_cores: int = 50
const build_cost_crystal_lattices: int = 30

const sell_price_bonus: float = 1.2  # +20%
const rp_generation_bonus: float = 2.0  # 2× passive RP

var status: String = "BUILDING"  # BUILDING, ACTIVE
var build_progress: float = 0.0


func _ready() -> void:
	pass


func tick(delta: float) -> void:
	if status == "BUILDING":
		build_progress += delta


func complete_build() -> void:
	status = "ACTIVE"


func is_active() -> bool:
	return status == "ACTIVE"


func get_sell_price_multiplier() -> float:
	if is_active():
		return sell_price_bonus
	return 1.0


func get_passive_rp_rate() -> float:
	if is_active():
		return rp_generation_bonus
	return 0.0
