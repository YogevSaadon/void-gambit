extends "res://scripts/actors/Actor.gd"
class_name Player

# --- Player Stats ---
@export var crit_chance: float = 5.0      # Player's crit chance (in percent)
@export var luck: float = 1.0             # Affects item drop rate
@export var piercing: int = 0             # Additional piercing from player
@export var range_bonus: float = 0.2      # e.g., +20% range bonus
@export var damage_multiplier: float = 0.1
@export var fire_rate_multiplier: float = 1.0

# --- Movement ---
var target_position: Vector2

# --- Weapon Slots (assume 4 for now) ---
var weapon_slots: Array[Node] = []

# --- Blink/Teleport ---
@export var blink_cooldown: float = 5.0   # 5 seconds
var blink_timer: float = blink_cooldown   # start available

# --- Damge Taking Timer---
var is_invulnerable: bool = false
@export var invuln_duration: float = 0.5  # seconds of invulnerability
var invuln_timer: float = 0.0

func _ready():
	add_to_group("Player")
	# Initialize weapon slot nodes (adjust names if needed)
	weapon_slots = [
		$WeaponSlots/Weapon1,
		$WeaponSlots/Weapon2,
		$WeaponSlots/Weapon3,
		$WeaponSlots/Weapon4
	]
	
	# Set player-specific stats (these are inherited from Actor.gd)
	health = 30
	max_health = 30
	shield = 0
	max_shield = 0 
	shield_recharge_rate = 0.0
	speed = 200.0

	target_position = global_position  # Start at current position

	# Equip a default weapon into slot 0 (for testing)
	var default_weapon_scene = preload("res://scenes/weapons/FiringWeapon.tscn")
	equip_weapon(default_weapon_scene, 0)

func _input(event):
	# Right-click to move the player
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		target_position = get_global_mouse_position()
	
	# F key to blink (teleport)\S key to manually stop movement
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F:
			if blink_timer >= blink_cooldown:
				blink_to_position(get_global_mouse_position())
				blink_timer = 0.0
		if event.keycode == KEY_S:
			stop()

func _physics_process(delta):
	# Update blink timer
	if blink_timer < blink_cooldown:
		blink_timer += delta
	 # Update invulnerability timer.
	if is_invulnerable:
		invuln_timer -= delta
		if invuln_timer <= 0:
			is_invulnerable = false


	# Move toward the target position
	if global_position.distance_to(target_position) > 3:
		var direction = (target_position - global_position).normalized()
		move(direction, delta)
	else:
		velocity = Vector2.ZERO

	# --- Kiter Mechanic ---
	# If the player is standing still (velocity nearly zero), fire equipped weapons.
	if velocity.length() < 1.0:
		for slot in weapon_slots:
			for weapon in slot.get_children():
				if weapon.has_method("auto_fire"):
					weapon.auto_fire(delta)

func blink_to_position(target_pos: Vector2):
	global_position = target_pos
	target_position = target_pos
	velocity = Vector2.ZERO

func stop():
	target_position = global_position
	velocity = Vector2.ZERO

func receive_damage(amount: int) -> void:
	if is_invulnerable:
		return
	take_damage(amount)
	is_invulnerable = true
	invuln_timer = invuln_duration

# Equip a weapon into a given slot and set its final stats based on player's bonuses.
func equip_weapon(weapon_scene: PackedScene, slot_index: int) -> void:
	if slot_index < 0 or slot_index >= weapon_slots.size():
		push_error("Invalid weapon slot index: %d" % slot_index)
		return

	# Clear any existing weapon in that slot.
	for child in weapon_slots[slot_index].get_children():
		child.queue_free()

	# Instance and add the new weapon.
	var weapon_instance = weapon_scene.instantiate()
	weapon_slots[slot_index].add_child(weapon_instance)
	weapon_instance.owner_player = self  # Let the weapon access player stats.

	# Apply player modifiers to the weapon's base stats.
	var final_stats = apply_weapon_modifiers(
		weapon_instance.base_range,
		weapon_instance.base_damage,
		weapon_instance.base_fire_rate,
		weapon_instance.base_crit,         # Typically 0 so final becomes player's crit chance.
		weapon_instance.base_piercing
	)
	
	# Set the final stats on the weapon.
	weapon_instance.final_range = final_stats.range
	weapon_instance.final_damage = final_stats.damage
	weapon_instance.final_fire_rate = final_stats.fire_rate
	weapon_instance.final_crit = final_stats.crit
	weapon_instance.final_piercing = final_stats.piercing

# Combines a weapon's base stats with the player's modifiers.
func apply_weapon_modifiers(
	base_range: float, base_damage: float, base_fire_rate: float, base_crit: float, base_piercing: int
) -> Dictionary:
	var final_stats = {}
	final_stats.range = base_range * (1.0 + range_bonus)
	final_stats.damage = base_damage * damage_multiplier
	final_stats.fire_rate = base_fire_rate * fire_rate_multiplier
	final_stats.crit = base_crit + crit_chance  # base_crit assumed to be 0.
	final_stats.piercing = base_piercing + piercing
	return final_stats
