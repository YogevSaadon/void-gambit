# scripts/actors/enemys/enemy-scripts/MiniBiter.gd
extends BaseEnemy
class_name MiniBiter

func _enter_tree() -> void:
   enemy_type = "mini_biter"

   # ── Base stats at power-level 1 ─────
   max_health = EnemyConstants.MINI_BITER_BASE_HEALTH
   max_shield = 0
   speed = EnemyConstants.MINI_BITER_BASE_SPEED
   shield_recharge_rate = 0

   # Contact-damage numbers
   damage = EnemyConstants.MINI_BITER_BASE_DAMAGE
   damage_interval = EnemyConstants.MINI_BITER_DAMAGE_INTERVAL

   # ── FIXED: Disable velocity rotation for spinning ─────
   disable_velocity_rotation = true

   # Call parent's _enter_tree
   super._enter_tree()
