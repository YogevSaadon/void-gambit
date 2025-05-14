extends "res://scripts/actors/Actor.gd"
class_name Enemy

@export var damage: int = 10
@export var damage_interval: float = 1.0
var _damage_timer: float = 0.0

func _ready():
	add_to_group("Enemies")
	collision_layer = 1 << 2       # Layer 2 = Enemy
	collision_mask = 1 << 4        # Only detect Bullets (Layer 4)

	max_health = 200
	health = 200
	speed = 50

func _physics_process(delta):
	_damage_timer -= delta
	recharge_shield(delta)

	var player = get_target_player()
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func get_target_player() -> Node:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		return players[0]
	return null

func can_deal_damage() -> bool:
	return _damage_timer <= 0.0

func reset_damage_timer():
	_damage_timer = damage_interval
