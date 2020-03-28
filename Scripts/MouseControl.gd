extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	var mouse_event = event as InputEventMouseButton
	if mouse_event and mouse_event.button_index == 1 and mouse_event.is_pressed():

		var origin = project_ray_origin(mouse_event.position)
		var normal = project_ray_normal(mouse_event.position)
		var target_point = origin + normal * 1000
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(origin, target_point)
		print(result)
		var target = result["collider"]
		if target is Powder:
			target.burn()
		
