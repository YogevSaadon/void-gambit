# scripts/actors/player/Player.gd - INSTANT DEATH HANDLING
extends CharacterBody2D
class_name Player

# ───── Actor properties ─────
@export var max_health: int = 100
@export var health: int = 100
@export var max_shield: int = 0
@export var shield: int = 0
@export var speed: float = 220.0
@export var shield_recharge_rate: float = 5.0

# ───── Shield recharge accumulator ─────
var shield_recharge_accumulator: float = 0.0

# ───── Dependencies (injected) ─────
var player_data: PlayerData = null

# ───── Sub-systems ─────
@onready var blink_system: BlinkSystem = $BlinkSystem
@onready var weapon_system: WeaponSystem = $WeaponSystem
@onready var movement_system: PlayerMovement = $PlayerMovement

# ─────  i-frame state ─────
var invuln_timer: float = 0.0
const INVULN_TIME := 0.3

# ───── DEATH STATE ─────
var is_dead: bool = false  # Prevent multiple death calls

# ───── Init ─────
func initialize(p_data: PlayerData) -> void:
	if not p_data:
		push_error("Player: PlayerData is null")
		return
		
	player_data = p_data
	add_to_group("Player")
	collision_layer = CollisionLayers.get_player_layer()
	collision_mask = CollisionLayers.MASK_PLAYER

	max_health = int(player_data.get_stat("max_hp"))
	health = int(player_data.hp)
	max_shield = int(player_data.get_stat("max_shield"))
	shield = int(player_data.shield)
	shield_recharge_rate = player_data.get_stat("shield_recharge_rate")
	speed = player_data.get_stat("speed")

	# Reset accumulator
	shield_recharge_accumulator = 0.0

	if not blink_system:
		push_error("Player: BlinkSystem component missing")
		return
	if not weapon_system:
		push_error("Player: WeaponSystem component missing")
		return
	if not movement_system:
		push_error("Player: PlayerMovement component missing")
		return

	blink_system.initialize(self, player_data)
	weapon_system.owner_player = self
	movement_system.initialize(self)

# ───── Physics loop ─────
func _physics_process(delta: float) -> void:
	# STOP ALL PROCESSING IF DEAD
	if is_dead:
		return
		
	invuln_timer = max(invuln_timer - delta, 0.0)
	movement_system.physics_step(delta)
	weapon_system.auto_fire(delta)
	recharge_shield(delta)

# ───── Shield recharge with accumulator ─────
func recharge_shield(delta: float) -> void:
	if shield >= max_shield:
		shield_recharge_accumulator = 0.0
		return
	
	# Accumulate fractional shield progress
	shield_recharge_accumulator += shield_recharge_rate * delta
	
	# Extract whole shield points
	var shield_to_add = int(shield_recharge_accumulator)
	if shield_to_add > 0:
		shield = min(shield + shield_to_add, max_shield)
		shield_recharge_accumulator -= float(shield_to_add)
		
		if shield >= max_shield:
			shield_recharge_accumulator = 0.0

# ───── Damage handling ─────
func take_damage(amount: int) -> void:
	# IGNORE DAMAGE IF ALREADY DEAD
	if is_dead:
		return
		
	# Apply armor damage reduction
	var effective_damage = amount
	if player_data:
		var armor_value = player_data.get_stat("armor")
		var damage_multiplier = _calculate_damage_multiplier(armor_value)
		effective_damage = int(amount * damage_multiplier)
		
		if armor_value > 0:
			var reduction_percent = (1.0 - damage_multiplier) * 100.0
			print("Armor: %.0f → %.0f%% damage reduction (%.0f → %.0f damage)" % [
				armor_value, reduction_percent, amount, effective_damage
			])
	
	# Apply damage to shield first, then health
	if shield > 0:
		shield -= effective_damage
		if shield < 0:
			health += shield
			shield = 0
	else:
		health -= effective_damage

	# Reset recharge accumulator when taking damage
	shield_recharge_accumulator = 0.0

	if health <= 0:
		destroy()

func _calculate_damage_multiplier(armor_value: float) -> float:
	if armor_value <= 0:
		return 1.0
	
	var reduction = armor_value / (armor_value + 100.0)
	return 1.0 - reduction

# ───── FIXED: Instant death handling ─────
func destroy() -> void:
	# Prevent multiple death calls
	if is_dead:
		return
	is_dead = true
	
	print("Player died! Returning to main menu...")
	
	# INSTANT: Stop all player functions immediately
	set_physics_process(false)
	set_process(false)
	
	# INSTANT: Make player invisible and disable collision
	visible = false
	collision_layer = CollisionLayers.get_player_layer()
	collision_mask = CollisionLayers.MASK_PLAYER
	
	# INSTANT: Stop all movement
	velocity = Vector2.ZERO
	if movement_system:
		movement_system._stop_movement_immediately()
	
	# INSTANT: Remove from player group so enemies stop targeting
	remove_from_group("Player")
	
	# VERY SHORT delay for visual feedback, then menu
	var timer = Timer.new()
	timer.wait_time = 0.2  # Much shorter - just 0.2 seconds
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_return_to_main_menu)
	timer.start()

func _return_to_main_menu() -> void:
	# Clean up any active effects
	var pem = get_tree().root.get_node_or_null("PassiveEffectManager")
	if pem:
		pem.reset()
	
	# Change to main menu scene
	get_tree().change_scene_to_file("res://scenes/game/MainMenu.tscn")

# ───── Damage intake ─────
func receive_damage(amount: int) -> void:
	# IGNORE DAMAGE IF ALREADY DEAD
	if is_dead or invuln_timer > 0.0:
		return          

	take_damage(amount)   
	invuln_timer = INVULN_TIME
	_flash_invuln()

func _flash_invuln() -> void:
	if is_dead:
		return
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.2, 0.05)
	tw.tween_property(self, "modulate:a", 1.0, 0.05)

# ───── Weapon helpers ─────
func get_weapon_slot(i: int) -> Node: 
	return weapon_system.get_slot(i)
	
func clear_all_weapons() -> void: 
	weapon_system.clear_all()
	
func equip_weapon(s: PackedScene, i: int) -> void: 
	weapon_system.equip(s, i)

# ───── Level reset ─────
func reset_per_level() -> void:
	health = int(player_data.get_stat("max_hp"))
	shield = int(player_data.get_stat("max_shield"))
	shield_recharge_accumulator = 0.0
	blink_system.initialize(self, player_data)
