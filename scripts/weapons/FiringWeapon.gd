extends Node2D
class_name FiringWeapon

# ====== Exports ======
@export var base_range: float = 300.0
@export var base_damage: float = 10.0
@export var base_fire_rate: float = 1.0
@export var base_crit: float = 0.0
@export var base_piercing: int = 0
@export var bullet_scene: PackedScene = preload("res://scenes/bullets/Bullet.tscn")

# ====== Runtime Variables ======
var final_range: float = 0.0
var final_damage: float = 0.0
var final_fire_rate: float = 0.0
var final_crit: float = 0.0
var final_piercing: int = 0

var owner_player: Player = null
var cooldown_timer: float = 0.0
var current_target: Node = null

# ====== Built-in Methods ======
func _physics_process(delta: float) -> void:
	current_target = find_target_in_range()
	if current_target:
		look_at(current_target.global_position)

	if cooldown_timer > 0.0:
		cooldown_timer -= delta

func auto_fire(_delta: float) -> void:
	if current_target and cooldown_timer <= 0.0:
		fire_bullet(current_target)
		cooldown_timer = 1.0 / final_fire_rate

# ====== Bullet Firing ======
func fire_bullet(target: Node) -> void:
	var muzzle = $Muzzle
	if muzzle == null:
		push_error("FiringWeapon: Muzzle node not found!")
		return

	var bullet = bullet_scene.instantiate()
	bullet.position = muzzle.global_position
	bullet.damage = final_damage
	bullet.piercing = final_piercing
	bullet.direction = (target.global_position - muzzle.global_position).normalized()
	bullet.rotation = bullet.direction.angle()

	if bullet.has_method("set_collision_properties"):
		bullet.set_collision_properties()
	else:
		bullet.collision_layer = 1 << 4
		bullet.collision_mask = 1 << 2

	get_tree().current_scene.add_child(bullet)

# ====== Targeting ======
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

# ====== Weapon Modifiers ======
func apply_weapon_modifiers(player_stats: PlayerData) -> void:
	final_range = base_range + player_stats.get_stat("weapon_range")
	final_crit = base_crit + player_stats.get_stat("crit_chance")
	final_piercing = base_piercing + player_stats.get_stat("bullet_pierce")

	var attack_speed = player_stats.get_stat("attack_speed")
	final_fire_rate = base_fire_rate * attack_speed

	var damage_bonus = player_stats.get_stat("damage_percent") + player_stats.get_stat("bullet_damage_percent")
	final_damage = base_damage * (1.0 + damage_bonus)
