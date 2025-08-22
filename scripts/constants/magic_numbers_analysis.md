# Magic Numbers Analysis

This file contains a comprehensive analysis of all magic numbers found in the codebase that should be extracted to constant files.

<!-- # COMPLETE MAGIC NUMBERS CATALOG
## Organized by Category for Constant Extraction

---

## 1. COLLISION & PHYSICS CONSTANTS

### Collision Layers
**Location:** Multiple files use raw bit shifts instead of CollisionLayers constants
- `scripts/projectiles/BaseBullet.gd:18-19`: `collision_layer = 1 << 4`, `collision_mask = 1 << 2`
- `scripts/projectiles/BaseExplosion.gd:9-10`: Uses `CollisionLayers.LAYER_*` (GOOD - already using constants)
- `scripts/weapons/laser/ChainLaserBeamController.gd:157,173,284`: Uses `CollisionLayers.get_enemy_layer()` (GOOD)

### Physics Query Limits
- `scripts/actors/enemys/base-enemy/BaseEnemy.gd:277`: `intersect_shape(params, 32)` - max query results
- `scripts/weapons/ShooterWeapon.gd:42`: `intersect_shape(params, 32)` - max query results  
- `scripts/weapons/laser/ChainLaserBeamController.gd:157`: `intersect_shape(params, 32)`
- `scripts/weapons/spawners/TargetSelector.gd:102`: `intersect_shape(params, 32)`
- `scripts/weapons/spawners/UniversalShipWeapon.gd:334`: `intersect_shape(params, 5)` - bio spread max targets

---

## 2. COMBAT & DAMAGE CONSTANTS

### Base Damage Values
- `scripts/actors/enemys/attacks/ConeAttack.gd:6`: `base_damage = 15.0`
- `scripts/actors/enemys/attacks/StarAttack.gd:3`: `base_damage = 25.0`
- `scripts/actors/enemys/attacks/TriangleAttack.gd:5`: `base_damage = 15.0`
- `scripts/actors/enemys/attacks/TripleShotAttack.gd:4`: `base_damage = 10.0`
- `scripts/weapons/BaseWeapon.gd:4`: `base_damage = 20.0`
- `scripts/weapons/BioWeapon.gd:6`: `base_dps = round(base_damage / 3.0)` - 7.0
- `scripts/weapons/RocketWeapon.gd:7`: `base_expl_damage = round(base_damage * 1.5)` - 30.0
- `scripts/weapons/laser/LaserWeapon.gd:4`: `laser_damage = round(base_damage * 0.05)` - 1.0

### Damage Multipliers
- `scripts/actors/enemys/base-enemy/StatusComponent.gd:22`: `0.33` - infection stack damage increase
- `scripts/weapons/spawners/UniversalShipSpawner.gd:109`: `0.33` - ship weapon damage reduction
- `scripts/weapons/BioWeapon.gd:6`: `/3.0` - bio DPS divisor
- `scripts/weapons/RocketWeapon.gd:7`: `*1.5` - explosion damage multiplier
- `scripts/weapons/laser/LaserWeapon.gd:4`: `*0.05` - laser tick damage multiplier
- `scripts/weapons/spawners/UniversalShipWeapon.gd:302`: `/10.0` - bio burst to DPS conversion
- `scripts/weapons/spawners/UniversalShipWeapon.gd:340`: `*0.5` and `*0.8` - bio spread damage/duration reduction

### Critical Hit Values
- `scripts/actors/player/PlayerData.gd:11`: `crit_chance: 0.05` - 5% base
- `scripts/actors/player/PlayerData.gd:12`: `crit_damage: 1.5` - 1.5x multiplier

### Armor Calculation
- `scripts/actors/player/Player.gd:104`: `armor / (armor + 100.0)` - armor damage reduction formula

### Invulnerability
- `scripts/actors/player/Player.gd:21`: `INVULN_TIME = 0.3` - i-frames duration

### Death Delays
- `scripts/actors/player/Player.gd:145`: `timer.wait_time = 0.2` - death to menu delay

---

## 3. ENEMY STATS & BEHAVIOR

### Enemy Base Stats
**Biter** (`scripts/actors/enemys/enemy-scripts/Biter.gd`):
- `max_health = 20`, `speed = 120`, `damage = 12`, `damage_interval = 0.8`

**MiniBiter** (`scripts/actors/enemys/enemy-scripts/MiniBiter.gd`):
- `max_health = 8`, `speed = 130`, `damage = 6`, `damage_interval = 0.7`

