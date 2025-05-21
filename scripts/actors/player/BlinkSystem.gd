extends Node
class_name BlinkSystem

signal player_blinked(position: Vector2)

var player: Player = null
var pd: PlayerData = null

var max_blinks: int = 1
var current_blinks: int = 1
var cooldown: float = 5.0
var blink_timer: float = 0.0

func initialize(p: Player, player_data: PlayerData) -> void:
	player = p
	pd = player_data

	max_blinks = int(pd.get_stat("blinks"))
	current_blinks = max_blinks
	cooldown = pd.get_stat("blink_cooldown")
	blink_timer = 0.0

func _process(delta: float) -> void:
	_recharge(delta)

func try_blink(target_position: Vector2) -> void:
	if current_blinks <= 0:
		return

	current_blinks -= 1
	blink_timer = 0.0

	player.global_position = target_position
	player.velocity = Vector2.ZERO
	player.target_position = target_position
	player.shoot_ready_timer = 0.0

	emit_signal("player_blinked", target_position)

func _recharge(delta: float) -> void:
	if current_blinks >= max_blinks:
		return

	blink_timer += delta
	if blink_timer >= cooldown:
		current_blinks += 1
		blink_timer = 0.0
