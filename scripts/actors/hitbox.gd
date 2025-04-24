extends Area2D
class_name Hitbox

@export var tick_interval: float = 0.5
var tick_timer: float = 0.0
var overlapping_enemies: Array = []

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	collision_layer = 1 << 2  # Layer 3
	collision_mask = 1 << 1   # Detect Layer 2 (Enemies)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Enemies"):
		if not overlapping_enemies.has(body):
			overlapping_enemies.append(body)
			var player = get_parent()
			if player and player.has_method("take_damage"):
				if body.has_method("can_deal_damage") and body.can_deal_damage():
					player.take_damage(body.damage)
					body.reset_damage_timer()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Enemies"):
		overlapping_enemies.erase(body)
		print("Enemy left hitbox: ", body)

func _physics_process(delta: float):
	tick_timer += delta
	if tick_timer >= tick_interval:
		tick_timer = 0.0
		var player = get_parent()
		if player and player.has_method("receive_damage"):
			for enemy in overlapping_enemies:
				player.receive_damage(enemy.damage)
				print("Tick damage from:", enemy)