**Triangle** (`scripts/actors/enemys/enemy-scripts/Triangle.gd`):
- `max_health = 40`, `speed = 100`, `damage = 15`, `damage_interval = 1.0`

**Rectangle** (`scripts/actors/enemys/enemy-scripts/Rectangle.gd`):
- `max_health = 60`, `speed = 90`, `damage = 15`, `damage_interval = 1.0`

**Tank** (`scripts/actors/enemys/enemy-scripts/Tank.gd`):
- `max_health = 80`, `speed = 85`, `damage = 20`, `damage_interval = 0.6`

**Star** (`scripts/actors/enemys/enemy-scripts/Star.gd`):
- `max_health = 200`, `speed = 80`, `damage = 25`, `damage_interval = 1.5`

**Diamond** (`scripts/actors/enemys/enemy-scripts/Diamond.gd`):
- `max_health = 250`, `speed = 70`, `damage = 30`, `damage_interval = 2.0`

**MotherShip** (`scripts/actors/enemys/enemy-scripts/MotherShip.gd`):
- `max_health = 400`, `speed = 45`, `damage = 40`, `damage_interval = 2.5`

**ChildShip** (`scripts/actors/enemys/enemy-scripts/ChildShip.gd`):
- `max_health = 35`, `speed = 130`, `damage = 15`, `damage_interval = 1.0`

**GoldShip** (`scripts/actors/enemys/enemy-scripts/GoldShip.gd`):
- `max_health = 40`, `speed = 90`, `damage = 20`, `damage_interval = 1.0`

**EnemyMissile** (`scripts/actors/enemys/enemy-scripts/EnemyMissle.gd`):
- `max_health = 30`, `speed = 200`, `explosion_damage = 40.0`, `explosion_radius = 80.0`

### Enemy Attack Ranges
- `scripts/actors/enemys/attacks/ConeAttack.gd:7`: `shooting_range = 500.0`
- `scripts/actors/enemys/attacks/StarAttack.gd:4`: `shooting_range = 5000.0`
- `scripts/actors/enemys/attacks/TriangleAttack.gd:6`: `shooting_range = 400.0`
- `scripts/actors/enemys/attacks/TripleShotAttack.gd:5`: `shooting_range = 350.0`
- `scripts/actors/enemys/attacks/MissileLauncherAttack.gd:3`: `shooting_range = 1000.0`
- `scripts/actors/enemys/attacks/ChildShipSpawner.gd:3`: `shooting_range = 5000.0`

### Enemy Attack Intervals
- `scripts/actors/enemys/attacks/ConeAttack.gd:8`: `fire_interval = 3.0`
- `scripts/actors/enemys/attacks/StarAttack.gd:5`: `fire_interval = 6.0`
- `scripts/actors/enemys/attacks/TriangleAttack.gd:7`: `fire_interval = 3.0`
- `scripts/actors/enemys/attacks/TripleShotAttack.gd:6`: `burst_interval = 3.0`
- `scripts/actors/enemys/attacks/MissileLauncherAttack.gd:4`: `fire_interval = 5.0`
- `scripts/actors/enemys/attacks/ChildShipSpawner.gd:4`: `spawn_interval = 6.0`

### Enemy Special Attack Properties
- `scripts/actors/enemys/attacks/ConeAttack.gd:9`: `cone_angle = 45.0` degrees
- `scripts/actors/enemys/attacks/StarAttack.gd:6`: `bullet_count = 16`
- `scripts/actors/enemys/attacks/TripleShotAttack.gd:7-9`: `shots_per_burst = 3`, `shot_delay = 0.15`, `spread_angle = 15.0`
- `scripts/actors/enemys/attacks/ChildShipSpawner.gd:6`: `spawn_offset_distance = 50.0`
- `scripts/actors/enemys/attacks/BaseEntitySpawner.gd:8`: `max_entities_per_spawner = 6`
- `scripts/actors/enemys/attacks/BaseEntitySpawner.gd:9`: `cleanup_interval = 1.0`

---

## 4. MOVEMENT CONSTANTS

### Player Movement
**PlayerMovement.gd:**
- Line 5: `accel_time = 0.25` - acceleration time
- Line 6: `decel_time = 0.30` - deceleration time  
- Line 7: `arrival_threshold = 8.0` - arrival distance
- Line 8: `movement_smoothing = 12.0` - lerp factor
- Line 9: `slowdown_distance = 40.0` - slowdown start distance
- Line 11: `rotation_speed = 8.0`
- Line 12: `min_velocity_for_rotation = 30.0`
- Line 135: `distance < 2.0` - snap threshold
- Line 162: `velocity.length() < 10.0` - stop threshold

