extends Area2D

@export var tick_interval: float = 0.5

var overlapping_enemies: Array = []
var enemy_cooldowns: Dictionary = {}

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	collision_layer = 1 << 3  # Put hitbox on Layer 4 (for example)
	collision_mask = 1 << 2   # Detect enemies on Layer 2

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Enemies"):
		if not overlapping_enemies.has(body):
			overlapping_enemies.append(body)
			enemy_cooldowns[body] = 0.0

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Enemies"):
		overlapping_enemies.erase(body)
		enemy_cooldowns.erase(body)

func _physics_process(delta: float) -> void:
	var player = get_parent()
	if player == null or not player.has_method("receive_damage"):
		return

	for enemy in overlapping_enemies:
		if not enemy_cooldowns.has(enemy):
			enemy_cooldowns[enemy] = 0.0

		enemy_cooldowns[enemy] -= delta

		if enemy_cooldowns[enemy] <= 0.0:
			if enemy.has_method("can_deal_damage") and enemy.can_deal_damage():
				player.receive_damage(enemy.damage)
				enemy.reset_damage_timer()
				enemy_cooldowns[enemy] = tick_interval
