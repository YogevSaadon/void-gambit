# res://scripts/ui/DamageNumber.gd
extends Label
class_name DamageNumber

signal label_finished

const HOLD_TIME   : float = 0.20   # seconds to wait before fading
const FADE_TIME   : float = 0.40   # fade-out duration
const FLOAT_SPEED : float = 0.0    # set to 0 to disable floating
const COUNT_SPEED : float = 60.0   # points per second for count-up

var total_damage     : float = 0.0
var displayed_damage : float = 0.0
var time_since_hit   : float = 0.0
var fading           : bool  = false
var tween            : Tween = null
var was_initialized  : bool  = false

func _ready() -> void:
	# Centered text
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	custom_minimum_size  = Vector2(64, 24)
	z_index              = 999
	text                 = ""

func add_damage(amount: float, is_crit: bool) -> void:
	# 1) Update total
	total_damage += amount

	# 2) Color for crit vs normal
	modulate = Color(1,1,0) if is_crit else Color(1,1,1)

	# 3) On first hit, snap display to total; thereafter, count up
	if not was_initialized:
		displayed_damage   = total_damage
		was_initialized    = true
		text               = str(int(displayed_damage))
	
	# 4) Reset fade timer
	time_since_hit = 0.0
	if fading:
		fading = false
		if tween and tween.is_valid():
			tween.kill()
		modulate.a = 1.0

func _process(delta: float) -> void:
	# A) Smooth count-up if needed
	if displayed_damage < total_damage:
		var diff = min(COUNT_SPEED * delta, total_damage - displayed_damage)
		displayed_damage += diff
		text = str(int(displayed_damage))

	# B) Optional floating (disabled here via FLOAT_SPEED=0)
	position.y -= FLOAT_SPEED * delta

	# C) Start fade once HOLD_TIME passes
	time_since_hit += delta
	if not fading and time_since_hit >= HOLD_TIME:
		_start_fade()

func _start_fade() -> void:
	fading = true
	tween  = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		emit_signal("label_finished")
		queue_free()
	)
