extends Label
class_name DamageNumber

signal label_finished

const HOLD_TIME : float = 0.20
const FADE_TIME : float = 0.40
const FLOAT_VEL : float = 22.0
const COUNT_SPEED : float = 60.0  # How fast to increment per second

var total_damage     : float = 0.0
var displayed_damage : float = 0.0
var time_since_hit   : float = 0.0
var fading           : bool  = false
var tween            : Tween = null

func _ready() -> void:
	text                      = ""
	horizontal_alignment      = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment        = VERTICAL_ALIGNMENT_CENTER
	custom_minimum_size       = Vector2(64, 24)
	z_index                   = 999

func add_damage(amount: float, is_crit: bool) -> void:
	total_damage += amount
	modulate      = Color(1, 1, 0) if is_crit else Color(1, 1, 1)
	time_since_hit = 0.0

	if fading:
		fading = false
		if tween and tween.is_valid():
			tween.kill()
		modulate.a = 1.0

func _process(delta: float) -> void:
	# Smooth count-up
	if displayed_damage < total_damage:
		var diff = min(COUNT_SPEED * delta, total_damage - displayed_damage)
		displayed_damage += diff
		text = str(int(displayed_damage))

	time_since_hit += delta
	if not fading and time_since_hit >= HOLD_TIME:
		_start_fade()

func _start_fade() -> void:
	fading = true
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		emit_signal("label_finished")
		queue_free()
	)
