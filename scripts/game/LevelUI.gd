# scripts/game/LevelUI.gd
extends CanvasLayer
class_name LevelUI

# ===== EXISTING NODES =====
@onready var hp_bar       = $Bars/HPBarContainer/HPBar
@onready var hp_text      = $Bars/HPBarContainer/HPText
@onready var shield_bar   = $Bars/ShieldBarContainer/ShieldBar
@onready var shield_text  = $Bars/ShieldBarContainer/ShieldText

# ===== NEW NODES =====
@onready var blink_bar    = $Bars/BlinkBarContainer/BlinkBar
@onready var blink_text   = $Bars/BlinkBarContainer/BlinkText
@onready var level_label  = $LevelLabel
@onready var timer_label  = $Timer          
@onready var credit_label = $CreditLabel   
@onready var gold_label   = $GoldLabel     
# ===== REFERENCES =====
@onready var gm           = get_tree().root.get_node("GameManager")
@onready var wave_manager = get_tree().current_scene.get_node_or_null("WaveManager")
var player : Node = null

# ===== LIFECYCLE =====
func _ready() -> void:
	# Level string is static until you load the next one
	level_label.text = "LEVEL %d" % gm.level_number
	
	# Blink bar starts fully charged
	blink_bar.min_value = 0.0
	blink_bar.max_value = 1.0
	blink_bar.value     = 1.0

func set_player(p : Node) -> void:
	player = p

# ===== PER‑FRAME UPDATE =====
func _process(_delta: float) -> void:
	if player == null:
		return
	
	_update_health_ui()
	_update_shield_ui()
	_update_blink_ui()
	_update_timer_ui()
	
	# Live currency read‑outs
	credit_label.text = "CREDITS: %d" % gm.credits
	gold_label.text   = "GOLD: %d"    % gm.coins

# ===== HEALTH UI =====
func _update_health_ui() -> void:
	hp_bar.max_value = player.max_health
	hp_bar.value     = player.health
	hp_text.text     = "%d/%d" % [player.health, player.max_health]

# ===== SHIELD UI =====
func _update_shield_ui() -> void:
	shield_bar.max_value = player.max_shield
	shield_bar.value     = player.shield
	shield_text.text     = "%d/%d" % [player.shield, player.max_shield]

# ===== BLINK UI =====
func _update_blink_ui() -> void:
	if not player.has_node("BlinkSystem"):
		return
	
	var blink_system   = player.get_node("BlinkSystem")
	var current_blinks = blink_system.current_blinks
	var max_blinks     = blink_system.max_blinks
	var cooldown       = blink_system.cooldown
	var blink_timer    = blink_system.blink_timer
	
	# Text
	blink_text.text = "%d/%d" % [current_blinks, max_blinks]
	
	# Bar & colour
	if current_blinks >= max_blinks:
		blink_bar.value    = 1.0
		blink_bar.modulate = Color(0.8, 0.4, 1.0, 1.0)  # ready
	else:
		blink_bar.value    = (blink_timer / cooldown) if cooldown > 0 else 0.0
		blink_bar.modulate = Color(0.4, 0.2, 0.6, 1.0)  # charging

# Optional visual feedback hook
func show_blink_used_effect() -> void:
	if blink_text:
		var tw = create_tween()
		tw.tween_property(blink_text, "modulate", Color.WHITE, 0.1)
		tw.tween_property(blink_text, "modulate", Color(0.8, 0.4, 1.0, 1.0), 0.1)

# ===== TIMER UI =====
func _update_timer_ui() -> void:
	if wave_manager == null or not wave_manager.has_method("get_time_remaining"):
		timer_label.text = "TIME"
		return
	
	var time_remaining = wave_manager.get_time_remaining()
	var minutes        = int(time_remaining) / 60
	var seconds        = int(time_remaining) % 60
	timer_label.text   = "%d:%02d" % [minutes, seconds]
