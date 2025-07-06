# scripts/actors/enemys/enemy-scripts/EnemyMissile.gd
extends BaseEnemy
class_name EnemyMissile

# ===== EXPLOSION CONFIG =====
@export var explosion_damage: float = 40.0
@export var explosion_radius: float = 80.0
@export var explosion_scene: PackedScene = preload("res://scenes/projectiles/enemy_projectiles/EnemyExplosion.tscn")

# ===== PROPER ENEMY INITIALIZATION =====
func _enter_tree() -> void:
	enemy_type = "missile"
	
	# ── Base stats at power-level 1 ─────
	max_health = 300             # Low HP - can be shot down
	max_shield = 0
	speed = 140                 # Fast homing speed
	shield_recharge_rate = 0

	# No contact damage - only explosion damage
	damage = 0                  
	damage_interval = 0.0       

	# ── Metadata ─────
	power_level = 1
	rarity = "common"
	min_level = 2               
	max_level = 10

	# Call parent's _enter_tree for power scaling
	super._enter_tree()

func _ready() -> void:
	super._ready()
	
	# No drops from missiles
	if _drop_handler:
		_drop_handler.queue_free()
		_drop_handler = null
	
	# Remove ContactDamage - we don't want it
	if has_node("ContactDamage"):
		$ContactDamage.queue_free()
	
	# Connect to player contact for explosion trigger
	if has_node("DamageZone"):
		var damage_zone = $DamageZone
		if not damage_zone.body_entered.is_connected(_on_player_contact):
			damage_zone.body_entered.connect(_on_player_contact)

func _on_player_contact(body: Node) -> void:
	"""When missile touches player - explode and die"""
	if body.is_in_group("Player"):
		print("Enemy missile hit player - exploding!")
		_explode()

func _explode() -> void:
	"""Create red explosion that damages player"""
	# Create EnemyExplosion scene
	var explosion = explosion_scene.instantiate()
	
	# Position explosion at missile location
	explosion.global_position = global_position
	
	# Configure explosion damage (scaled by power level)
	explosion.damage = explosion_damage * power_level
	explosion.radius = explosion_radius
	explosion.crit_chance = 0.0
	
	print("Created enemy explosion: damage=%.0f (%.0f * %.0f), radius=%.0f" % [
		explosion.damage, explosion_damage, power_level, explosion.radius
	])
	
	# Add explosion to scene
	get_tree().current_scene.add_child(explosion)
	
	# Missile dies after exploding
	queue_free()

func on_death() -> void:
	"""When missile is shot down - DON'T explode (this was the bug)"""
	print("Enemy missile shot down - no explosion")
	
	# Do normal enemy death cleanup WITHOUT explosion
	if _damage_display:
		_damage_display.detach_active()
	
	if _status and _status.has_method("clear_all"):
		_status.clear_all()
	
	_spread_infection()
	
	emit_signal("died")
	
	# NOTE: Don't call _explode() here - that was the original bug!
