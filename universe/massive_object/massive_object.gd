class_name MassiveObject
extends RigidBody2D

var scale_factor: float = 1.0e-6
@onready var image: Sprite2D = $image
@export var body_mass: float = 5.972e24
@onready var velocity_vector: Sprite2D = $VelocityVector
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
const SUN = preload("res://universe/massive_object/sun.png")

func _ready() -> void:
	if !body_mass:
		body_mass = Calculations.earth_mass
	mass = body_mass

	linear_damp_mode = DAMP_MODE_REPLACE
	linear_damp = 0.0
	angular_damp_mode = DAMP_MODE_REPLACE
	angular_damp = 0.0
	gravity_scale = 0.0

	if body_mass <= Calculations.earth_mass:
		linear_velocity = Vector2(randi_range(0, 1000), randi_range(0, 1000))

	if body_mass >= Calculations.earth_mass * 25000:
		image.texture = SUN

# _integrate_forces gives us direct control over velocity each physics step,
# bypassing Godot's built-in force accumulation. We update velocity by the
# geodesic acceleration ourselves, then Godot integrates position from velocity.
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var total_accel := Vector2.ZERO
	var total_curvature := 0.0

	for body in get_parent().get_children():
		if not (body is MassiveObject) or body == self:
			continue

		# Vector from the source body to us — curvature acts along this direction
		var r_vec: Vector2 = global_position - body.global_position

		total_accel += Calculations.geodesic_accel(r_vec, state.linear_velocity, body.body_mass)

		# Curvature percentage uses SI units (via scale_factor) for visual feedback only
		var r_m := r_vec.length() / scale_factor
		total_curvature += Calculations.spacetime_curvature_percent(r_m, body.body_mass)

	# Euler integration of geodesic velocity change: Δv = a · Δt
	state.linear_velocity += total_accel * state.step

	velocity_vector.rotation = state.linear_velocity.angle()
	_update_visual_curvature(total_curvature)

func _update_visual_curvature(curvature: float) -> void:
	var intensity := clamp(curvature / 10.0, 0.0, 1.0)
	velocity_vector.modulate = Color(1.0, 1.0 - intensity * 0.5, 1.0 - intensity * 0.5)
	var scale_effect := 1.0 + (curvature / 1000.0)
	velocity_vector.scale = Vector2.ONE * scale_effect

func get_influence(object: MassiveObject) -> float:
	var distance := Calculations.get_distance(object.position, self.position)
	return Calculations.spacetime_curvature_percent(distance, self.mass)
