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

# ───── Universal Spaceship Movement ─────
@export var rotation_speed: float = 3.0
@export var disable_velocity_rotation: bool = false

# ───── Enemy metadata ─────
@export var power_level: int = 1
@export var rarity: String = "common"
@export_range(1,100) var min_level: int = 1
@export_range(1,100) var max_level: int = 5
@export var enemy_type: String = "default"

# ───── Performance optimization ─────
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
var _original_power_level: int

# ───── Components ─────
var _move_logic: Node = null
var _attack_logic: Node = null
var _drop_handler: DropHandler = null
var _damage_display: DamageDisplay = null

# ───── References ─────
@onready var _status: Node = $StatusComponent if has_node("StatusComponent") else null
@onready var _pd: PlayerData = get_tree().root.get_node_or_null("PlayerData")
@onready var _power_ind: Node = $PowerIndicator if has_node("PowerIndicator") else null

# ───── Lifecycle ─────
func _enter_tree() -> void:
	_cache_base_stats()

func _ready() -> void:
	# FIXED: Cache original power level AFTER child _enter_tree() has run
	_original_power_level = power_level
	_apply_combat_scaling()
	
	_setup_collision()
	_setup_components()
	_discover_behaviors()
	_setup_groups()
	
	if _power_ind and _power_ind.has_method("apply_power_level"):
		_power_ind.apply_power_level(power_level)

# ───── Setup methods ─────
func _cache_base_stats() -> void:
	_base_hp = max_health
	_base_sh = max_shield
	_base_spd = speed
	_base_reg = shield_recharge_rate
	_base_dmg = damage

func _apply_combat_scaling() -> void:
	max_health = _base_hp * power_level
	health = max_health
	max_shield = _base_sh * power_level
	shield = max_shield
	damage = _base_dmg * power_level
	
	speed = _base_spd
	shield_recharge_rate = _base_reg

# ===== NEW: Method for spawn cost calculations =====
func get_budget_power_level() -> int:
	"""Return the original power level for spawn cost calculations"""
	return _original_power_level

func _setup_collision() -> void:
	collision_layer = 1 << CollisionLayers.LAYER_ENEMIES
	collision_mask = 0  # Enemies don't detect via collision
	monitoring = false
	monitorable = true

func _setup_components() -> void:
	if not has_node("DropHandler"):
		_drop_handler = preload("res://scripts/actors/enemys/base-enemy/DropHandler.gd").new()
		_drop_handler.name = "DropHandler"
		add_child(_drop_handler)
	else:
		_drop_handler = $DropHandler
	
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

# ───── Per-frame ─────
func _physics_process(delta: float) -> void:
	if _move_logic and _move_logic.has_method("tick_movement"):
		_move_logic.tick_movement(delta)
	if _attack_logic and _attack_logic.has_method("tick_attack"):
		_attack_logic.tick_attack(delta)

	move(delta)
	recharge_shield(delta)
	
	# ───── VELOCITY ROTATION (Fixed conditional) ─────
	if not disable_velocity_rotation and velocity.length() > 10.0:
		var target_angle = velocity.angle()
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	
	# Keep damage anchor upright
	var damage_anchor = get_node_or_null("DamageAnchor")
	if damage_anchor:
		damage_anchor.rotation = -rotation

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
	
	if not _status.has_method("apply_infection") or not _status.get("infection"):
		return
	
	var infection = _status.infection
	if infection == null:
		return
	
	var radius: float = _pd.get_stat("weapon_range") * 0.4
	
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsShapeQueryParameters2D.new()
	
	var circle = CircleShape2D.new()
	circle.radius = radius
	
	params.shape = circle
	params.transform = Transform2D(0, global_position)
	params.collision_mask = 1 << CollisionLayers.LAYER_ENEMIES
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	var results = space_state.intersect_shape(params, PerformanceConstants.MAX_PHYSICS_QUERY_RESULTS)
	
	var best: Node = null
	var best_d: float = radius
	
	for result in results:
		var enemy = result.collider
		if enemy == self or not is_instance_valid(enemy):
			continue
		var d := global_position.distance_to(enemy.global_position)
		if d < best_d:
			best_d = d
			best = enemy
	
	if best and best.has_node("StatusComponent"):
		var target_status = best.get_node("StatusComponent")
		if target_status and target_status.has_method("apply_infection"):
			target_status.apply_infection(infection.dps, infection.remaining_time)

# ===== NEW: Post‑spawn tier scaling for new spawning system =====
func _post_spawn_setup(level: int) -> void:
	"""
	Called after enemy is spawned to apply tier scaling.
	
	This method handles the tier-based power scaling for the new fixed spawning system.
	It uses the original power level (cached in _original_power_level) and applies
	tier multipliers based on the current game level.
	"""
	# Get tier multiplier for current level
	var tier_mult := PowerBudgetCalculator.get_tier_multiplier(level)
	
	# Apply tier scaling to power level
	power_level = _original_power_level * tier_mult
	
	# Re-apply combat scaling with new power level
	_apply_combat_scaling()
	
	# Update power indicator if present
	if _power_ind and _power_ind.has_method("apply_power_level"):
		_power_ind.apply_power_level(power_level)

# ───── Memory cleanup ─────
func _exit_tree() -> void:
	if _damage_display:
		_damage_display.detach_active()
