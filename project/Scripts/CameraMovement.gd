# ----------------------------------------------------------------------------------- #
# ---------------------- 3D PLATFORMER CONTROLLER BY SD STUDIOS --------------------- #
# ----------------------------------------------------------------------------------- #

extends Node3D

# ---------- VARIABLES ---------- #

# Control Mouse Sensitivity through inspector or from here
@export var mouse_sensitivity := 0.2
@export var key_rotate_speed := 120.0
@export var min_zoom := 0.6
@export var max_zoom := 1.6

# Assign Camera Node here it might be named different in your Project
@onready var camera = $Camera3D
@onready var base_offset : Vector3 = camera.position
var zoom := 1.0

# ---------- FUNCTIONS ---------- #

func _ready():
	top_level = true
	# Confining Mouse Cursor in the game view so it doesnt get in the way of gameplay
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# Optional keyboard camera rotation (Q / E) and smooth zoom
	if Input.is_action_pressed("cam_left"):
		rotation_degrees.y += key_rotate_speed * delta
	if Input.is_action_pressed("cam_right"):
		rotation_degrees.y -= key_rotate_speed * delta
	camera.position = camera.position.lerp(base_offset * zoom, delta * 8.0)

# Handling Camera Movement
func _unhandled_input(event):
	# Re-capture the mouse when clicking on the game (needed for web builds)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED and not get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = clamp(zoom - 0.1, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = clamp(zoom + 0.1, min_zoom, max_zoom)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -60, 10)

		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)
