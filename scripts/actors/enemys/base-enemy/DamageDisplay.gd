# scripts/actors/enemys/base-enemy/DamageDisplay.gd
extends Node
class_name DamageDisplay

# ===== REFERENCES =====
var enemy: BaseEnemy
var _active_dn: DamageNumber = null

# ===== INITIALIZATION =====
func _ready() -> void:
	enemy = get_parent() as BaseEnemy

# ===== DAMAGE DISPLAY MANAGEMENT =====
func show_damage(value: float, is_crit: bool) -> void:
	"""
	Display damage number with aggregation - combines multiple hits into single display.
	
	MEMORY SAFETY: Validates existing damage numbers before reuse to prevent 
	references to freed objects when enemies die rapidly.
	"""
	# Check if existing damage number can accept more damage
	if _active_dn and is_instance_valid(_active_dn) and not _active_dn.is_detached and _active_dn._accepting_damage:
		_active_dn.add_damage(value, is_crit)
		return

	# Clean up invalid reference
	if _active_dn and (not is_instance_valid(_active_dn) or not _active_dn._accepting_damage):
		_active_dn = null

	# Create new damage number
	_active_dn = preload("res://scripts/ui/DamageNumber.gd").new()
	
	# Find anchor point for attachment
	var anchor = enemy.get_node_or_null("DamageAnchor")
	if anchor:
		anchor.add_child(_active_dn)
	else:
		enemy.add_child(_active_dn)
		
	_active_dn.add_damage(value, is_crit)
	_active_dn.connect("label_finished", Callable(self, "_on_dn_finished"))

func _on_dn_finished() -> void:
	"""Clear reference when damage number completes"""
	_active_dn = null

# ===== ENEMY DEATH HANDLING =====
func detach_active() -> void:
	"""
	Detach active damage number when enemy dies.
	
	MEMORY SAFETY: Stops accepting new damage but allows existing animation 
	to complete naturally, preventing abrupt visual cutoffs.
	"""
	if _active_dn and is_instance_valid(_active_dn):
		_active_dn._accepting_damage = false
		_active_dn.detach()
	_active_dn = null

# ===== CLEANUP =====
func _exit_tree() -> void:
	"""Ensure cleanup on removal"""
	detach_active()
