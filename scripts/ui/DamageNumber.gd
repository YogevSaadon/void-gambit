# scripts/ui/DamageNumber.gd
extends Node2D
class_name DamageNumber

# ===== BULLET HELL DAMAGE DISPLAY SYSTEM =====
# PROBLEM: Rapid-fire weapons create 50+ damage numbers per enemy causing:
#   - Visual spam that obscures gameplay
#   - Performance death from hundreds of UI nodes
#   - Memory leaks when enemies die mid-animation
# SOLUTION: Aggregate multiple hits into single animated counter with safe detachment
# DOMAIN: Essential for bullet-hell games where 1000+ damage events occur per second

signal label_finished

# ===== TIMING CONSTANTS =====
const HOLD_TIME: float = 0.08    # Display time before fade starts
const FADE_TIME: float = 0.40    # Fade duration for smooth exit
const FLOAT_SPEED: float = 30.0  # Upward drift speed (game juice)
const COUNT_SPEED: float = 60.0  # Damage counter animation speed

# ===== DAMAGE AGGREGATION STATE =====
var total_damage: float = 0.0      # Accumulated damage from multiple hits
var displayed_damage: float = 0.0  # Current animated display value
var time_since_hit: float = 0.0    # Timer for fade trigger
var fading: bool = false           # Animation state flag
var tween: Tween = null            # Fade animation controller
var is_detached: bool = false      # Memory safety flag

# ===== VISUAL PROPERTIES =====
var crit_color: Color = Color(1, 0.3, 0.3)  # Red for critical hits
var norm_color: Color = Color(1, 1, 1)      # White for normal damage

# ===== COMPONENTS =====
var label: Label

# ===== MEMORY SAFETY SYSTEM =====
# WHY: Enemies die unpredictably while damage numbers animate
# SOLUTION: _accepting_damage flag prevents new damage on dying enemies
# BENEFIT: Clean animation completion without memory leaks or visual glitches
var _accepting_damage: bool = true

# ===== INITIALIZATION =====
func _ready() -> void:
	label = Label.new()
	add_child(label)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = ""
	_center_label()

# ===== DAMAGE AGGREGATION SYSTEM =====
func add_damage(amount: float, is_crit: bool) -> void:
	"""
	BULLET HELL OPTIMIZATION: Combines rapid hits into single display
	
	PROBLEM: High-RoF weapons (300+ bullets/sec) create visual chaos
	SOLUTION: Aggregate damage values, smooth-count to final total
	PERFORMANCE: 1 UI element per enemy instead of 50+ overlapping numbers
	"""
	if not _accepting_damage:
		return  # Enemy dying - reject new damage but continue animation
		
	total_damage += amount
	label.modulate = crit_color if is_crit else norm_color

	# SMOOTH COUNTING: Initialize or update display target
	if displayed_damage == 0.0:
		displayed_damage = total_damage      # First hit - instant display
		label.text = str(int(displayed_damage))
	else:
		label.text = str(int(total_damage))  # Update target for counting animation

	_center_label()
	time_since_hit = 0.0  # Reset fade timer

	# ANIMATION INTERRUPTION: Cancel fade if new damage arrives
	if fading:
		fading = false
		if tween and tween.is_valid():
			tween.kill()
		modulate.a = 1.0

# ===== SMOOTH ANIMATION SYSTEM =====
func _process(delta: float) -> void:
	# SMOOTH COUNTING: Animate from displayed_damage to total_damage
	# GAME JUICE: Creates satisfying visual feedback for big hits
	if displayed_damage < total_damage:
		var step: float = min(COUNT_SPEED * delta, total_damage - displayed_damage)
		displayed_damage += step
		label.text = str(int(displayed_damage))
		_center_label()

	# VISUAL POLISH: Upward drift for game feel
	position.y -= FLOAT_SPEED * delta

	# LIFECYCLE MANAGEMENT: Trigger fade after hold time
	time_since_hit += delta
	if not fading and time_since_hit >= HOLD_TIME:
		if not is_detached:
			detach()  # Safe detachment from dying enemy
		else:
			_start_fade()  # Normal fade sequence

# ===== UTILITY METHODS =====
func _center_label() -> void:
	"""Center label on node origin for consistent positioning"""
	if not is_instance_valid(label):
		return
	var size: Vector2 = label.get_minimum_size()
	label.position = Vector2(-size.x * 0.5, -size.y * 0.5)

func _start_fade() -> void:
	"""Smooth fade-out animation with cleanup"""
	fading = true
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_on_fade_done)

func _on_fade_done() -> void:
	"""Complete animation lifecycle"""
	emit_signal("label_finished")
	queue_free()

# ===== BULLET HELL MEMORY SAFETY =====
func detach() -> void:
	"""
	CRITICAL SYSTEM: Prevents memory leaks when enemies die during animation
	
	PROBLEM: Enemy death destroys damage number mid-animation
	CONSEQUENCES: Visual glitches, abrupt cutoffs, poor game feel
	SOLUTION: Reparent to scene root, preserve world position, complete animation
	
	MEMORY SAFETY: Breaks parent reference to allow enemy cleanup
	VISUAL CONTINUITY: Animation completes naturally for player feedback
	"""
	if is_detached:
		return
	is_detached = true

	# POSITION PRESERVATION: Maintain world coordinates during reparenting
	var gpos: Vector2 = global_position

	# SAFE REFERENCE: Cache tree before parent removal
	var tree: SceneTree = get_tree()

	if get_parent():
		get_parent().remove_child(self)

	# FALLBACK HIERARCHY: Find safe parent for orphaned damage number
	var target_parent: Node = null
	if tree != null:
		target_parent = tree.get_current_scene()
		if target_parent == null:
			target_parent = tree.root
	else:
		target_parent = get_viewport()  # Last resort

	# REPARENTING WITH VALIDATION: Ensure safe attachment
	if target_parent and is_instance_valid(target_parent):
		target_parent.add_child(self)
		global_position = gpos  # Restore world position
	else:
		# GRACEFUL DEGRADATION: No safe parent found
		queue_free()

# ===== CLEANUP =====
func _exit_tree() -> void:
	"""Final cleanup - stop accepting damage and kill animations"""
	_accepting_damage = false
	if tween and tween.is_valid():
		tween.kill()
