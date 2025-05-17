# res://scripts/ui/DamageNumber.gd
extends Label
class_name DamageNumber

const HOLD_TIME : float = 0.20    # delay before fade
const FADE_TIME : float = 0.40    # fade-out duration

var total_damage   : float = 0.0
var time_since_hit : float = 0.0
var fading         : bool  = false
var tween          : Tween = null

func _ready() -> void:
	# Center text alignment
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	custom_minimum_size  = Vector2(64, 24)
	text = ""
	z_index = 999        # render over sprites

func add_damage(amount: float, is_crit: bool) -> void:
	total_damage += amount
	text = str(int(total_damage))
	modulate = Color(1,1,0) if is_crit else Color(1,1,1)

	time_since_hit = 0.0
	if fading:
		fading = false
		if tween and tween.is_valid():
			tween.kill()
		modulate.a = 1.0

	# small pop-scale animation
	scale = Vector2.ONE
	var pop := create_tween()
	pop.tween_property(self, "scale", Vector2(1.15, 1.15), 0.05)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(self, "scale", Vector2.ONE, 0.05).set_delay(0.05)

func _process(delta: float) -> void:
	time_since_hit += delta
	if not fading and time_since_hit >= HOLD_TIME:
		_start_fade()

func _start_fade() -> void:
	fading = true
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)