### Enemy Movement Ranges
**BaseRangeKeepingMovement.gd:**
- Line 6-9: `inner_range = 250.0`, `outer_range = 300.0`, `chase_range = 400.0`, `master_interval = 3.0`
- Line 10-12: `retreat_reaction_min = 2.0`, `retreat_reaction_max = 5.0`
- Line 13-14: `position_update_min = 1.0`, `position_update_max = 5.0`
- Line 17-20: Behavior values: `strafe_intensity = 1.0`, `back_away_speed = 1.0`, etc.
- Line 23-27: Action chances: `0.33`, `0.5`, `0.15`
- Line 28-29: Stop/acceleration durations: `0.8`, `1.2`
- Line 32: `zone_hysteresis = 0.2` - 20% buffer

**Enemy-Specific Movement Configs:**
- Triangle: Uses base values (250/300/400)
- Rectangle: Same ranges, `master_interval = 4.0`
- ChildShip: 220/280/420 ranges, `master_interval = 2.0`
- Diamond: 400/450/500 ranges, `master_interval = 6.0`
- Star: 600/620/800 ranges, `master_interval = 12.0`
- MotherShip: 910/975/1040 ranges, `master_interval = 10.0`
- GoldShip: 1000/1200/1200 ranges, `master_interval = 5.0`

### Charge Movement (Tank)
**ChargeMovement.gd:**
- Line 6-10: `charge_range = 250.0`, `charge_distance_multiplier = 4.0`, `charge_acceleration = 800.0`, `max_charge_speed = 400.0`, `charge_cooldown = 0.8`
- Line 69: `distance_to_target < 20.0` - arrival threshold

### Sawblade Movement
**SawbladeMovement.gd:**
- Line 7-10: `cloud_size = 1.0`, `cloud_tightness = 1.0`, `orbit_radius = 15.0`, `orbit_switch_chance = 0.02`
- Line 13-16: Spin speeds: `base_spin_speed = 3.0`, `speed_spin_multiplier = 0.003`, etc.
- Line 31-34: Base distances: `35.0`, `30.0`, PI values
- Line 37-38: Check intervals: `0.5`, `0.05`

### Missile Movement
**EnemyMissileMovement.gd:**
- Line 6-9: `turn_speed = 8.0`, `acceleration = 300.0`, `max_speed_multiplier = 2.5`, `update_interval = 0.05`
- Line 20: Start speed: `enemy.speed * 0.4`

---

## 5. WEAPON CONSTANTS

### Fire Rates & Cooldowns
- `scripts/weapons/BaseWeapon.gd:6`: `base_fire_rate = 1.0`
- `scripts/weapons/RocketWeapon.gd`: Rocket fire rate: `0.7` (in inspector)
- `scripts/weapons/spawners/UniversalShipSpawner.gd:9`: `spawn_interval = 0.3`

### Projectile Speeds
- `scripts/projectiles/BaseBullet.gd:5`: `speed = 1000.0` - base bullet
- `scripts/projectiles/enemy_projectiles/EnemyBullet.gd:8`: `speed = 400.0` - enemy bullets
- `scripts/projectiles/player_projectiles/PlayerBullet.gd:7`: `speed = 1800.0` - player bullets
- `scripts/projectiles/player_projectiles/PlayerMissile.gd:5`: `speed = 450.0` - missiles
- `scripts/weapons/spawners/UniversalShipWeapon.gd:18`: `bullet_speed = 1800.0`

### Projectile Lifetimes
- `scripts/projectiles/BaseBullet.gd:6`: `max_lifetime = 2.0` seconds
- `scripts/projectiles/enemy_projectiles/EnemyBullet.gd:9`: `max_lifetime = 3.0`
- `scripts/projectiles/player_projectiles/PlayerBullet.gd:8`: `max_lifetime = 2.0`

### Weapon Ranges
- `scripts/actors/player/PlayerData.gd:10`: `weapon_range: 300.0` - base range
- `scripts/weapons/FiringWeapon.gd:5`: `base_range = 300.0`

### Explosion Properties
- `scripts/projectiles/BaseExplosion.gd:8`: `radius = 64.0`
- `scripts/projectiles/BaseExplosion.gd:13`: `fade_duration = 0.15`
- `scripts/projectiles/player_projectiles/PlayerMissile.gd:8`: `radius = 64.0`
- `scripts/weapons/RocketWeapon.gd:8`: `base_radius = 64.0`
- `scripts/weapons/spawners/UniversalShipWeapon.gd:19`: `rocket_explosion_radius = 64.0`

