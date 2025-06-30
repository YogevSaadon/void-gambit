# scripts/actors/enemys/missile/EnemyMissile.gd
extends BaseEnemy
class_name EnemyMissile

# ===== EXPLOSION CONFIGURATION =====
@export var explosion_scene: PackedScene = preload("res://scenes/projectiles/enemy_projectiles/EnemyExplosion.tscn")
@export var base_explosion_damage: float = 40.0
@export var base_explosion_radius: float = 80.0

# ===== STATE =====
var has_exploded: bool = false

func _enter_tree() -> void:
	enemy_type = "missile"  
	
	# ── Base stats at power-level 1 ─────
	max_health = 15             # Low HP - can be shot down
	max_shield = 0
	speed = 140                 # Fast homing speed
	shield_recharge_rate = 0

	# No contact damage - explodes instead
	damage = 0                  
	damage_interval = 0.0       

	# ── Metadata ─────
	power_level = 1             # Will be set by spawner/launcher
	rarity = "common"
	min_level = 2               
	max_level = 10

	# Call parent's _enter_tree for power scaling
	super._enter_tree()

func _ready() -> void:
	super._ready()
	
	# PROPER FIX: Set drop handler to null instead of freeing it
	# This prevents BaseEnemy from trying to use a freed reference
	if _drop_handler:
		_drop_handler.queue_free()
		_drop_handler = null  # ← This is the key fix!
	
	# Remove ContactDamage - we don't want damage over time
	if has_node("ContactDamage"):
		$ContactDamage.queue_free()
	
	# Connect DamageZone to explode ONLY on player contact
	if has_node("DamageZone"):
		var damage_zone = $DamageZone
		if not damage_zone.body_entered.is_connected(_on_player_contact):
			damage_zone.body_entered.connect(_on_player_contact)

func _on_player_contact(body: Node) -> void:
	"""ONLY explosion trigger - when missile touches player"""
	if body.is_in_group("Player") and not has_exploded:
		_explode_and_die()

func on_death() -> void:
	"""When shot down - just die, NO explosion"""
	# Skip explosion, just die normally
	super.on_death()

func _explode_and_die() -> void:
	"""Explode AND destroy missile"""
	if has_exploded:
		return
	
	has_exploded = true
	
	# Create explosion with power-scaled damage
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		explosion.damage = base_explosion_damage * power_level
		explosion.radius = base_explosion_radius
		explosion.crit_chance = 0.0
		
		get_tree().current_scene.add_child(explosion)
		print("EnemyMissile exploded on contact! Damage: %d" % explosion.damage)
	
	# Die immediately after explosion
	queue_free()
