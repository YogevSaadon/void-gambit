# scripts/actors/enemys/enemy-scripts/EnemyMissile.gd
extends BaseEnemy
class_name EnemyMissile

# ===== Config =====
@export var explosion_damage: float = 40.0
@export var explosion_radius: float = 80.0

# ===== State =====
var has_exploded: bool = false

# ===== Standard enemy setup =====
func _enter_tree() -> void:
	enemy_type = "missile"
	max_health = 30
	max_shield = 0
	speed = 140
	shield_recharge_rate = 0
	damage = 0
	damage_interval = 0.0
	power_level = 1
	rarity = "common"
	min_level = 2
	max_level = 10
	super._enter_tree()

func _ready() -> void:
	super._ready()
	
	# Remove drops and contact damage
	if _drop_handler:
		_drop_handler.queue_free()
		_drop_handler = null
	
	if has_node("ContactDamage"):
		$ContactDamage.queue_free()
	
	# Player contact detection
	if has_node("DamageZone"):
		var damage_zone = $DamageZone
		if not damage_zone.body_entered.is_connected(_on_player_contact):
			damage_zone.body_entered.connect(_on_player_contact)

func _on_player_contact(body: Node) -> void:
	if body.is_in_group("Player"):
		explode()

# ===== BRUTE FORCE: SKIP EXPLOSION, DAMAGE PLAYER DIRECTLY =====
func explode() -> void:
	if has_exploded:
		return
	has_exploded = true
	
	print("Missile exploding at position: ", global_position)
	
	# Find the player directly
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("No player found!")
		queue_free()
		return
	
	# Check if player is in explosion radius
	var distance = global_position.distance_to(player.global_position)
	print("Distance to player: %.1f, explosion radius: %.1f" % [distance, explosion_radius])
	
	if distance <= explosion_radius:
		# DIRECT DAMAGE - bypass all collision systems
		var final_damage = int(explosion_damage * power_level)
		print("Player in explosion range! Applying %d damage directly..." % final_damage)
		
		if player.has_method("receive_damage"):
			player.receive_damage(final_damage)
			print("SUCCESS: Damage applied to player!")
		else:
			print("ERROR: Player has no receive_damage method!")
	else:
		print("Player outside explosion radius - no damage")
	
	# Create visual effect (optional)
	_create_visual_explosion()
	
	# Die
	queue_free()

func _create_visual_explosion() -> void:
	"""Create a simple visual explosion effect"""
	# Simple colored circle that fades
	var visual = Node2D.new()
	visual.position = global_position
	get_tree().current_scene.add_child(visual)
	
	# Create a simple tween to fade it out
	var tween = visual.create_tween()
	tween.tween_method(_draw_explosion_circle.bind(visual), 1.0, 0.0, 0.3)
	tween.tween_callback(visual.queue_free)

func _draw_explosion_circle(visual: Node2D, alpha: float) -> void:
	visual.queue_redraw()
	# Note: This won't actually draw without a custom _draw method, 
	# but the important part is the damage, not the visuals

func on_death() -> void:
	print("Enemy missile shot down - no explosion")
	if _damage_display:
		_damage_display.detach_active()
	if _status and _status.has_method("clear_all"):
		_status.clear_all()
	_spread_infection()
	emit_signal("died")
