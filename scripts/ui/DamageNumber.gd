# scripts/ui/DamageNumber.gd
extends Node2D
class_name DamageNumber

signal label_finished

# ===== TIMING CONSTANTS =====
const HOLD_TIME: float = 0.08
const FADE_TIME: float = 0.40
const FLOAT_SPEED: float = 30.0
const COUNT_SPEED: float = 60.0

# ===== DAMAGE STATE =====
var total_damage: float = 0.0
var displayed_damage: float = 0.0
var time_since_hit: float = 0.0
var fading: bool = false
var tween: Tween = null
var is_detached: bool = false

# ===== VISUAL PROPERTIES =====
var crit_color: Color = Color(1, 0.3, 0.3)
var norm_color: Color = Color(1, 1, 1)

# ===== COMPONENTS =====
var label: Label

# ===== MEMORY MANAGEMENT =====
var _accepting_damage: bool = true  # Prevents new damage, allows animation completion

# ===== INITIALIZATION =====
func _ready() -> void:
	label = Label.new()
	add_child(label)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = ""
	_center_label()

# ===== DAMAGE AGGREGATION =====
func add_damage(amount: float, is_crit: bool) -> void:
	"""Add damage to counter - aggregates multiple hits into single display"""
	if not _accepting_damage:
		return
		
	total_damage += amount
	label.modulate = crit_color if is_crit else norm_color

	# Initialize or update display
	if displayed_damage == 0.0:
		displayed_damage = total_damage
		label.text = str(int(displayed_damage))
	else:
		label.text = str(int(total_damage))

	_center_label()
	time_since_hit = 0.0

	# Cancel fade if in progress
	if fading:
		fading = false
		if tween and tween.is_valid():
			tween.kill()
		modulate.a = 1.0

# ===== UPDATE LOOP =====
func _process(delta: float) -> void:
	# Smooth count-up animation
	if displayed_damage < total_damage:
		var step: float = min(COUNT_SPEED * delta, total_damage - displayed_damage)
		displayed_damage += step
		label.text = str(int(displayed_damage))
		_center_label()

	# Upward drift
	position.y -= FLOAT_SPEED * delta

	# Fade timing
	time_since_hit += delta
	if not fading and time_since_hit >= HOLD_TIME:
		if not is_detached:
			detach()
		else:
			_start_fade()

# ===== UTILITY METHODS =====
func _center_label() -> void:
	"""Center label on this node's origin"""
	if not is_instance_valid(label):
		return
	var size: Vector2 = label.get_minimum_size()
	label.position = Vector2(-size.x * 0.5, -size.y * 0.5)

func _start_fade() -> void:
	"""Begin fade out animation"""
	fading = true
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_on_fade_done)

func _on_fade_done() -> void:
	"""Clean up after fade completes"""
	emit_signal("label_finished")
	queue_free()

# ===== MEMORY MANAGEMENT SYSTEM =====
func detach() -> void:
	"""
	Detach from parent when enemy dies - prevents memory leaks.
	
	SAFETY: Preserves world position and reparents to scene root to complete 
	animation without holding references to destroyed enemies.
	"""
	if is_detached:
		return
	is_detached = true

	# Preserve world position
	var gpos: Vector2 = global_position

	# Cache the SceneTree reference before removal
	var tree: SceneTree = get_tree()

	if get_parent():
		get_parent().remove_child(self)

	# Choose a safe parent for the floating number
	var target_parent: Node = null
	if tree != null:
		target_parent = tree.get_current_scene()
		if target_parent == null:
			target_parent = tree.root
	else:
		target_parent = get_viewport()

	# Safety check before re-parenting
	if target_parent and is_instance_valid(target_parent):
		target_parent.add_child(self)
		global_position = gpos
	else:
		# Can't find safe parent, just let it free naturally
		queue_free()

# ===== CLEANUP =====
func _exit_tree() -> void:
	"""Stop accepting damage and clean up"""
	_accepting_damage = false
	if tween and tween.is_valid():
		tween.kill()
