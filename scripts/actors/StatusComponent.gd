# res://scripts/components/StatusComponent.gd
extends Node
class_name StatusComponent

@onready var pd = get_tree().root.get_node("PlayerData")   # consistent singleton access

# ────── DOT struct ──────
class DOT:
	var dps: float
	var tick: float
	var remaining: float
	var stacks: int

var infection: DOT = null                                   # active infection

# ────── Public API ──────
func apply_infection(base_dps: float, duration: float) -> void:
	if infection:
		infection.stacks = min(infection.stacks + 1, 3)
		infection.dps    = base_dps * (1.0 + 0.33 * infection.stacks)
		infection.remaining = duration
	else:
		infection = DOT.new()
		infection.dps       = base_dps
		infection.tick      = 0.5
		infection.remaining = duration
		infection.stacks    = 1

# ────── Tick loop ──────
func _process(delta: float) -> void:
	if infection == null:
		return

	infection.tick      -= delta
	infection.remaining -= delta

	if infection.tick <= 0.0:
		infection.tick += 0.5
		_tick_damage()

	if infection.remaining <= 0.0:
		infection = null

# ────── Helpers ──────
func _tick_damage() -> void:
	var dmg     = infection.dps * 0.5
	var is_crit = randf() < pd.get_stat("crit_chance")
	if is_crit:
		dmg *= pd.get_stat("crit_damage")
	get_parent().take_damage(dmg)