### Laser Properties
- `scripts/weapons/laser/ChainLaserBeamController.gd:11-12`: `tick_time = 0.05`, `validation_interval = 0.1`
- `scripts/weapons/laser/LaserWeapon.gd:4`: Laser damage multiplier: `0.05`

### Bio Weapon Properties
- `scripts/weapons/BioWeapon.gd:7`: `base_duration = 3.0`
- `scripts/weapons/spawners/UniversalShipWeapon.gd:20-21`: `bio_dps = 15.0`, `bio_duration = 3.0`

---

## 6. UI & VISUAL CONSTANTS

### Damage Numbers
**DamageNumber.gd:**
- Line 7-10: `HOLD_TIME = 0.08`, `FADE_TIME = 0.40`, `FLOAT_SPEED = 30.0`, `COUNT_SPEED = 60.0`

### Visual Effects
- `scripts/other/ExplosionEffect.gd:4-12`: Various particle parameters
- `scripts/projectiles/BaseExplosion.gd:14`: `initial_color = Color(1, 1, 1, 0.8)`
- `scripts/projectiles/enemy_projectiles/EnemyExplosion.gd:10`: `Color(1, 0.3, 0.1, 0.8)` - red/orange

### Flash/Tween Timings
- `scripts/actors/enemys/attacks/ConeAttack.gd:142-143`: Flash: `0.05`, `0.10`
- `scripts/actors/enemys/attacks/StarAttack.gd:79-80`: Flash: `0.05`, `0.10`
- `scripts/actors/enemys/attacks/TripleShotAttack.gd:106-107`: Flash: `0.03`, `0.06`
- `scripts/actors/enemys/attacks/MissileLauncherAttack.gd:90-91`: Flash: `0.1`, `0.2`
- `scripts/actors/enemys/attacks/ChildShipSpawner.gd:107-108`: Flash: `0.15`, `0.3`
- `scripts/actors/player/Player.gd:177-178`: Invuln flash: `0.05`, `0.05`

---

## 7. DROP & ECONOMY CONSTANTS

### Drop Values & Behavior
**DropPickup.gd:**
- Line 9-15: Pickup constants: `PICKUP_RADIUS = 120.0`, `PICKUP_THRESHOLD = 15.0`, speeds: `200.0`, `2000.0`
- Line 13-15: Acceleration: `ACCELERATION_POWER = 3.0`, `DISTANCE_POWER = 2.5`, `PLAYER_SPEED_MULTIPLIER = 1.5`
- Line 82: Lerp speed: `8.0 * delta`

**DropHandler.gd:**
- Line 4: `drop_value_multiplier = 4.0` - credit value multiplier

---

## 8. SPAWNING & WAVE CONSTANTS

### Wave Management
**WaveManager.gd:**
- Line 10-13: `spawn_batch_interval = 1.0`, `enemy_spawn_interval = 0.05`, `level_duration = 60.0`, `max_enemies_alive = 250`
- Line 46: Fixed duration: `35.0` seconds
- Line 54: Initial batch timer: `0.1`
- Line 60: Golden ship initial timer: `1.0`
- Line 63: Golden ship timing: `level_duration * 0.5`

### Power Budget
**PowerBudgetCalculator.gd:**
- Line 12-14: Base budget: `10`, scaling: `0.1` per level (10%)
- Line 24-29: Tier breakpoints: levels 6, 12, 18, 24
- Line 24-29: Tier multipliers: 1, 2, 3, 4, 5
- Line 62-66: Wave duration: `30.0` to `60.0` seconds
- Line 79: Usable time: `0.9` (90% buffer)
- Line 82: Min spawn interval: `0.1`

**PowerBudgetSpawner.gd:**
- Line 20-21: `budget_tolerance = 1.2` (20% overspend), `prefer_variety = true`
- Line 51: `max_attempts = 1000`
- Line 163: Overspend threshold: `0.3` (30% remaining)

### Enemy Pool
**SimpleEnemySpawner.gd:**
- Spawns `level` copies of each available enemy type

### Level Spawn Settings
**Level.gd:**
- Line 9-12: `DISTANCE_VARIANCE = 100.0`, `SPAWN_MARGIN = 64.0`

---

## 9. STATUS EFFECT CONSTANTS

### Infection/Bio
**StatusComponent.gd:**
- Line 22: Stack damage increase: `0.33` (33%)
- Line 23: Max stacks: `3`
- Line 17: `tick_interval = 0.5` seconds

---

## 10. PERFORMANCE CONSTANTS

