extends Node2D
class_name FiringWeapon

# --- Base Weapon Stats ---
@export var base_range: float = 300.0
@export var base_damage: float = 10.0
@export var base_fire_rate: float = 1.0   # Shots per second
@export var base_crit: float = 0.0          # Base crit is 0
@export var base_piercing: int = 0

# --- Final Stats (set by the Player when equipped) ---
var final_range: float = 300.0
var final_damage: float = 10.0
var final_fire_rate: float = 1.0
var final_crit: float = 0.0
var final_piercing: int = 0

# Reference to the owning player (set when equipped)
var owner_player: Player = null

# --- Bullet Scene (must be assigned via Inspector or preload) ---
@export var bullet_scene: PackedScene = preload("res://scenes/bullets/Bullet.tscn")

# Firing cooldown timer
var cooldown_timer: float = 0.0

# Persistent target, updated continuously
var current_target: Node = null

func _physics_process(delta):
	# Continuously update the current target based on this weapon's position and effective range.
	current_target = find_target_in_range()
	if current_target:
		# Always rotate the weapon to face the target.
		look_at(current_target.global_position)
	
	# Decrease cooldown (even if not firing).
	if cooldown_timer > 0:
		cooldown_timer -= delta

# This function is intended to be called by the player when the ship is stationary.
func auto_fire(delta: float) -> void:
	# Firing only happens if we have a valid target and the cooldown has expired.
	if current_target and cooldown_timer <= 0:
		fire_bullet(current_target)
		cooldown_timer = 1.0 / final_fire_rate

# Fires a bullet toward the given target.
func fire_bullet(target: Node) -> void:
	var muzzle = $Muzzle
	if muzzle == null:
		push_error("Muzzle node not found in weapon!")
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.position = muzzle.global_position
	bullet.damage = final_damage
	bullet.piercing = final_piercing
	# Calculate the bullet's direction from the muzzle toward the target.
	bullet.direction = (target.global_position - muzzle.global_position).normalized()
	# Set the bullet's rotation so its sprite faces the direction it's moving.
	bullet.rotation = bullet.direction.angle()
	
	get_tree().current_scene.add_child(bullet)

# Finds the closest enemy within the weapon's effective range using the weapon's own position.
func find_target_in_range() -> Node:
	var best_target = null
	var best_dist = final_range
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			best_target = enemy
	return best_target
