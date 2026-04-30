class_name Physicist
extends Node

# Physical constants (SI) — kept for reference and visualization
const G = 6.67430e-11  # m³ kg⁻¹ s⁻²
const C = 299792458.0  # m/s

# Body parameters
var earth_mass = 5.972e24  # kg
var earth_radius = 6.371e6  # m
var sun_mass = 1.989e30    # kg
var sun_radius = 6.96e8    # m

# Game-unit constants (positions in px, time in seconds).
# G_EFF is calibrated so a circular orbit at ~3400 px around a sun-mass body
# has a natural velocity of ~400 px/s (matching scene initial velocities).
# C_EFF is reduced from the real speed of light so the Schwarzschild radius of
# a sun-mass body spans ~120 px — large enough to produce visible GR effects
# (precession, event-horizon capture) at typical game distances.
# Both can be tuned: raise C_EFF to weaken GR effects, lower it to strengthen them.
var G_EFF: float = 2.8e-22  # px³ kg⁻¹ s⁻²
var C_EFF: float = 3000.0   # px/s

func _ready() -> void:
	print("Sun Schwarzschild radius (game units): %.1f px" % schwarzschild_radius_game(sun_mass))
	print("Earth Schwarzschild radius (game units): %.4f px" % schwarzschild_radius_game(earth_mass))

# Schwarzschild radius in SI meters (for visualization only)
func schwarzschild_radius(mass: float) -> float:
	return (2.0 * G * mass) / (C * C)

# Schwarzschild radius in game units (pixels)
func schwarzschild_radius_game(mass: float) -> float:
	return (2.0 * G_EFF * mass) / (C_EFF * C_EFF)

# Geodesic acceleration of a test body in the curved spacetime of source_mass.
#
# Derived from the Schwarzschild metric geodesic equation.
# The time-time metric component g_tt = -(1 - rs/r) encodes how mass curves
# spacetime. Bodies don't experience a force — they follow the straightest
# possible path (geodesic) through this curved geometry.
#
# The acceleration comes from the gradient of the metric:
#   a = -(c²/2) · ∂_r(ln|g_tt|) · (1 + v²/c²) · r̂
#       = -(G·M / (r² · (1 - rs/r))) · (1 + v²/c²) · r̂
#
# The (1 - rs/r) denominator diverges at the event horizon (r → rs), capturing
# the infinite curvature there. The (1 + v²/c²) factor comes from the 4-velocity
# normalization in the geodesic equation and causes orbital precession: at
# perihelion where v is highest, curvature coupling is strongest, so the orbit
# does not close — it precesses.
#
# All arguments and the return value are in game units (px, px/s, px/s²).
func geodesic_accel(r_vec: Vector2, velocity: Vector2, source_mass: float) -> Vector2:
	var r = r_vec.length()
	if r == 0.0:
		return Vector2.ZERO

	var rs = schwarzschild_radius_game(source_mass)

	# Inside the event horizon: geodesic converges to singularity
	if r <= rs:
		return -r_vec.normalized() * 1.0e8

	# Spacetime curvature factor at this distance (from g_tt component)
	var g00 = 1.0 - rs / r

	var v_sq = velocity.length_squared()
	var c_sq = C_EFF * C_EFF

	# Geodesic acceleration magnitude: metric gradient × velocity correction
	var accel = G_EFF * source_mass / (r * r * g00) * (1.0 + v_sq / c_sq)

	return -r_vec.normalized() * accel

# Spacetime curvature as a percentage (0 = flat, 100 = event horizon).
# Used only for visual feedback — not for motion calculations.
func spacetime_curvature_percent(distance: float, mass: float) -> float:
	if distance <= 0.0 || mass <= 0.0:
		push_warning("Invalid parameters: distance and mass must be positive")
		return 0.0
	var rs = schwarzschild_radius(mass)
	if distance <= rs:
		return 100.0
	var time_dilation = sqrt(1.0 - rs / distance)
	return (1.0 - time_dilation) * 100.0

func get_distance(p1: Vector2i, p2: Vector2i) -> float:
	var dx = p1.x - p2.x
	var dy = p1.y - p2.y
	return sqrt(dx * dx + dy * dy)
