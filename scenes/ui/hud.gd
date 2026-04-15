extends CanvasLayer
## HUD — Displays ore count, credits, storage tank, and interaction prompt.

@onready var inventory_label: Label = $TopBar/InventoryLabel
@onready var rare_ore_label: Label = $TopBar/RareOreLabel
@onready var shards_label: Label = $TopBar/ShardsLabel
@onready var materials_label: Label = $TopBar/MaterialsLabel
@onready var credits_label: Label = $TopBar/CreditsLabel
@onready var storage_bar: ProgressBar = $StorageTank/StorageBar
@onready var storage_count_label: Label = $StorageTank/StorageCountLabel
@onready var interaction_prompt: Label = $InteractionPrompt
@onready var mining_progress_bar: ProgressBar = $MiningProgressBar


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
	_on_materials_changed(GameState.scrap_metal, GameState.storage_shards)

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
		var screen_pos = player.get_global_transform_with_canvas().origin
		mining_progress_bar.position = screen_pos + Vector2(-30, -40)
	else:
		mining_progress_bar.visible = false


# --- Signal Handlers ---

func _on_credits_changed(new_amount: int) -> void:
	credits_label.text = "CR: %s" % NumberFormat.format_number(new_amount)
	_bounce_label(credits_label)


func _on_inventory_changed(carried: int, max_carry: int) -> void:
	inventory_label.text = "INV: %d/%d" % [carried, max_carry]
	if carried > 0:
		_bounce_label(inventory_label)
	var rare = GameState.player_rare_ore
	rare_ore_label.visible = rare > 0
	if rare > 0:
		rare_ore_label.text = "KRYSITE: %d" % rare
	var shards = GameState.player_carried_shards
	shards_label.visible = shards > 0
	if shards > 0:
		shards_label.text = "◆%d" % shards


func _on_storage_changed(stored: int, capacity: int) -> void:
	storage_bar.max_value = capacity
	storage_bar.value = stored
	storage_count_label.text = "%d/%d" % [stored, capacity]
	if float(stored) / float(capacity) >= 0.9:
		storage_bar.modulate = Color(0.9, 0.3, 0.2)
	else:
		storage_bar.modulate = Color(0.85, 0.65, 0.2)


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
	rare_ore_label.visible = GameState.player_rare_ore > 0
	shards_label.visible = GameState.player_carried_shards > 0


# --- Juice ---

func _bounce_label(label: Control) -> void:
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15)
