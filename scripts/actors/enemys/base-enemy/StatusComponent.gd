# /scripts/enemies/base_enemy/StatusComponent.gd
extends Node
class_name StatusComponent

@onready var pd: PlayerData = get_tree().root.get_node("PlayerData")

# Represents one Damage-over-Time effect (infection, burn, etc.)
class DOT:
	var dps: float
	var tick_interval: float
	var remaining_time: float
	var tick_accumulator: float
	var stacks: int

var infection: DOT = null

# ─── Public API ─────────────────────────────────
func apply_infection(base_dps: float, duration: float) -> void:
	"""
	If the enemy is already infected, add a stack (up to 3) 
	and refresh remaining time. Otherwise, create a new DOT.
	"""
	if infection:
		infection.stacks = min(infection.stacks + 1, 3)
		# Each stack increases dps by 33%
		infection.dps = base_dps * (1.0 + 0.33 * infection.stacks)
		infection.remaining_time = duration
	else:
		infection = DOT.new()
		infection.dps = base_dps
		infection.tick_interval = 0.5
		infection.remaining_time = duration
		infection.tick_accumulator = infection.tick_interval
		infection.stacks = 1

# ─── Internal Tick Loop ─────────────────────────
func _process(delta: float) -> void:
	if infection == null:
		return

	infection.remaining_time -= delta
	infection.tick_accumulator -= delta

	if infection.tick_accumulator <= 0.0:
		infection.tick_accumulator += infection.tick_interval
		_tick_damage()

	if infection.remaining_time <= 0.0:
		infection = null

# ─── Helpers ─────────────────────────────────────
func _tick_damage() -> void:
	"""
	Deal a slice of the DOT damage. 
	If crit chance applies, roll for crit.
	"""
	var damage_amount: float = infection.dps * infection.tick_interval
	var is_crit = randf() < pd.get_stat("crit_chance")
	# Parent is the enemy node—call its apply_damage:
	if get_parent().has_method("apply_damage"):
		get_parent().apply_damage(damage_amount, is_crit)

func clear_all() -> void:
	"""
	Removes any ongoing status effects (e.g., on enemy death).
	"""
	infection = null
