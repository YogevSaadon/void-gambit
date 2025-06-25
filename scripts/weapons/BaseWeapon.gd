extends Node2D
class_name BaseWeapon

# universal bases
@export var base_damage     : float = 10.0
@export var base_crit       : float = 0.0
# ← REMOVED: base_range (now only use player range)

# runtime
var final_damage    : float = 0.0
var final_crit      : float = 0.0
var final_range     : float = 0.0

var owner_player : Player = null

# -------------- new: type‑specific key --------------
# subclasses override this with e.g. "bullet_damage_percent",
# "laser_damage_percent", etc.
func _damage_type_key() -> String:
	return ""          # default: none; just global bonus
# ---------------------------------------------------

func apply_weapon_modifiers(pd: PlayerData) -> void:
	final_damage    = base_damage
	final_crit      = base_crit      + pd.get_stat("crit_chance")
	final_range     = pd.get_stat("weapon_range")  # ← SIMPLIFIED: Only player range

	# apply global damage%
	var dmg_bonus = pd.get_stat("damage_percent")

	# type‑specific bonus if defined
	var key = _damage_type_key()
	if key != "":
		dmg_bonus += pd.get_stat(key)

	final_damage *= (1.0 + dmg_bonus)

func auto_fire(_delta: float) -> void:
	push_warning("%s missed auto_fire()" % self)
