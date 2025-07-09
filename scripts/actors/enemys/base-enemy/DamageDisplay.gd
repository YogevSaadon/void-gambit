# scripts/actors/enemys/base-enemy/DamageDisplay.gd
extends Node
class_name DamageDisplay

# ===== BULLET HELL DAMAGE AGGREGATION MANAGER =====
# PROBLEM: High-RoF weapons create visual spam (50+ damage numbers per enemy)
# SOLUTION: Single damage number per enemy that aggregates multiple hits
# MEMORY SAFETY: Handles enemy death during active damage display

var enemy: BaseEnemy
var _active_dn: DamageNumber = null

func _ready() -> void:
	enemy = get_parent() as BaseEnemy

func show_damage(value: float, is_crit: bool) -> void:
	"""
	DAMAGE AGGREGATION: Reuses existing damage number or creates new one
	
	BULLET HELL OPTIMIZATION: Prevents 50+ overlapping damage numbers per enemy
	MEMORY SAFETY: Validates references before reuse (enemies die unpredictably)
	"""
	# REUSE EXISTING: Add to active damage number if still accepting damage
	if _active_dn and is_instance_valid(_active_dn) and not _active_dn.is_detached and _active_dn._accepting_damage:
		_active_dn.add_damage(value, is_crit)
		return

	# CLEANUP INVALID REFERENCE: Enemy died or damage number stopped accepting
	if _active_dn and (not is_instance_valid(_active_dn) or not _active_dn._accepting_damage):
		_active_dn = null

	# CREATE NEW DAMAGE NUMBER: First hit or previous one finished
	_active_dn = preload("res://scripts/ui/DamageNumber.gd").new()
	
	# ANCHOR POSITIONING: Use DamageAnchor if available for consistent placement
	var anchor = enemy.get_node_or_null("DamageAnchor")
	if anchor:
		anchor.add_child(_active_dn)
	else:
		enemy.add_child(_active_dn)
		
	_active_dn.add_damage(value, is_crit)
	_active_dn.connect("label_finished", Callable(self, "_on_dn_finished"))

func _on_dn_finished() -> void:
	_active_dn = null

func detach_active() -> void:
	"""
	ENEMY DEATH HANDLING: Safely detach damage number when enemy dies
	
	MEMORY SAFETY: Stops accepting new damage but allows animation completion
	VISUAL CONTINUITY: No abrupt cutoffs when enemies die mid-animation
	"""
	if _active_dn and is_instance_valid(_active_dn):
		_active_dn._accepting_damage = false
		_active_dn.detach()
	_active_dn = null

func _exit_tree() -> void:
	detach_active()
