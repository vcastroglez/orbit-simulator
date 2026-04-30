class_name MassiveObject
extends RigidBody2D

# Bodies merge when closer than this, regardless of their Schwarzschild radii.
const MIN_MERGE_RADIUS: float = 300.0

var scale_factor: float = 1.0e-6
@onready var image: Sprite2D = $image
@export var body_mass: float = 5.972e24
@onready var velocity_vector: Sprite2D = $VelocityVector
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
const SUN = preload("res://universe/massive_object/sun.png")

# Set synchronously when this body is absorbed so other bodies stop interacting
# with it in the same physics frame before call_deferred("queue_free") fires.
var _absorbed: bool = false
var is_black_hole: bool = false

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
	_update_appearance()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _absorbed:
		return

	var total_accel := Vector2.ZERO
	var total_curvature := 0.0
	var absorb_target: MassiveObject = null

	for body in get_parent().get_children():
		if not (body is MassiveObject) or body == self or not is_instance_valid(body):
			continue
		var mo := body as MassiveObject
		if mo._absorbed:
			continue

		var r_vec: Vector2 = global_position - body.global_position
		var r: float = r_vec.length()

		total_accel += Calculations.geodesic_accel(r_vec, state.linear_velocity, mo.body_mass)

		var r_m: float = r / scale_factor
		total_curvature += Calculations.spacetime_curvature_percent(r_m, mo.body_mass)

		# Only the more massive body initiates; tiebreak by instance ID so exactly one body acts.
		if absorb_target == null:
			var merge_r: float = maxf(
				maxf(Calculations.schwarzschild_radius_game(body_mass),
					 Calculations.schwarzschild_radius_game(mo.body_mass)),
				MIN_MERGE_RADIUS
			)
			var we_win: bool = body_mass > mo.body_mass or \
				(body_mass == mo.body_mass and get_instance_id() > body.get_instance_id())
			if r < merge_r and we_win:
				absorb_target = mo

	if absorb_target != null and is_instance_valid(absorb_target):
		var combined: float = body_mass + absorb_target.body_mass
		state.linear_velocity = (state.linear_velocity * body_mass + absorb_target.linear_velocity * absorb_target.body_mass) / combined
		body_mass = combined
		mass = body_mass
		_update_appearance()
		absorb_target._absorbed = true
		absorb_target.call_deferred("queue_free")
	else:
		state.linear_velocity += total_accel * state.step

	# Black holes are anchored: spacetime is so curved here that nothing escapes,
	# including the singularity itself shifting position.
	if is_black_hole:
		state.linear_velocity = Vector2.ZERO

	velocity_vector.rotation = state.linear_velocity.angle()
	_update_visual_curvature(total_curvature)

func _update_appearance() -> void:
	if body_mass >= Calculations.sun_mass * 3.0:
		is_black_hole = true
		image.texture = SUN
		image.modulate = Color(0.0, 0.0, 0.0, 1.0)
		velocity_vector.visible = false
	elif body_mass >= Calculations.earth_mass * 25000:
		image.texture = SUN

func _update_visual_curvature(curvature: float) -> void:
	var intensity: float = clamp(curvature / 10.0, 0.0, 1.0)
	velocity_vector.modulate = Color(1.0, 1.0 - intensity * 0.5, 1.0 - intensity * 0.5)
	var scale_effect: float = 1.0 + (curvature / 1000.0)
	velocity_vector.scale = Vector2.ONE * scale_effect

func get_influence(object: MassiveObject) -> float:
	var distance: float = Calculations.get_distance(object.position, self.position)
	return Calculations.spacetime_curvature_percent(distance, self.mass)
