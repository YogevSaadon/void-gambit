extends Node2D
class_name BaseWeapon

# universal bases
@export var base_damage     : float = WeaponConstants.BASE_WEAPON_DAMAGE
@export var base_crit       : float = 0.0
@export var base_fire_rate  : float = WeaponConstants.BASE_WEAPON_FIRE_RATE

# runtime
var final_damage    : float = 0.0
var final_crit      : float = 0.0
var final_range     : float = 0.0
var final_fire_rate : float = 1.0

var owner_player : Player = null

# -------------- type‑specific damage key --------------
func _damage_type_key() -> String:
	return ""          # default: none; just global bonus

# -------------- fire rate scaling key --------------
func _fire_rate_stat_key() -> String:
	return ""          # default: no scaling, only bullets scale

func apply_weapon_modifiers(pd: PlayerData) -> void:
	final_damage    = base_damage
	final_crit      = base_crit      + pd.get_stat("crit_chance")
	final_range     = pd.get_stat("weapon_range")
	final_fire_rate = base_fire_rate  # Start with base

	# Apply global damage%
	var dmg_bonus = pd.get_stat("damage_percent")

	# Type‑specific damage bonus
	var damage_key = _damage_type_key()
	if damage_key != "":
		dmg_bonus += pd.get_stat(damage_key)

	final_damage *= (1.0 + dmg_bonus)

	# Type-specific fire rate scaling (only bullets)
	var fire_rate_key = _fire_rate_stat_key()
	if fire_rate_key != "":
		final_fire_rate *= pd.get_stat(fire_rate_key)

func auto_fire(_delta: float) -> void:
	push_warning("%s missed auto_fire()" % self)
