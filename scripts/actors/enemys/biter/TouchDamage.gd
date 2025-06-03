# /scripts/actors/enemys/biter/TouchDamage.gd
extends Node2D
class_name TouchDamage
var enemy : BaseEnemy
@export var damage_per_tick : int   = 5
@export var tick_interval   : float = 0.5

var _player : Node = null
var _timer  : float = 0.0

func _ready()->void:
	var zone := enemy.get_node("DamageZone") as Area2D
	zone.body_entered.connect(_on_entered)
	zone.body_exited.connect(_on_exited)

func _on_entered(body:Node)->void:
	if body.is_in_group("Player"):
		_player = body
		_timer = 0.0

func _on_exited(body:Node)->void:
	if body == _player: _player = null

func tick_attack(delta:float)->void:
	if _player == null: return
	_timer -= delta
	if _timer <= 0.0:
		_timer = tick_interval
		if _player and _player.has_method("receive_damage"):
			_player.receive_damage(damage_per_tick)
