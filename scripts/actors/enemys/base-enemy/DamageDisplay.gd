# scripts/actors/enemys/base-enemy/DamageDisplay.gd
extends Node
class_name DamageDisplay

var enemy: BaseEnemy
var _active_dn: DamageNumber = null

func _ready() -> void:
	enemy = get_parent() as BaseEnemy

func show_damage(value: float, is_crit: bool) -> void:
	if _active_dn and is_instance_valid(_active_dn) and not _active_dn.is_detached:
		_active_dn.add_damage(value, is_crit)
		return

	_active_dn = preload("res://scripts/ui/DamageNumber.gd").new()
	
	# Find anchor point
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
	if _active_dn and is_instance_valid(_active_dn):
		_active_dn.detach()
