extends "res://scripts/actors/Actor.gd"
class_name Enemy

@onready var status := $StatusComponent
@onready var pd     := get_tree().root.get_node("PlayerData")
@onready var credit_scene := preload("res://scenes/drops/CreditDrop.tscn")

@export var damage: int = 10
@export var damage_interval: float = 1.0
var _damage_timer: float = 0.0

var active_damage_label: DamageNumber = null

func _ready() -> void:
	add_to_group("Enemies")
	collision_layer = 1 << 2
	collision_mask  = 1 << 4
	max_health = 20
	health     = 20
	speed      = 150

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

func get_target_player() -> Node:
	var players = get_tree().get_nodes_in_group("Player")
	return players[0] if players.size() > 0 else null

func can_deal_damage() -> bool:
	return _damage_timer <= 0.0

func reset_damage_timer() -> void:
	_damage_timer = damage_interval

func apply_damage(amount: float, is_crit: bool) -> void:
	var dmg = amount * (pd.get_stat("crit_damage") if is_crit else 1.0)
	_show_damage_number(dmg, is_crit)
	take_damage(dmg)

func _show_damage_number(amount: float, is_crit: bool) -> void:
	if active_damage_label and is_instance_valid(active_damage_label):
		if active_damage_label.is_detached:
			active_damage_label = null
		else:
			active_damage_label.add_damage(amount, is_crit)
			return

	var dn := DamageNumber.new()
	active_damage_label = dn
	add_child(dn)
	dn.position = Vector2(-40, -32)
	dn.add_damage(amount, is_crit)
	dn.connect("label_finished", Callable(self, "_on_label_finished"))

func _on_label_finished() -> void:
	active_damage_label = null

func on_death() -> void:
	if active_damage_label and is_instance_valid(active_damage_label):
		active_damage_label.detach()

	_spread_infection()
	drop_credit()
	queue_free()

func _spread_infection() -> void:
	if status.infection == null:
		return

	var radius = pd.get_stat("weapon_range") * 0.4
	var best: Node = null
	var best_dist = radius

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

func drop_credit() -> void:
	var credit := credit_scene.instantiate()
	credit.global_position = global_position
	credit.value = 1  # TODO: Replace with power-level based value
	get_tree().current_scene.add_child(credit)
