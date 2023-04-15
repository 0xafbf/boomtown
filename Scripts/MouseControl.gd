extends Camera

export var max_bombs = 5
export var max_arrows = 20

onready var PanelArrow = load("res://Scripts/PanelArrow.gd")
onready var Bomb = load("res://Scripts/Bomb.gd")
export var brush_path: NodePath
export var arrow_scene: PackedScene
export var bomb_scene: PackedScene

onready var current_scene = arrow_scene
onready var brush: Spatial = get_node(brush_path)

enum PlayMode {MODE_PLACEMENT, MODE_INTERACT}

var current_mode = PlayMode.MODE_PLACEMENT
var delete_mode = false
var started = false

var snap_size = Vector3(1,1,1)

func _ready():
	reset()
func play():
	current_mode = PlayMode.MODE_INTERACT
func reset():
	current_mode = PlayMode.MODE_PLACEMENT
	started = false


var start_drag_pos: Vector2 = Vector2.ZERO
var start_drag_pos_3d: Vector3 = Vector3.ZERO
var last_drag_pos: Vector2 = Vector2.ZERO

## pixels to drag to detect drag and not emit click events
export var drag_threshold: float = 10 
var dragging: bool = false
var pressed: bool = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		pressed = event.pressed
		if event.pressed:
			start_drag_pos = event.position
			var origin = project_ray_origin(start_drag_pos)
			var normal = project_ray_normal(start_drag_pos)
			var target_point = origin + normal * 1000
			var space_state = get_world().direct_space_state
			var result: Dictionary = space_state.intersect_ray(origin, target_point,[], 1, true, true)
			start_drag_pos_3d = result.position
			dragging = false
		else: # if event released
			if not dragging:
				event_clicked(event)
			dragging = false
	elif event is InputEventMouseMotion:
		if pressed:
			if not dragging:
				var dist = start_drag_pos.distance_to(event.position)
				if dist >= drag_threshold:
					dragging = true
					last_drag_pos = start_drag_pos
			
			if dragging:
				var prev_origin = project_ray_origin(last_drag_pos)
				var prev_normal = project_ray_normal(last_drag_pos)
				var curr_origin = project_ray_origin(event.position)
				var curr_normal = project_ray_normal(event.position)
				var plane = Plane(Vector3.UP, start_drag_pos_3d.y)
				
				var from_3d = plane.intersects_ray(prev_origin, prev_normal)
				var to_3d = plane.intersects_ray(curr_origin, curr_normal)
				if from_3d != null and to_3d != null:
					var delta: Vector3 = to_3d - from_3d
					get_parent().translation -= delta
				
				last_drag_pos = event.position
			
func event_clicked(mouse_event: InputEventMouseButton):
	if current_mode == PlayMode.MODE_PLACEMENT:
		var origin = project_ray_origin(mouse_event.position)
		var normal = project_ray_normal(mouse_event.position)
		var target_point = origin + normal * 1000
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(origin, target_point,[], 1, true, true)
		
		var use_brush = true
		if delete_mode:
			use_brush = false
		if result:
			var target = result["collider"]
			var is_bomb = target is Bomb
			var is_panel = target is PanelArrow
			if is_bomb or is_panel:
				if delete_mode:
					target.queue_free()
					if is_bomb:
						max_bombs += 1
					elif is_panel:
						max_arrows += 1
				else:
					target.rotation.y -= TAU * 0.25
					if is_bomb:
						target.save()
			else: # target is not bomb or panel
				var target_position = result["position"]
				target_position = target_position.snapped(snap_size)
				
				if target_position.y == 0:
					# only allow placement at surface level
					
					var new_scene = current_scene.instance()
					new_scene.translation = target_position
					get_node("/root").add_child(new_scene)
					
					if current_scene == arrow_scene:
						max_arrows -= 1
					elif current_scene == bomb_scene:
						max_bombs -= 1
					
	
	elif current_mode == PlayMode.MODE_INTERACT:
		var origin = project_ray_origin(mouse_event.position)
		var normal = project_ray_normal(mouse_event.position)
		var target_point = origin + normal * 1000
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(origin, target_point)
		if result:
			var target = result["collider"]
			if target is Powder:
				started = true
				target.burn()

export var cam_speed = 10

func _process(delta):
	
	$Control/TopBar/BtnArrow/Text.text = "%d" % max_arrows
	$Control/TopBar/BtnBomb/Text.text = "%d" % max_bombs
	
	$Control/ScoreScreen.visible = Global.report_now
	$Control/ScoreScreen/Container/TextScore.text = "%d" % Global.score
	
	if current_mode == PlayMode.MODE_INTERACT:
		brush.visible = false
		if not $Control/AudioRunning.playing:
			$Control/AudioRunning.playing = true
		$Control/AudioPlanning.playing = false
	elif current_mode == PlayMode.MODE_PLACEMENT:
		if not $Control/AudioPlanning.playing:
			 $Control/AudioPlanning.playing = true
		$Control/AudioRunning.playing = false

func _on_BtnArrow_pressed():
	brush.set_preview(brush.arrow)
	current_scene = arrow_scene
	delete_mode = false

func _on_BtnBomb_pressed():
	brush.set_preview(brush.bomb)
	current_scene = bomb_scene
	delete_mode = false

func _on_BtnDelete_pressed():
	delete_mode = true
	

