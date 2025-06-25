# scripts/actors/enemys/base-enemy/BaseEnemy.gd
extends Area2D
class_name BaseEnemy

signal died

# ───── Stats ─────
@export var max_health: int = 100
@export var health: int = 100
@export var max_shield: int = 0
@export var shield: int = 0
@export var speed: float = 100.0
@export var shield_recharge_rate: float = 0.0

# ───── Enemy metadata ─────
@export var power_level: int = 1
@export var rarity: String = "common"
@export_range(1,100) var min_level: int = 1
@export_range(1,100) var max_level: int = 5
@export var enemy_type: String = "default"

# ───── Performance optimization ─────
# Set to true for teleporting enemies (bosses, blinkers) to bypass spatial hash optimization
# Teleporting enemies use expensive O(n) targeting but this is only for special cases
@export var bypass_spatial_hash: bool = false

# ───── Contact damage ─────
@export var damage: int = 10
@export var damage_interval: float = 1.0

# ───── Movement ─────
var velocity: Vector2 = Vector2.ZERO

# ───── Cached base stats ─────
var _base_hp: int
var _base_sh: int
var _base_spd: float
var _base_reg: float
var _base_dmg: int

# ───── Components ─────
var _move_logic: Node = null
var _attack_logic: Node = null
var _drop_handler: DropHandler = null
var _damage_display: DamageDisplay = null

# ───── Targeting optimization ─────
var _targeting_manager: TargetingManager = null
var _last_position: Vector2 = Vector2.ZERO

# ───── References ─────
@onready var _status: Node = $StatusComponent if has_node("StatusComponent") else null
@onready var _pd: PlayerData = get_tree().root.get_node_or_null("PlayerData")
@onready var _power_ind: Node = $PowerIndicator if has_node("PowerIndicator") else null

# ───── Lifecycle ─────
func _enter_tree() -> void:
	_cache_base_stats()
	_apply_power_scale()

func _ready() -> void:
	_setup_collision()
	_setup_components()
	_discover_behaviors()
	_setup_groups()
	_register_with_targeting_manager()
	
	if _power_ind and _power_ind.has_method("apply_power_level"):
		_power_ind.apply_power_level(power_level)

# ───── Setup methods ─────
func _cache_base_stats() -> void:
	_base_hp = max_health
	_base_sh = max_shield
	_base_spd = speed
	_base_reg = shield_recharge_rate
	_base_dmg = damage

func _apply_power_scale() -> void:
	max_health = _base_hp * power_level
	health = max_health
	max_shield = _base_sh * power_level
	shield = max_shield
	speed = _base_spd * power_level
	shield_recharge_rate = _base_reg * power_level
	damage = _base_dmg * power_level

func _setup_collision() -> void:
	# The enemy itself is the hitbox
	collision_layer = 1 << 2  # Enemy layer
	collision_mask = 0        # Don't detect anything
	monitoring = false        # We don't monitor
	monitorable = true        # But we can be detected by bullets

func _setup_components() -> void:
	# Drop handler
	if not has_node("DropHandler"):
		_drop_handler = preload("res://scripts/actors/enemys/base-enemy/DropHandler.gd").new()
		_drop_handler.name = "DropHandler"
		add_child(_drop_handler)
	else:
		_drop_handler = $DropHandler
	
	# Damage display
	if not has_node("DamageDisplay"):
		_damage_display = preload("res://scripts/actors/enemys/base-enemy/DamageDisplay.gd").new()
		_damage_display.name = "DamageDisplay"
		add_child(_damage_display)
	else:
		_damage_display = $DamageDisplay

func _discover_behaviors() -> void:
	for c in get_children():
		if _move_logic == null and c.has_method("tick_movement"):
			_move_logic = c
		elif _attack_logic == null and c.has_method("tick_attack"):
			_attack_logic = c

func _setup_groups() -> void:
	add_to_group("Enemies")
	if enemy_type != "":
		add_to_group("Enemy_" + enemy_type)

func _register_with_targeting_manager() -> void:
	# Find targeting manager in the scene
	_targeting_manager = get_tree().get_first_node_in_group("TargetingManager")
	if _targeting_manager:
		_targeting_manager.register_enemy(self)
		_last_position = global_position

# ───── Per-frame ─────
func _physics_process(delta: float) -> void:
	if _move_logic and _move_logic.has_method("tick_movement"):
		_move_logic.tick_movement(delta)
	if _attack_logic and _attack_logic.has_method("tick_attack"):
		_attack_logic.tick_attack(delta)

	move(delta)
	recharge_shield(delta)
	
	# Update targeting manager if position changed significantly
	_update_targeting_position()

func _update_targeting_position() -> void:
	if _targeting_manager and not bypass_spatial_hash:
		var pos_change = global_position.distance_squared_to(_last_position)
		if pos_change > 100.0:  # 10 pixel threshold (squared)
			_targeting_manager.update_enemy_position(self, _last_position, global_position)
			_last_position = global_position

# ───── Core mechanics ─────
func move(delta: float) -> void:
	position += velocity * delta

func recharge_shield(delta: float) -> void:
	if shield < max_shield:
		shield = min(shield + shield_recharge_rate * delta, max_shield)

func take_damage(amount: int) -> void:
	if shield > 0:
		shield -= amount
		if shield < 0:
			health += shield
			shield = 0
	else:
		health -= amount

	if health <= 0:
		destroy()

func apply_damage(amount: float, is_crit: bool) -> void:
	if _pd == null: 
		return
	var dmg := amount * (_pd.get_stat("crit_damage") if is_crit else 1.0)
	if _damage_display:
		_damage_display.show_damage(dmg, is_crit)
	take_damage(int(dmg))

# ───── Death ─────
func destroy() -> void:
	on_death()
	queue_free()

func on_death() -> void:
	if _damage_display:
		_damage_display.detach_active()
	
	if _status and _status.has_method("clear_all"):
		_status.clear_all()
	
	_spread_infection()
	
	if _drop_handler:
		_drop_handler.drop_loot()
	
	emit_signal("died")

# ───── Special mechanics ─────
func _spread_infection() -> void:
	if _status == null or _pd == null:
		return
	
	# Check if status component has infection properly
	if not _status.has_method("apply_infection") or not _status.get("infection"):
		return
	
	var infection = _status.infection
	if infection == null:
		return
	
	var radius: float = _pd.get_stat("weapon_range") * 0.4
	var best: Node = null
	var best_d: float = radius

	for e in get_tree().get_nodes_in_group("Enemies"):
		if e == self: 
			continue
		var d := global_position.distance_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
