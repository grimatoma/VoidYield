extends CanvasLayer
## HUD — Resource rail (top-left), credits panel (top-right), interaction prompt,
## and floating mining progress bar.  Layout matches design_mocks/11_hud_desktop.svg.

const NumberFormat = preload("res://scripts/utils/number_format.gd")

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

# ── Debug controls ──────────────────────────────────────────────────────────────
var debug_fill_button: Button = null

# ── Research button ──────────────────────────────────────────────────────────────
var research_button: Button = null


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

	# Setup debug fill button (only visible when debug_click_mode is true)
	debug_fill_button = Button.new()
	debug_fill_button.text = "⚡ DEBUG FILL"
	debug_fill_button.custom_minimum_size = Vector2(120, 30)
	debug_fill_button.add_theme_font_size_override("font_size", 10)
	debug_fill_button.add_theme_color_override("font_color", Color(0.831, 0.658, 0.270))
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.545, 0.227, 0.164, 0.8)
	debug_fill_button.add_theme_stylebox_override("normal", style)
	debug_fill_button.pressed.connect(_on_debug_fill_pressed)
	add_child(debug_fill_button)
	debug_fill_button.visible = GameState.debug_click_mode

	# Setup research button
	research_button = Button.new()
	research_button.text = "🔬 RESEARCH"
	research_button.custom_minimum_size = Vector2(120, 30)
	research_button.add_theme_font_size_override("font_size", 10)
	research_button.add_theme_color_override("font_color", Color(0.831, 0.658, 0.270))
	var style2 = StyleBoxFlat.new()
	style2.bg_color = Color(0.101, 0.101, 0.113, 0.9)
	research_button.add_theme_stylebox_override("normal", style2)
	research_button.pressed.connect(_on_research_pressed)
	add_child(research_button)


func _process(_delta: float) -> void:
	# Position buttons in bottom-right corner
	if debug_fill_button or research_button:
		var viewport_size = get_viewport_rect().size
		if debug_fill_button:
			debug_fill_button.position = viewport_size - Vector2(debug_fill_button.custom_minimum_size.x + 10, debug_fill_button.custom_minimum_size.y + 10)
			debug_fill_button.visible = GameState.debug_click_mode
		if research_button:
			var offset_y = debug_fill_button.custom_minimum_size.y + 15 if GameState.debug_click_mode else 10
			research_button.position = viewport_size - Vector2(research_button.custom_minimum_size.x + 10, research_button.custom_minimum_size.y + offset_y)

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


func _on_debug_fill_pressed() -> void:
	GameState.debug_fill_resources()


func _on_research_pressed() -> void:
	# TODO: Implement research button when tech_tree_panel is fixed
	print("[HUD] Research button pressed - feature coming soon!")
