class_name Physicist
extends Node

# Physical constants
const G = 6.67430e-11  # Gravitational constant (m^3 kg^-1 s^-2)
const C = 299792458.0  # Speed of light (m/s)

# Earth parameters
var earth_mass = 5.972e24  # kg
var earth_radius = 6.371e6  # meters
	# Sun parameters
var sun_mass = 1.989e30  # kg
var sun_radius = 6.96e8  # meters
	
func _ready() -> void:
	print("Earth's surface:")
	var earth_surface_curve = Calculations.spacetime_curvature_percent(earth_radius, earth_mass)
	print("  Curvature: %.10f%%" % earth_surface_curve)
	
	
	print("\nSun's surface:")
	var sun_surface_curve = Calculations.spacetime_curvature_percent(sun_radius, sun_mass)
	print("  Curvature: %.6f%%" % sun_surface_curve)
	
	# Black hole (stellar mass)
	var bh_mass = 10.0 * sun_mass
	var bh_rs = Calculations.schwarzschild_radius(bh_mass)
	
	print("\nStellar black hole:")
	print("  Schwarzschild radius: %.2f km" % (bh_rs / 1000.0))
	print("  At 1x event horizon: %.2f%%" % Calculations.spacetime_curvature_percent(1.0 * bh_rs, bh_mass))
	print("  At 2x event horizon: %.2f%%" % Calculations.spacetime_curvature_percent(2.0 * bh_rs, bh_mass))
	print("  At 10x event horizon: %.2f%%" % Calculations.spacetime_curvature_percent(10.0 * bh_rs, bh_mass))
	
	
# Calculate the Schwarzschild radius for a given mass
func schwarzschild_radius(mass: float) -> float:
	return (2.0 * G * mass) / (C * C)

# Calculate spacetime curvature as a percentage
# Parameters:
#   distance: distance from center of mass in meters
#   mass: mass of the object in kilograms
# Returns: percentage of spacetime curvature (0-100%)
func spacetime_curvature_percent(distance: float, mass: float) -> float:
	if distance <= 0 || mass <= 0:
		push_warning("Invalid parameters: distance and mass must be positive")
		return 0.0
	
	var rs = schwarzschild_radius(mass)
	
	# Check if we're inside the Schwarzschild radius (event horizon)
	if distance <= rs:
		return 100.0
	
	# Calculate the time dilation factor using Schwarzschild metric
	# sqrt(1 - rs/r) represents how much proper time differs from coordinate time
	var time_dilation = sqrt(1.0 - rs / distance)
	
	# Convert to curvature percentage
	# 0% = flat spacetime (far from mass)
	# 100% = maximum curvature (at event horizon)
	var curvature_percent = (1.0 - time_dilation) * 100.0
	
	return curvature_percent

func get_distance(p1 : Vector2i, p2 : Vector2i) -> float:
	var dx = p1.x - p2.x
	var dy = p1.y - p2.y
	return sqrt(dx * dx + dy * dy)
