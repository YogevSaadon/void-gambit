extends Node2D
class_name ContactDamage

var enemy   : BaseEnemy
var _player : Node   = null
var _timer  : float  = 0.0

func _enter_tree() -> void:
	enemy = get_parent() as BaseEnemy
	assert(enemy, "ContactDamage must be child of BaseEnemy")

	var zone : Area2D = enemy.get_node("DamageZone") as Area2D
	assert(zone, "ContactDamage: DamageZone missing under %s" % enemy.name)

	# ----- Ensure the zone actually sees the player -------------------
	zone.collision_layer = enemy.collision_layer      # bit-2 (Enemies)
	zone.collision_mask  = 1 << 1                     # bit-1 (Player)
	zone.monitoring      = true                       # just in case

	if not zone.body_entered.is_connected(_on_enter):
		zone.body_entered.connect(_on_enter)
		zone.body_exited .connect(_on_exit)

func _on_enter(body): if body.is_in_group("Player"): _player = body; _timer = 0.0
func _on_exit (body): if body == _player: _player = null

func tick_attack(delta: float) -> void:
	if _player == null:
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = enemy.damage_interval      # scaled by power_level
		_player.receive_damage(enemy.damage)
