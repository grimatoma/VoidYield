extends CanvasLayer
## HUD — Resource rail (top-left), credits panel (top-right), interaction prompt,
## and floating mining progress bar.  Layout matches ui_mocks/01_hud_desktop.svg.

# ── Resource Rail ─────────────────────────────────────────────────────────────
@onready var ore_value_label:     Label = $ResourceRail/RailVBox/OreRow/OreHBox/OreLabels/OreValue
@onready var ore_pool_label:      Label = $ResourceRail/RailVBox/OreRow/OreHBox/OrePool
@onready var crystal_value_label: Label = $ResourceRail/RailVBox/CrystalRow/CrystalHBox/CrystalLabels/CrystalValue
@onready var crystal_pool_label:  Label = $ResourceRail/RailVBox/CrystalRow/CrystalHBox/CrystalPool
@onready var fuel_value_label:    Label = $ResourceRail/RailVBox/FuelRow/FuelHBox/FuelLabels/FuelValue
@onready var inv_value_label:     Label = $ResourceRail/RailVBox/InvRow/InvHBox/InvValue

# ── Credits Panel ─────────────────────────────────────────────────────────────
@onready var credits_label: Label = $CreditsPanel/CreditsHBox/CreditsVBox/CreditsLabel

# ── Crafting materials pill (shown only when scrap or shards > 0) ─────────────
@onready var materials_label: Label = $MaterialsLabel

# ── World-space interaction / mining ──────────────────────────────────────────
@onready var interaction_prompt:   Label       = $InteractionPrompt
@onready var mining_progress_bar:  ProgressBar = $MiningProgressBar


func _ready() -> void:
	GameState.credits_changed.connect(_on_credits_changed)
	GameState.inventory_changed.connect(_on_inventory_changed)
	GameState.storage_changed.connect(_on_storage_changed)
	GameState.interaction_target_changed.connect(_on_interaction_target_changed)
	GameState.ore_sold.connect(_on_ore_sold)
	GameState.materials_changed.connect(_on_materials_changed)

	_on_credits_changed(GameState.credits)
	_on_inventory_changed(GameState.player_carried_ore, GameState.player_max_carry)
	_on_storage_changed(GameState.storage_ore, GameState.storage_capacity)
	_on_interaction_target_changed(null)
	_on_materials_changed(GameState.scrap_metal, GameState.player_carried_shards)

	mining_progress_bar.visible = false


func _process(_delta: float) -> void:
	var target = GameState.current_interaction_target
	if target != null and target.has_method("get_prompt_text"):
		var text = target.get_prompt_text()
		interaction_prompt.text = text
		interaction_prompt.visible = text != ""
	else:
		interaction_prompt.visible = false

	var player = get_tree().get_first_node_in_group("player")
	if player and player.is_mining:
		mining_progress_bar.visible = true
		mining_progress_bar.value = player.get_mining_progress() * 100.0
	else:
		mining_progress_bar.visible = false

	# DEBUG: print viewport size every 2 seconds so we can see if it changes on resize
	_debug_timer += _delta
	if _debug_timer >= 2.0:
		_debug_timer = 0.0
		var vp_size = get_viewport().get_visible_rect().size
		var scale_mode = get_tree().root.content_scale_mode
		print("[HUD DEBUG] viewport=%s  content_scale_mode=%d" % [vp_size, scale_mode])

var _debug_timer: float = 0.0


# ── Signal Handlers ────────────────────────────────────────────────────────────

func _on_credits_changed(new_amount: int) -> void:
	credits_label.text = NumberFormat.format_number(new_amount)
	_bounce_label(credits_label)


func _on_inventory_changed(carried: int, max_carry: int) -> void:
	inv_value_label.text = "%02d/%d" % [carried, max_carry]
	if carried > 0:
		_bounce_label(inv_value_label)

	# ORE row — common (Vorax) carried
	var common = GameState.get_common_carried()
	ore_value_label.text = "%04d" % common

	# CRYSTAL row — carried shards
	crystal_value_label.text = "%03d" % GameState.player_carried_shards

	# FUEL CRYSTAL row — carried krysite (rare)
	fuel_value_label.text = "%03d" % GameState.player_rare_ore


func _on_storage_changed(stored: int, capacity: int) -> void:
	# Pool labels show what is in the shared storage, not player inventory
	var common_stored = stored - GameState.storage_rare_ore \
		- GameState.storage_aethite - GameState.storage_voidstone - GameState.storage_shards
	ore_pool_label.text    = "POOL\n%d/%d" % [common_stored,             capacity]
	crystal_pool_label.text = "POOL\n%d/%d" % [GameState.storage_shards, capacity]


func _on_materials_changed(scrap: int, shards: int) -> void:
	var any_mats = scrap > 0 or shards > 0
	materials_label.visible = any_mats
	if any_mats:
		materials_label.text = "⚙%d ◆%d" % [scrap, shards]


func _on_interaction_target_changed(target: Node2D) -> void:
	if target != null and target.has_method("get_prompt_text"):
		var prompt_text = target.get_prompt_text()
		if prompt_text != "":
			interaction_prompt.text = prompt_text
			interaction_prompt.visible = true
			return
	interaction_prompt.visible = false


func _on_ore_sold(_amount: int, _credits_earned: int) -> void:
	_bounce_label(credits_label)


# ── Juice ──────────────────────────────────────────────────────────────────────

func _bounce_label(label: Control) -> void:
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15)
