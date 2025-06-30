extends ShooterWeapon
class_name RocketWeapon

@onready var pd: PlayerData = get_tree().root.get_node("PlayerData")

@export var missile_scene: PackedScene = preload("res://scenes/projectiles/player_projectiles/PlayerMissile.tscn")
@export var base_expl_damage: float = 60.0
@export var base_radius: float = 64.0
# inherited base_fire_rate set in Inspector (e.g. 0.7)

func _damage_type_key() -> String:
	return "explosive_damage_percent"

# ─── Stat application ─────────────────────────────────
func apply_weapon_modifiers(player_data: PlayerData) -> void:
	super.apply_weapon_modifiers(player_data)
	# Fire rate fixed for rockets
	final_fire_rate = base_fire_rate

func _fire_once(target: Node) -> void:
	if missile_scene == null or not is_instance_valid(target):
		return

	var missile: Area2D = missile_scene.instantiate()
	missile.global_position = $Muzzle.global_position
	missile.target_position = target.global_position

	var dmg: float = base_expl_damage * (1.0 + pd.get_stat("damage_percent")
											   + pd.get_stat("explosive_damage_percent"))
	var rad: float = base_radius * (1.0 + pd.get_stat("explosion_radius_bonus"))

	missile.damage = dmg
	missile.radius = rad
	missile.crit_chance = pd.get_stat("crit_chance")

	get_tree().current_scene.add_child(missile)
