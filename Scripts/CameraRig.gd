extends Spatial

onready var camera = $Camera
export var base_distance: float = 20.0

onready var desired_distance: float = base_distance
onready var current_distance: float = base_distance

var zoom_level: float = 0
# max steps of zoom in/out
export var max_zoom = 4.0
# how much zoom does each step does
export var zoom_exponent = 1.2

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			var new_zoom = 0.0
			if event.button_index == BUTTON_WHEEL_UP:
				new_zoom = -event.factor
			elif event.button_index == BUTTON_WHEEL_DOWN:
				new_zoom = event.factor
			if new_zoom != 0.0:
				zoom_level += new_zoom
				zoom_level = clamp(zoom_level, -max_zoom, max_zoom)
				desired_distance = base_distance * pow(zoom_exponent, zoom_level)

export var cam_blend_speed: float = 10.0
export var cam_speed: float = 20

func _process(delta):
	var factor = cam_blend_speed * delta
	current_distance = lerp(current_distance, desired_distance, factor)
	camera.translation.z = current_distance

	var right = Input.get_action_strength("right") - Input.get_action_strength("left")
	var forward = Input.get_action_strength("forward") - Input.get_action_strength("back")

	var right_direction = (-global_transform.basis.z).cross(Vector3.UP)
	var fwd_direction = Vector3.UP.cross(global_transform.basis.x)

	var movement = right * right_direction.normalized()
	movement += forward * fwd_direction.normalized()

	translation += delta * cam_speed * movement * pow(zoom_exponent, zoom_level)
