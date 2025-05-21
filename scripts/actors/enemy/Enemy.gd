# res://scripts/actors/Enemy.gd
extends "res://scripts/actors/Actor.gd"
class_name Enemy

@onready var status := $StatusComponent
@onready var pd     := get_tree().root.get_node("PlayerData")   # consistent singleton access

@export var damage: int          = 10
@export var damage_interval: float = 1.0
var _damage_timer: float         = 0.0

var active_damage_label: DamageNumber = null

func _ready() -> void:
	add_to_group("Enemies")
	collision_layer = 1 << 2        # Layer 2 = Enemy
	collision_mask  = 1 << 4        # Detect Bullets only (Layer 4)

	max_health = 200
	health     = 200
	speed      = 50

func _physics_process(delta: float) -> void:
	_damage_timer -= delta
	recharge_shield(delta)

	var player = get_target_player()
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

# ─── Targeting ─────────────────────────────────────
func get_target_player() -> Node:
	var players = get_tree().get_nodes_in_group("Player")
	return players[0] if players.size() > 0 else null

# ─── Contact damage timer ─────────────────────────
func can_deal_damage() -> bool:
	return _damage_timer <= 0.0

func reset_damage_timer() -> void:
	_damage_timer = damage_interval

# ─── Death hook (from Actor.gd) ───────────────────
func on_death() -> void:
	_spread_infection()
	# TODO: loot, effects, sounds …

# ─── Bio spread helper ────────────────────────────
func _spread_infection() -> void:
	if status.infection == null:
		return

	var radius    : float = pd.get_stat("weapon_range") * 0.4
	var best      : Node  = null
	var best_dist : float = radius

	for e in get_tree().get_nodes_in_group("Enemies"):
		if e == self:
			continue
		var d = global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best = e

	if best:
		best.get_node("StatusComponent").apply_infection(
			status.infection.dps,
			status.infection.remaining
		)

func apply_damage(amount: float, is_crit: bool) -> void:
	var dmg: float = amount * (pd.get_stat("crit_damage") if is_crit else 1.0)
	_show_damage_number(dmg, is_crit)
	take_damage(dmg)

func _show_damage_number(amount: float, is_crit: bool) -> void:
	if active_damage_label and is_instance_valid(active_damage_label):
		active_damage_label.add_damage(amount, is_crit)
	else:
		var dn := DamageNumber.new()
		active_damage_label = dn
		add_child(dn)  
		dn.position = Vector2(-40, -32)  # Relative to the enemy
		dn.add_damage(amount, is_crit)
		dn.connect("label_finished", Callable(self, "_on_label_finished"))


func _on_label_finished():
	active_damage_label = null
