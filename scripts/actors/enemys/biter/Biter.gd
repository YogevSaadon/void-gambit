#  /scripts/actors/enemys/biter/Biter.gd
extends BaseEnemy
class_name Biter

const MOVE := preload("res://scripts/actors/enemys/movment/ChaseMovement..gd")
const ATK  := preload("res://scripts/actors/enemys/biter/TouchDamage.gd")

# ------------------------------------------------------------------
func _enter_tree() -> void:
	# --- 1.  Per-enemy base stats (power-level = 1 values) ----------
	max_health           = 20
	max_shield           = 0
	speed                = 150
	shield_recharge_rate = 0          # none

	# --- 2.  Metadata & plug-ins -----------------------------------
	power_level     = 1               # will be multiplied later if needed
	rarity          = "common"
	movement_script = MOVE
	attack_script   = ATK

	# --- 3.  Collision identical to old enemies --------------------
	collision_layer = 1 << 2                        # layer 2 “Enemies”
	collision_mask  = (1 << 1) | (1 << 4)           # collide player + bullets
	if has_node("DamageZone"):
		$DamageZone.collision_layer = 1 << 2
		$DamageZone.collision_mask  = 1 << 1        # only player

	# --- 4.  Hand control back to BaseEnemy ------------------------
	super._enter_tree()
