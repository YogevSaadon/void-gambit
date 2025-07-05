# scripts/weapons/spawner/UniversalShipSpawner.gd
extends BaseWeapon
class_name UniversalShipSpawner

# ===== WEAPON TYPE =====
enum WeaponType { BULLET, LASER, ROCKET, BIO }
@export var weapon_type: WeaponType = WeaponType.BULLET

# ===== SPAWNER CONFIGURATION =====
@export var mini_ship_scene: PackedScene = preload("res://scenes/weapons/spawners/MiniShip.tscn")
@export var ship_weapon_scene: PackedScene = preload("res://scenes/weapons/spawners/UniversalShipWeapon.tscn")
@export var spawn_interval: float = 2.0      # Time between ship spawns
@export var respawn_delay: float = 5.0       # Time to respawn dead ships

# ===== SHIP MANAGEMENT =====
var active_ships: Array[MiniShip] = []
var max_ships: int = 1                       # Will be set from player stats
var spawn_timer: float = 0.0
# owner_player already exists in BaseWeapon - don't redeclare

# ===== REFERENCES =====
@onready var player_data: PlayerData = get_tree().root.get_node("PlayerData")
# REMOVED: @onready var spawn_point: Node2D = $SpawnPoint  # ← FIXED: Removed unused spawn point reference

# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_spawner_visuals()

func _physics_process(delta: float) -> void:
	_update_spawner(delta)

# ===== WEAPON CONFIGURATION =====
func apply_weapon_modifiers(pd: PlayerData) -> void:
	"""Configure spawner based on player stats"""
	super.apply_weapon_modifiers(pd)
	
	# Get ship count from player stats
	max_ships = int(pd.get_stat("ship_count"))
	
	# Calculate final weapon stats for ships
	_calculate_ship_weapon_stats(pd)

func configure_spawner(type: WeaponType, player: Player) -> void:
	"""Set weapon type and player reference"""
	weapon_type = type
	owner_player = player
	_setup_spawner_visuals()

func _setup_spawner_visuals() -> void:
	"""Change spawner appearance based on weapon type"""
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return
	
	# Different colors for different spawner types
	match weapon_type:
		WeaponType.BULLET:
			sprite.modulate = Color(0.8, 0.6, 0.4, 1)  # Brown/orange
		WeaponType.LASER:
			sprite.modulate = Color(1, 0.4, 0.4, 1)    # Red
		WeaponType.ROCKET:
			sprite.modulate = Color(1, 1, 0.4, 1)      # Yellow
		WeaponType.BIO:
			sprite.modulate = Color(0.4, 0.8, 0.4, 1)  # Green

# ===== SHIP STAT CALCULATION =====
func _calculate_ship_weapon_stats(pd: PlayerData) -> Dictionary:
	"""Calculate weapon stats for spawned ships"""
	var base_damage = final_damage  # From BaseWeapon (includes global damage bonus)
	var fire_rate = final_fire_rate # From BaseWeapon (includes scaling if applicable)
	var crit_chance = final_crit
	
	# ===== FIXED FIRE RATE SCALING =====
	# Apply weapon-type specific fire rate scaling
	match weapon_type:
		WeaponType.BULLET:
			# Bullet ships get 50% of player's bullet attack speed bonus
			var bullet_bonus = pd.get_stat("bullet_attack_speed") - 1.0  # Get just the bonus part
			fire_rate *= (1.0 + bullet_bonus * 0.5)  # Apply 50% of the bonus
		# Laser/Rocket/Bio get no additional scaling (keep base fire_rate)
	
	# Add weapon-specific damage bonuses
	match weapon_type:
		WeaponType.BULLET:
			base_damage *= (1.0 + pd.get_stat("bullet_damage_percent"))
		WeaponType.LASER:
			base_damage *= (1.0 + pd.get_stat("laser_damage_percent"))
		WeaponType.ROCKET:
			base_damage *= (1.0 + pd.get_stat("explosive_damage_percent"))
		WeaponType.BIO:
			base_damage *= (1.0 + pd.get_stat("bio_damage_percent"))
	
	# Add ship-specific bonuses
	base_damage *= (1.0 + pd.get_stat("ship_damage_percent"))
	
	# Weapon-specific stats
	var weapon_stats = {
		"damage": base_damage,
		"fire_rate": fire_rate,
		"crit_chance": crit_chance,
		"weapon_range": pd.get_stat("weapon_range") * pd.get_stat("ship_range"),
		
		# Weapon-specific traits
		"bullet_speed": 1000.0 * pd.get_stat("bullet_attack_speed"),
		"laser_reflects": int(pd.get_stat("laser_reflects")),
		"explosion_radius": 64.0 * (1.0 + pd.get_stat("explosion_radius_bonus")),
		"bio_spread_chance": pd.get_stat("bio_spread_chance"),
	}
	
	return weapon_stats

# ===== SHIP SPAWNING & MANAGEMENT =====
func _update_spawner(delta: float) -> void:
	"""Main spawner update loop"""
	spawn_timer -= delta
	
	# Clean up dead ships
	_cleanup_dead_ships()
	
	# Spawn new ships if needed
	if active_ships.size() < max_ships and spawn_timer <= 0.0:
		_spawn_ship()
		spawn_timer = spawn_interval

func _cleanup_dead_ships() -> void:
	"""Remove dead ships from active list"""
	active_ships = active_ships.filter(func(ship): return is_instance_valid(ship))

func _spawn_ship() -> void:
	"""Spawn a new ship with configured weapon"""
	if not mini_ship_scene or not ship_weapon_scene:
		push_error("UniversalShipSpawner: Missing ship or weapon scene!")
		return
	
	# Create ship
	var ship = mini_ship_scene.instantiate()
	ship.set_owner_player(owner_player)
	
	# Create and configure weapon for ship
	var ship_weapon = ship_weapon_scene.instantiate()
	var weapon_stats = _calculate_ship_weapon_stats(player_data)
	
	ship_weapon.configure_weapon_with_type(
		weapon_stats.damage,
		weapon_stats.fire_rate,
		weapon_stats.crit_chance,
		weapon_type
	)
	
	# Attach weapon to ship
	ship.setup_weapon(ship_weapon)
	
	# ===== SPAWN AT SPAWNER CENTER (no spawn point needed) =====
	ship.global_position = global_position  # ← Simple and clean spawning
	
	# Add to scene and track
	get_tree().current_scene.add_child(ship)
	active_ships.append(ship)
	
	print("Spawned %s ship (%d/%d)" % [WeaponType.keys()[weapon_type], active_ships.size(), max_ships])

# ===== SPAWNER AUTO-FIRE (Required by BaseWeapon) =====
func auto_fire(_delta: float) -> void:
	"""Spawners don't fire projectiles, they manage ships"""
	# Ships handle their own auto-firing
	pass

# ===== WEAPON TYPE OVERRIDE =====
func _damage_type_key() -> String:
	"""Return damage type for this spawner weapon"""
	match weapon_type:
		WeaponType.BULLET: return "bullet_damage_percent"
		WeaponType.LASER: return "laser_damage_percent"
		WeaponType.ROCKET: return "explosive_damage_percent"
		WeaponType.BIO: return "bio_damage_percent"
		_: return ""

# ===== DEBUG INFO =====
func get_spawner_debug_info() -> Dictionary:
	"""Get debug information about spawner state"""
	return {
		"weapon_type": WeaponType.keys()[weapon_type],
		"active_ships": "%d/%d" % [active_ships.size(), max_ships],
		"spawn_timer": "%.1fs" % spawn_timer,
		"ship_weapon_stats": _calculate_ship_weapon_stats(player_data)
	}
