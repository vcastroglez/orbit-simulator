extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
const MASSIVE_OBJECT = preload("res://universe/massive_object/massive_object.tscn")
var target_zoom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_zoom = Vector2(0.1,0.1)
	
var pressed
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && !pressed:
			pressed = get_global_mouse_position()
		else: 
			pressed = null
			
	if pressed:
		camera_2d.position =  camera_2d.position + (pressed - get_global_mouse_position())
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("wheel_up"):
		target_zoom = target_zoom * 1.2
	if Input.is_action_just_pressed("wheel_down"):
		target_zoom = target_zoom * 0.8
	
	if target_zoom.x <= 0:
		target_zoom.x = 0.1
	if target_zoom.y <= 0:
		target_zoom.y = 0.1
	if target_zoom.x >= 2:
		target_zoom.x = 2
	if target_zoom.y >= 2:
		target_zoom.y = 2
	camera_2d.zoom = target_zoom
		  
	if Input.is_action_just_pressed("righ_click"):
		var planet = MASSIVE_OBJECT.instantiate()
		planet.position = get_global_mouse_position()
		planet.body_mass = Calculations.earth_mass
		add_child(planet)
		  
	if Input.is_action_just_pressed("e"):
		var planet = MASSIVE_OBJECT.instantiate()
		planet.position = get_global_mouse_position()
		planet.body_mass = Calculations.sun_mass
		add_child(planet)
		
