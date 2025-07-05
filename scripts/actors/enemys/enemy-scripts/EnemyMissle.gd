# scripts/actors/enemys/enemy-scripts/EnemyMissle.gd
extends BaseEnemy
class_name EnemyMissile

# ===== SIMPLE CONFIG =====
@export var explosion_damage: float = 40.0

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
	
	# Connect to player contact
	if has_node("DamageZone"):
		var damage_zone = $DamageZone
		if not damage_zone.body_entered.is_connected(_on_player_contact):
			damage_zone.body_entered.connect(_on_player_contact)

func _on_player_contact(body: Node) -> void:
	"""When missile touches player - deal explosion damage and die"""
	if body.is_in_group("Player"):
		# Deal explosion damage directly to player
		var final_damage = explosion_damage * power_level
		
		if body.has_method("receive_damage"):
			body.receive_damage(int(final_damage))
			print("Missile hit player for ", final_damage, " damage")
		
		# Die
		queue_free()

func on_death() -> void:
	"""When shot down - just die normally, no explosion"""
	super.on_death()
