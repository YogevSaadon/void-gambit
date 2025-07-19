# scripts/game/LevelUI.gd
extends CanvasLayer
class_name LevelUI

# ===== YOUR EXISTING NODES =====
@onready var hp_bar = $Bars/HPBarContainer/HPBar
@onready var hp_text = $Bars/HPBarContainer/HPText
@onready var shield_bar = $Bars/ShieldBarContainer/ShieldBar
@onready var shield_text = $Bars/ShieldBarContainer/ShieldText

# ===== YOUR NEW NODES =====
@onready var blink_bar = $Bars/BlinkBarContainer/BlinkBar
@onready var blink_text = $Bars/BlinkBarContainer/BlinkText
@onready var level_label = $LevelLabel
@onready var timer_label = $tIMER

# ===== REFERENCES =====
@onready var gm = get_tree().root.get_node("GameManager")
@onready var wave_manager = get_tree().current_scene.get_node_or_null("WaveManager")
var player: Node = null

func _ready():
	level_label.text = "LEVEL %d" % gm.level_number
	
	# Setup blink bar
	blink_bar.min_value = 0.0
	blink_bar.max_value = 1.0
	blink_bar.value = 1.0  # Start fully charged

func set_player(p: Node) -> void:
	player = p

func _process(delta: float) -> void:
	if player == null:
		return
	
	_update_health_ui()
	_update_shield_ui()
	_update_blink_ui()
	_update_timer_ui()

# ===== HEALTH UI =====
func _update_health_ui() -> void:
	hp_bar.max_value = player.max_health
	hp_bar.value = player.health
	hp_text.text = "%d/%d" % [player.health, player.max_health]

# ===== SHIELD UI =====
func _update_shield_ui() -> void:
	shield_bar.max_value = player.max_shield
	shield_bar.value = player.shield
	shield_text.text = "%d/%d" % [player.shield, player.max_shield]

# ===== BLINK UI =====
func _update_blink_ui() -> void:
	if not player.has_node("BlinkSystem"):
		return
	
	var blink_system = player.get_node("BlinkSystem")
	if not blink_system:
		return
	
	# Get blink data
	var current_blinks = blink_system.current_blinks
	var max_blinks = blink_system.max_blinks
	var cooldown = blink_system.cooldown
	var blink_timer = blink_system.blink_timer
	
	# Update blink count text
	blink_text.text = "%d/%d" % [current_blinks, max_blinks]
	
	# Update blink bar (shows cooldown progress)
	if current_blinks >= max_blinks:
		# All blinks available - bar full
		blink_bar.value = 1.0
		blink_bar.modulate = Color(0.8, 0.4, 1, 1)  # Purple (ready)
	else:
		# Show recharge progress
		if cooldown > 0:
			blink_bar.value = blink_timer / cooldown
		else:
			blink_bar.value = 0.0
		
		# Darker purple when charging
		blink_bar.modulate = Color(0.4, 0.2, 0.6, 1)

# ===== TIMER UI =====
func _update_timer_ui() -> void:
	if not wave_manager:
		timer_label.text = "TIME"
		return
	
	if not wave_manager.has_method("get_time_remaining"):
		timer_label.text = "TIME"
		return
	
	var time_remaining = wave_manager.get_time_remaining()
	
	# Format time as M:SS
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	timer_label.text = "%d:%02d" % [minutes, seconds]

# ===== VISUAL EFFECTS =====
func show_blink_used_effect() -> void:
	if blink_text:
		var tween = create_tween()
		tween.tween_property(blink_text, "modulate", Color.WHITE, 0.1)
		tween.tween_property(blink_text, "modulate", Color(0.8, 0.4, 1, 1), 0.1)
