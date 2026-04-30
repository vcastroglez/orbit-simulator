class_name MassiveObject
extends RigidBody2D

var scale_factor: float = 1.0e-6
@onready var image: Sprite2D = $image
@export var force_multiplier: float = 1.25e27  # Multiplier to make forces visible in game
@export var body_mass: float = 5.972e24 # Mass in kg (default: Earth-like)
@onready var velocity_vector: Sprite2D = $VelocityVector
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
const SUN = preload("res://universe/massive_object/sun.png")

# Example usage with some real-world objects
func _ready():
	if !body_mass:
		body_mass =  Calculations.earth_mass
	mass = body_mass
		# Disable all damping (friction-like forces) - only inertia remains
	linear_damp_mode = DAMP_MODE_REPLACE
	linear_damp = 0.0
	angular_damp_mode = DAMP_MODE_REPLACE
	angular_damp = 0.0
	
	if body_mass <= Calculations.earth_mass:
		linear_velocity = Vector2(randi_range(0, 1000), randi_range(0, 1000))
	
	if body_mass >= Calculations.earth_mass * 25000:
		image.texture = SUN
	# Disable gravity
	gravity_scale = 0.0

func _physics_process(delta: float) -> void:
	var total_acceleration = Vector2.ZERO
	var total_curvature = 0
	for body in get_parent().get_children():
		if !(body is MassiveObject):
			continue
		var direction = body.global_position - global_position
		var distance_pixels = direction.length()
		var distance_meters = distance_pixels / scale_factor
		
		if !distance_meters:
			continue
		var other_mass = body.body_mass
		
		if distance_meters <= 0 || other_mass <= 0:
			print(other_mass, ' ', distance_meters)
		var curvature = Calculations.spacetime_curvature_percent(distance_meters, other_mass)
		total_curvature += curvature
		var curvature_factor = 1.0 + (curvature / 100.0)
		direction = direction * curvature
		total_acceleration += direction
	
	apply_central_force(total_acceleration.normalized() * force_multiplier)
	velocity_vector.rotation = linear_velocity.angle()
		# Optional: Update visual representation based on curvature
	_update_visual_curvature(total_curvature)

# Optional: Visual feedback for spacetime curvature
func _update_visual_curvature(curvature: float) -> void:
	# Modulate color based on curvature intensity
	var intensity = clamp(curvature / 10.0, 0.0, 1.0)
	velocity_vector.modulate = Color(1.0, 1.0 - intensity * 0.5, 1.0 - intensity * 0.5)
	
	# Scale sprite slightly based on curvature (gravitational lensing effect)
	var scale_effect = 1.0 + (curvature / 1000.0)
	velocity_vector.scale = Vector2.ONE * scale_effect

func get_influence(object : MassiveObject):
	var distance = Calculations.get_distance(object.position, self.position)
	return Calculations.spacetime_curvature_percent(distance, self.mass)
