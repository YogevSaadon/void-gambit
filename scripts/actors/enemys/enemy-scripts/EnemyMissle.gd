# scripts/actors/enemys/enemy-scripts/EnemyMissile.gd
extends BaseEnemy
class_name EnemyMissile

# ===== HOMING MISSILE ENEMY =====
# DOMAIN: Suicide unit that explodes on player contact for area denial
# CHALLENGE: Balance threat level with fair gameplay mechanics
# BEHAVIOR: Homes toward player, explodes on contact, no drops (consumable unit)

@export var explosion_damage: float = 40.0
@export var explosion_radius: float = 80.0

var has_exploded: bool = false

func _enter_tree() -> void:
	enemy_type = "missile"
	max_health = 30
	max_shield = 0
	speed = 140
	shield_recharge_rate = 0
	damage = 0  # No contact damage - explosion only
	damage_interval = 0.0
	power_level = 1
	rarity = "common"
	min_level = 2
	max_level = 10
	super._enter_tree()

func _ready() -> void:
	super._ready()
	
	# CONSUMABLE UNIT: No drops, no contact damage
	if _drop_handler:
		_drop_handler.queue_free()
		_drop_handler = null
	
	if has_node("ContactDamage"):
		$ContactDamage.queue_free()
	
	# PROXIMITY DETECTION: Setup player collision for explosion trigger
	if has_node("DamageZone"):
		var damage_zone = $DamageZone
		if not damage_zone.body_entered.is_connected(_on_player_contact):
			damage_zone.body_entered.connect(_on_player_contact)

func _on_player_contact(body: Node) -> void:
	if body.is_in_group("Player"):
		explode()

func explode() -> void:
	"""
	AREA DENIAL EXPLOSION: Direct damage with visual feedback
	
	GAME DESIGN: High damage but telegraphed threat (player can shoot missile down)
	BALANCE: Power scaling makes missiles relevant at all difficulty levels
	"""
	if has_exploded:
		return
	has_exploded = true
	
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		queue_free()
		return
	
	# RANGE-BASED DAMAGE: Full damage within explosion radius
	var distance = global_position.distance_to(player.global_position)
	if distance <= explosion_radius:
		var final_damage = int(explosion_damage * power_level)
		if player.has_method("receive_damage"):
			player.receive_damage(final_damage)
	
	_create_visual_explosion()
	queue_free()

func _create_visual_explosion() -> void:
	"""Simple explosion visual for player feedback"""
	var visual = Node2D.new()
	visual.position = global_position
	get_tree().current_scene.add_child(visual)
	
	var tween = visual.create_tween()
	tween.tween_method(_draw_explosion_circle.bind(visual), 1.0, 0.0, 0.3)
	tween.tween_callback(visual.queue_free)

func _draw_explosion_circle(visual: Node2D, alpha: float) -> void:
	visual.queue_redraw()

func on_death() -> void:
	"""SHOT DOWN: Clean death without explosion when destroyed by player"""
	if _damage_display:
		_damage_display.detach_active()
	if _status and _status.has_method("clear_all"):
		_status.clear_all()
	_spread_infection()
	emit_signal("died")
