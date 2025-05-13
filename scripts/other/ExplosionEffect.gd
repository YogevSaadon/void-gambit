extends Node2D
class_name ExplosionEffect

@export var radius: float = 64.0
@export var amount_factor: float = 0.5    # particles.amount = radius * amount_factor
@export var particle_lifetime: float = 0.4
@export var speed_scale: float = 1.0
@export var randomness: float = 0.0
@export var velocity_min: float = 60.0
@export var velocity_max: float = 60.0
@export var angular_min: float = 45.0
@export var angular_max: float = 81.0
@export var scale_variation: float = 0.4  # ±40%

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var timer: Timer               = $Timer

func _ready() -> void:
	_setup_particles()
	timer.wait_time = particle_lifetime
	timer.start()

func _setup_particles() -> void:
	if particles == null:
		push_warning("GPUParticles2D not found in ExplosionEffect scene!")
		return

	# GPUParticles2D settings
	particles.one_shot    = true
	particles.emitting    = true
	particles.amount      = int(radius * amount_factor)
	particles.lifetime    = particle_lifetime
	particles.speed_scale = speed_scale
	particles.randomness  = randomness

	# Build and assign a process material
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape       = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_box_extents = Vector3(radius / 2.0, radius / 2.0, 0.0)
	mat.direction            = Vector3(0, -1, 0)
	mat.directional_velocity_min = velocity_min
	mat.directional_velocity_max = velocity_max
	mat.angular_velocity_min = angular_min
	mat.angular_velocity_max = angular_max

	# Scale variation around 0.5
	mat.scale_min = 0.5 * (1.0 - scale_variation)
	mat.scale_max = 0.5 * (1.0 + scale_variation)
	mat.gravity    = Vector3.ZERO

	particles.process_material = mat

func _on_Timer_timeout() -> void:
	queue_free()
