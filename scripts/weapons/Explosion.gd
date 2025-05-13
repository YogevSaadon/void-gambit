extends Area2D
class_name Explosion

@export var damage: float = 20.0
@export var crit_chance: float = 0.0
@export var radius: float = 64.0
@export var damage_group: String = "Enemies"
@export var duration: float = 0.1
@export var color: Color = Color(1, 1, 1, 0.5)

func _ready() -> void:
	$CollisionShape2D.shape.radius = radius
	$Timer.wait_time = duration
	$Timer.start()
	_setup_particles()
	_apply_damage()
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)

func _apply_damage() -> void:
	for body in get_overlapping_bodies():
		if not body.is_in_group(damage_group): continue
		if not body.has_method("take_damage"): continue
		var final_damage = damage
		if crit_chance > 0.0 and randf() < crit_chance:
			final_damage *= 2.0
		body.take_damage(final_damage)

func _on_Timer_timeout() -> void:
	queue_free()

func _setup_particles() -> void:
	var particles: GPUParticles2D = $GPUParticles2D
	if particles == null:
		push_warning("GPUParticles2D not found in Explosion scene!")
		return

	# Node-level settings (GPUParticles2D)
	particles.emitting     = false
	particles.one_shot     = true
	particles.amount       = int(radius / 2.0)
	particles.lifetime     = 0.4
	particles.speed_scale  = 1.0        # overall speed multiplier
	particles.randomness   = 0.0        # per-particle speed randomness

	# Configure a GPU process material
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	# Emit from a sphere of given radius
	mat.emission_shape      = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_box_extents = Vector3(radius / 2.0, radius / 2.0, 0.0)

	# Blast outwards upward-biased
	mat.direction               = Vector3(0, -1, 0)
	mat.directional_velocity_min = 60.0
	mat.directional_velocity_max = 60.0

	# Rotation
	mat.angular_velocity_min    = 45.0
	mat.angular_velocity_max    = 81.0

	# Size
	mat.scale_min = 0.5 * (1.0 - 0.4)  # = 0.3
	mat.scale_max = 0.5 * (1.0 + 0.4)  # = 0.7

	# No extra gravity
	mat.gravity = Vector3.ZERO

	particles.process_material = mat
	particles.emitting         = true
