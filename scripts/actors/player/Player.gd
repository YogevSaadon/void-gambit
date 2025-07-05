# scripts/actors/player/Player.gd
extends CharacterBody2D
class_name Player

# ───── We need Actor's properties but Player extends CharacterBody2D ─────
@export var max_health: int = 10000
@export var health: int = 10000
@export var max_shield: int = 0
@export var shield: int = 0
@export var speed: float = 200.0
@export var shield_recharge_rate: float = 5.0

# ───── Dependencies (injected) ─────
var player_data: PlayerData = null

# ───── Sub-systems ─────
@onready var blink_system: BlinkSystem = $BlinkSystem
@onready var weapon_system: WeaponSystem = $WeaponSystem
@onready var movement_system: PlayerMovement = $PlayerMovement

# ─────  i-frame state ─────
var invuln_timer: float = 0.0
const INVULN_TIME := 0.3

# ───── Init ─────
func initialize(p_data: PlayerData) -> void:
	player_data = p_data
	add_to_group("Player")
	collision_layer = 1 << 1
	collision_mask = 0

	max_health = int(player_data.get_stat("max_hp"))
	health = int(player_data.hp)
	max_shield = int(player_data.get_stat("max_shield"))
	shield = int(player_data.shield)
	shield_recharge_rate = player_data.get_stat("shield_recharge_rate")
	speed = player_data.get_stat("speed")

	blink_system.initialize(self, player_data)
	weapon_system.owner_player = self
	movement_system.initialize(self)

# ───── Physics loop ─────
func _physics_process(delta: float) -> void:
	invuln_timer = max(invuln_timer - delta, 0.0)
	movement_system.physics_step(delta)
	weapon_system.auto_fire(delta)
	recharge_shield(delta)

# ───── Actor-like methods ─────
func recharge_shield(delta: float) -> void:
	if shield < max_shield:
		shield = min(shield + shield_recharge_rate * delta, max_shield)

func take_damage(amount: int) -> void:
	# ===== Apply armor damage reduction =====
	var effective_damage = amount
	if player_data:
		var armor_value = player_data.get_stat("armor")
		var damage_multiplier = _calculate_damage_multiplier(armor_value)
		effective_damage = int(amount * damage_multiplier)
		
		# Debug armor effectiveness
		if armor_value > 0:
			var reduction_percent = (1.0 - damage_multiplier) * 100.0
			print("Armor: %.0f → %.0f%% damage reduction (%.0f → %.0f damage)" % [
				armor_value, reduction_percent, amount, effective_damage
			])
	
	# Apply damage to shield first, then health
	if shield > 0:
		shield -= effective_damage
		if shield < 0:
			health += shield  # shield is negative, subtracts from health
			shield = 0
	else:
		health -= effective_damage

	if health <= 0:
		destroy()

# ===== Armor calculation belongs in Player, not PlayerData =====
func _calculate_damage_multiplier(armor_value: float) -> float:
	"""
	League of Legends / Brotato style armor formula:
	Damage Reduction % = Armor / (Armor + 100)
	Returns: multiplier to apply to damage (1.0 - reduction_percent)
	"""
	if armor_value <= 0:
		return 1.0
	
	var reduction = armor_value / (armor_value + 100.0)
	return 1.0 - reduction

func destroy() -> void:
	queue_free()  # TODO: hook GameManager death flow

# ───── Damage intake ─────
func receive_damage(amount: int) -> void:
	if invuln_timer > 0.0:
		return          

	take_damage(amount)   
	invuln_timer = INVULN_TIME
	_flash_invuln()

func _flash_invuln() -> void:
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

# ───── Per-level reset ─────
func reset_per_level() -> void:
	health = int(player_data.get_stat("max_hp"))
	shield = int(player_data.get_stat("max_shield"))
	blink_system.initialize(self, player_data)
