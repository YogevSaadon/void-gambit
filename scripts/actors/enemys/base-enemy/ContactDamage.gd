# scripts/actors/enemys/base-enemy/ContactDamage.gd
extends Node
class_name ContactDamage

var enemy: BaseEnemy
var _player: Node = null
var _timer: float = 0.0

func _enter_tree() -> void:
	enemy = get_parent() as BaseEnemy
	assert(enemy, "ContactDamage must be child of BaseEnemy")

func _ready() -> void:
	# Get the DamageZone from the scene
	var zone = enemy.get_node("DamageZone") as Area2D
	assert(zone, "ContactDamage: DamageZone missing under %s" % enemy.name)
	
	# Make sure it has correct collision settings
	zone.collision_layer = enemy.collision_layer  # Same layer as enemy
	zone.collision_mask = 1 << CollisionLayers.LAYER_PLAYER  # Contact damage zones detect player                
	zone.monitoring = true
	
	# Connect signals if not already connected
	if not zone.body_entered.is_connected(_on_enter):
		zone.body_entered.connect(_on_enter)
		zone.body_exited.connect(_on_exit)

func _on_enter(body: Node) -> void:
	if body.is_in_group("Player"):
		_player = body
		_timer = 0.0

func _on_exit(body: Node) -> void:
	if body == _player:
		_player = null

func tick_attack(delta: float) -> void:
	if not _player:
		return
	
	_timer -= delta
	if _timer <= 0.0:
		_timer = enemy.damage_interval
		if _player.has_method("receive_damage"):
			_player.receive_damage(enemy.damage)
