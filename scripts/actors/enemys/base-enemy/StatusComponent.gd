# /scripts/enemies/base_enemy/StatusComponent.gd
extends Node
class_name StatusComponent

@onready var pd: PlayerData = get_tree().root.get_node("PlayerData")

# Represents one Damage-over-Time effect (infection, burn, etc.)
class DOT:
	var dps: float
	var tick_interval: float
	var remaining_time: float
	var tick_accumulator: float
	var stacks: int

var infection: DOT = null
var _processing_disabled: bool = false

# ─── Public API ─────────────────────────────────
func apply_infection(base_dps: float, duration: float) -> void:
	"""
	If the enemy is already infected, add a stack (up to 3) 
	and refresh remaining time. Otherwise, create a new DOT.
	"""
	# Don't apply infection if processing is disabled (enemy dead)
	if _processing_disabled:
		return
		
	if infection:
		infection.stacks = min(infection.stacks + 1, 3)
		# Each stack increases dps by 33%
		infection.dps = base_dps * (1.0 + CombatConstants.INFECTION_STACK_MULTIPLIER * infection.stacks)
		infection.remaining_time = duration
	else:
		infection = DOT.new()
		infection.dps = base_dps
		infection.tick_interval = 0.5
		infection.remaining_time = duration
		infection.tick_accumulator = infection.tick_interval
		infection.stacks = 1

# ─── Internal Tick Loop ─────────────────────────
func _process(delta: float) -> void:
	# Early exit if processing is disabled
	if _processing_disabled:
		return
		
	# Check if parent enemy is dead/dying
	var parent = get_parent()
	if not parent or not is_instance_valid(parent):
		_disable_processing()
		return
	
	# Check if parent enemy has been queued for deletion
	if parent.is_queued_for_deletion():
		_disable_processing()
		return
	
	# Check if parent enemy has died (health <= 0)
	if parent.has_method("get_actor_stats"):
		var stats = parent.get_actor_stats()
		if stats.get("hp", 0) <= 0:
			_disable_processing()
			return

	# Check if infection exists
	if not infection:
		return

	# Safe property access with validation
	if not _is_infection_safe():
		_disable_processing()
		return

	# Safe updates
	_safe_update_infection(delta)

func _is_infection_safe() -> bool:
	"""Check if infection object is safe to access"""
	if not infection:
		return false
	
	# Basic check - if we can access the object reference, it should be safe
	# GDScript doesn't have try/catch, so we rely on null checks and valid references
	return is_instance_valid(infection)

func _safe_update_infection(delta: float) -> void:
	"""Safely update infection properties - FIXED RACE CONDITION"""
	if not infection or _processing_disabled:
		return
		
	# Check again before each property access
	if not is_instance_valid(infection):
		_disable_processing()
		return
		
	infection.remaining_time -= delta
	infection.tick_accumulator -= delta

	if infection.tick_accumulator <= 0.0:
		infection.tick_accumulator += infection.tick_interval
		_tick_damage()
		
		# CRITICAL FIX: Check if enemy died from tick damage
		# _tick_damage() can kill the enemy, which calls _disable_processing(), which sets infection = null
		if not infection or _processing_disabled:
			return  # Enemy died from infection damage, exit safely

	# SECOND CHECK: Only access infection.remaining_time if infection still exists
	if infection and infection.remaining_time <= 0.0:
		infection = null

func _disable_processing() -> void:
	"""Disable all processing and clean up"""
	_processing_disabled = true
	infection = null

# ─── Helpers ─────────────────────────────────────
func _tick_damage() -> void:
	"""
	Deal a slice of the DOT damage. 
	If crit chance applies, roll for crit.
	"""
	# Extra safety check
	if _processing_disabled or not infection:
		return
		
	if not is_instance_valid(infection):
		_disable_processing()
		return
		
	var damage_amount: float = infection.dps * infection.tick_interval
	var is_crit = randf() < pd.get_stat("crit_chance")
	
	# Parent is the enemy node—call its apply_damage:
	# NOTE: This can cause the enemy to die, which triggers _disable_processing()
	if get_parent().has_method("apply_damage"):
		get_parent().apply_damage(damage_amount, is_crit)

func clear_all() -> void:
	"""
	Removes any ongoing status effects (e.g., on enemy death).
	"""
	_disable_processing()

# ─── Additional Safety Methods ─────────────────────
func has_infection() -> bool:
	"""Safe way to check if enemy has infection"""
	return not _processing_disabled and infection != null and is_instance_valid(infection)

func get_infection_time_remaining() -> float:
	"""Safe way to get remaining infection time"""
	if has_infection():
		return infection.remaining_time
	return 0.0
