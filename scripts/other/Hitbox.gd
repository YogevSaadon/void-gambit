extends Area2D
class_name Hitbox

@export var tick_interval: float = 0.5  # Set this to match the player's invulnerability duration
var tick_timer: float = 0.0

# Array to track overlapping enemy bodies.
var overlapping_enemies: Array = []

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	collision_layer = 1 << 2  # Hitbox on layer 3
	collision_mask = 1 << 1   # Detect collisions on layer 2

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Enemies"):
		# Only add if not already in the array.
		if not overlapping_enemies.has(body):
			overlapping_enemies.append(body)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Enemies"):
		overlapping_enemies.erase(body)

func _physics_process(delta):
	tick_timer += delta
	if tick_timer >= tick_interval:
		tick_timer = 0.0
		var player = get_parent()  # Assuming the hitbox is a child of the Player.
		if player and player.has_method("receive_damage"):
			for enemy in overlapping_enemies:
				player.receive_damage(enemy.damage)
