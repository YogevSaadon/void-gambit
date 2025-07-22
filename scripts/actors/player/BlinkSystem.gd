extends Node
class_name BlinkSystem

signal player_blinked(position: Vector2)

# ===== REFERENCES =====
var player: Player = null
var pd: PlayerData = null

# ===== BLINK STATE =====
var max_blinks: int = 1
var current_blinks: int = 1
var cooldown: float = 5.0
var blink_timer: float = 0.0

# ===== INITIALISE =====
func initialize(p: Player, player_data: PlayerData) -> void:
	player = p
	pd = player_data

	max_blinks    = int(pd.get_stat("blinks"))
	current_blinks = max_blinks
	cooldown      = pd.get_stat("blink_cooldown")
	blink_timer   = 0.0

func _ready() -> void:
	# A plain Node doesn't auto‑process in Godot 4
	set_process(true)

func _process(delta: float) -> void:
	_recharge(delta)

# ===== PUBLIC: TRY BLINK =====
# Returns TRUE if the blink happened, FALSE if out of charges
func try_blink(target_position: Vector2) -> bool:
	if current_blinks <= 0:
		return false

	current_blinks -= 1
	blink_timer = 0.0  # Reset recharge timer

	# ADDED: Calculate blink direction and rotate player
	var blink_direction = (target_position - player.global_position).normalized()
	if blink_direction.length() > 0.1:  # Avoid rotating for very small blinks
		player.rotation = blink_direction.angle()

	# Teleport + zero momentum
	player.global_position = target_position
	player.velocity = Vector2.ZERO

	emit_signal("player_blinked", target_position)
	return true

# ===== INTERNAL: RECHARGE =====
func _recharge(delta: float) -> void:
	if current_blinks >= max_blinks:
		return

	blink_timer += delta
	if blink_timer >= cooldown:
		current_blinks += 1
		blink_timer = 0.0
