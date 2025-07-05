# scripts/actors/enemys/enemy-scripts/EnemyMissle.gd
extends BaseEnemy
class_name EnemyMissile

# ===== EXPLOSION CONFIG =====
@export var explosion_damage: float = 40.0
@export var explosion_radius: float = 80.0

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
	var explosion_scene = preload("res://scenes/projectiles/enemy_projectiles/EnemyExplosion.tscn")
	var explosion = explosion_scene.instantiate()
	
	# Position explosion at missile location
	explosion.global_position = global_position
	
	# Configure explosion damage (scaled by power level)
	explosion.damage = explosion_damage * power_level
	explosion.radius = explosion_radius
	explosion.crit_chance = 0.0
	
	# Make sure it targets player (EnemyExplosion should already be configured for this)
	# EnemyExplosion.gd sets: target_group = "Player", collision layers automatically
	
	# Add explosion to scene
	get_tree().current_scene.add_child(explosion)
	
	print("Created enemy explosion: damage=", explosion.damage, " radius=", explosion.radius)
	
	# Missile dies after exploding
	queue_free()

func on_death() -> void:
	"""When missile is shot down - also explode"""
	print("Enemy missile shot down - exploding!")
	_explode()
	# Don't call super.on_death() because we're already exploding
