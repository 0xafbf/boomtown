extends Camera

var PanelArrow = preload("res://Scripts/PanelArrow.gd")
export var brush_path: NodePath
export var arrow_scene: PackedScene
onready var brush: Spatial = get_node(brush_path)

enum PlayMode {MODE_PLACEMENT, MODE_INTERACT}

var current_mode = PlayMode.MODE_PLACEMENT

var snap_size = Vector3(1,1,1)

func _ready():
	reset()
func play():
	current_mode = PlayMode.MODE_INTERACT
func reset():
	Global.register_object(self)
	current_mode = PlayMode.MODE_PLACEMENT

func _unhandled_input(event):
	if current_mode == PlayMode.MODE_PLACEMENT:
		var mouse_event = event as InputEventMouse
		var click_event:InputEventMouseButton = event as InputEventMouseButton
		var is_click = click_event && click_event.button_index == BUTTON_LEFT && !click_event.pressed
		if mouse_event:
			var origin = project_ray_origin(mouse_event.position)
			var normal = project_ray_normal(mouse_event.position)
			var target_point = origin + normal * 1000
			var space_state = get_world().direct_space_state
			var result = space_state.intersect_ray(origin, target_point,[], 1, true, true)
			
			var use_brush = true
			if result:
				var target = result["collider"]
				if target is PanelArrow:
					print(target)
					use_brush = false
					if is_click:
						target.rotation.y += TAU * 0.25
					
				if use_brush:
					var target_position = result["position"]
					target_position = target_position.snapped(snap_size)
					brush.translation = target_position
				
					if is_click:
						var new_arrow = arrow_scene.instance()
						get_node("/root").add_child(new_arrow)
						new_arrow.translation = target_position
			brush.visible = use_brush
			
	
	
	elif current_mode == PlayMode.MODE_INTERACT:
		var mouse_event = event as InputEventMouseButton
		if mouse_event and mouse_event.button_index == 1 and mouse_event.is_pressed():
	
			var origin = project_ray_origin(mouse_event.position)
			var normal = project_ray_normal(mouse_event.position)
			var target_point = origin + normal * 1000
			var space_state = get_world().direct_space_state
			var result = space_state.intersect_ray(origin, target_point)
			var target = result["collider"]
			if target is Powder:
				target.burn()
	