### Timer Intervals
- `scripts/actors/enemys/attacks/ConeAttack.gd:30`: `RANGE_CHECK_INTERVAL = 0.2`
- `scripts/actors/enemys/movment/BaseChaseMovement.gd:18`: `DISTANCE_CHECK_INTERVAL = 0.1`
- `scripts/actors/enemys/movment/BaseRangeKeepingMovement.gd:57`: `MODE_CHECK_INTERVAL = 0.1`
- `scripts/weapons/spawners/TargetSelector.gd:16`: `SEARCH_INTERVAL = 0.2`

### Spatial Query Limits
- Most queries: `32` max results
- Bio spread: `5` max targets

---

## 11. PLAYER BASE STATS

**PlayerData.gd base_stats:**
```gdscript
"max_hp": 50,
"max_shield": 10,
"speed": 150.0,
"shield_recharge_rate": 0.0,
"weapon_range": 300.0,
"crit_chance": 0.05,
"crit_damage": 1.5,
"damage_percent": 0.0,
"bullet_damage_percent": 0.0,
"laser_damage_percent": 0.0,
"explosive_damage_percent": 0.0,
"bio_damage_percent": 0.0,
"ship_damage_percent": 0.0,
"blink_cooldown": 8.0,
"blinks": 1,
"rerolls_per_wave": 1,
"luck": 0.0,
"gold_drop_rate": 1.0,
"ship_count": 1,
"ship_range": 300.0,
"bullet_attack_speed": 1.0,
"laser_reflects": 0,
"bio_spread_chance": 0.0,
"explosion_radius_bonus": 0.0,
"golden_ship_count": 1,
"armor": 0.0
```

---

## 12. RARITY & LOOT CONSTANTS

### Slot Machine Logic
**SlotMachineLogic.gd:**
- Line 28-29: `SCALING_CONSTANT = 50.0`, `MAX_COMMON_REDUCTION = 0.5`
- Line 32-38: Base weights: 60%, 25%, 10%, 4%, 1%
- Line 41-46: Redistribution: 40%, 30%, 20%, 10%

### Store Rarity System
**StoreLevelRarityLogic.gd:**
- Line 33-59: Complete level rarity table (1-25)
- Line 70-75: Pity thresholds: 8, 12, 15, 20 visits

---

## 13. SHIP SPAWNER CONSTANTS

### Mini Ship Movement
**MiniShipMovement.gd:**
- Line 10-13: Ranges: `600.0`, `350.0`, `250.0`, `350.0`
- Line 15-17: Speeds: `300.0`, `150.0`, `180.0`
- Line 20-22: Follow player: `0.8` responsiveness, `500.0` max speed
- Line 30: Velocity smoothing: `5.0`
- Line 57-59: Smoothing constants: `400.0`, `4.0`, `3.0`

### Target Selection
**TargetSelector.gd:**
- Line 6-8: `target_search_range = 350.0`, `target_switch_interval = 2.0`, `target_switch_variance = 1.0`

### Ship Weapon Stats
**UniversalShipSpawner.gd:**
- Line 109: Ship damage reduction: `0.33` (33%)
- Line 143-148: Ship gets 50% of player weapon bonuses

---

## PRIORITY REFACTORING TARGETS

### CRITICAL (Used everywhere):
1. Damage multipliers (0.33, 1.5, 0.05)
2. Physics query limit (32)
3. Timer intervals (0.1, 0.2)
4. Base weapon stats (damage, fire rate, range)

### HIGH (Combat balance):
1. Enemy base stats (health, speed, damage)
2. Attack ranges and intervals
3. Critical hit values
4. Projectile speeds and lifetimes

### MEDIUM (Visual/UX):
1. UI timing constants
2. Flash/tween durations
3. Color values
4. Particle parameters

### LOW (Rarely changed):
1. Spawn margins and variance
2. Pity system thresholds
3. Smoothing factors

---

## SUGGESTED CONSTANT FILES MAPPING

1. **CombatConstants.gd**: All damage, crit, armor values
2. **MovementConstants.gd**: All movement speeds, ranges, accelerations
3. **WeaponConstants.gd**: Fire rates, projectile speeds, ranges
4. **EnemyConstants.gd**: Base stats for all enemy types
5. **UIConstants.gd**: Damage numbers, flash timings, colors
6. **DropConstants.gd**: Pickup ranges, magnetism values
7. **SpawningConstants.gd**: Wave timings, power budgets, spawn intervals
8. **StatusConstants.gd**: DoT intervals, stack limits
9. **PerformanceConstants.gd**: Timer intervals, query limits
10. **balance_config.json**: Easily tweakable multipliers -->
