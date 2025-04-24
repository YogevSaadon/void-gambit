extends Node2D
class_name FiringWeapon

@export var base_range: float = 300.0
@export var base_damage: float = 10.0
@export var base_fire_rate: float = 1.0
@export var base_crit: float = 0.0
@export var base_piercing: int = 0

var final_range: float = 0.0
var final_damage: float = 0.0
var final_fire_rate: float = 0.0
var final_crit: float = 0.0
var final_piercing: int = 0

var owner_player: Node = null
@export var bullet_scene: PackedScene = preload("res://scenes/bullets/Bullet.tscn")

var cooldown_timer: float = 0.0
var current_target: Node = null

func _physics_process(delta: float) -> void:
	current_target = find_target_in_range()
	if current_target:
		look_at(current_target.global_position)

	if cooldown_timer > 0:
		cooldown_timer -= delta

func auto_fire(delta: float) -> void:
	if current_target and cooldown_timer <= 0:
		fire_bullet(current_target)
		cooldown_timer = 1.0 / final_fire_rate

func fire_bullet(target: Node) -> void:
	var muzzle = $Muzzle
	if muzzle == null:
		push_error("Muzzle node not found in weapon!")
		return

	var bullet = bullet_scene.instantiate()
	bullet.position = muzzle.global_position
	bullet.damage = final_damage
	bullet.piercing = final_piercing
	bullet.direction = (target.global_position - muzzle.global_position).normalized()
	bullet.rotation = bullet.direction.angle()
	get_tree().current_scene.add_child(bullet)

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

func apply_weapon_modifiers(stats: Dictionary) -> void:
	final_range = base_range + stats.get("weapon_range", 0.0)
	final_crit = base_crit + stats.get("crit_chance", 0.0)
	final_piercing = base_piercing + stats.get("piercing", 0)

	var attack_speed = stats.get("attack_speed", 1.0)
	final_fire_rate = base_fire_rate * attack_speed

	var bonus_damage = stats.get("damage_percent", 0.0)
	final_damage = base_damage * (1.0 + bonus_damage)
