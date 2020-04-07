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

func _unhandled_input(event):
	if current_mode == PlayMode.MODE_PLACEMENT:
		$Control/Icons/IconErase.visible = false
		
		var mouse_event = event as InputEventMouse
		var click_event:InputEventMouseButton = event as InputEventMouseButton
		var is_click = click_event && click_event.button_index == BUTTON_LEFT && !click_event.pressed
		if mouse_event:
			$Control/Icons.rect_position = mouse_event.position
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
					use_brush = false
					$Control/Icons.visible = true
					$Control/Icons/IconErase.visible = delete_mode
					$Control/Icons/IconRotate.visible = !delete_mode
					$Control/Icons/IconFire.visible = false
					
					if is_click:
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
				else:
					$Control/Icons.visible = false
					
				if current_scene == arrow_scene and max_arrows < 1:
					use_brush = false
				elif current_scene == bomb_scene and max_bombs < 1:
					use_brush = false
				
				if use_brush:
					var target_position = result["position"]
					target_position = target_position.snapped(snap_size)
					if target_position.y != 0:
						use_brush = false
					else:
						brush.translation = target_position
						if is_click:
							
							var new_scene = current_scene.instance()
							new_scene.translation = target_position
							get_node("/root").add_child(new_scene)
							
							if current_scene == arrow_scene:
								max_arrows -= 1
							elif current_scene == bomb_scene:
								max_bombs -= 1
						
			brush.visible = use_brush
			
	
	elif current_mode == PlayMode.MODE_INTERACT:
		$Control/Icons.visible = false
		brush.visible = false
		var mouse_event = event as InputEventMouse
		if mouse_event:
			$Control/Icons.rect_position = mouse_event.position
			var origin = project_ray_origin(mouse_event.position)
			var normal = project_ray_normal(mouse_event.position)
			var target_point = origin + normal * 1000
			var space_state = get_world().direct_space_state
			var result = space_state.intersect_ray(origin, target_point)
			if result:
				var target = result["collider"]
				if target is Powder:
					$Control/Icons.visible = true
					$Control/Icons/IconErase.visible = false
					$Control/Icons/IconRotate.visible = false
					$Control/Icons/IconFire.visible = true
					if mouse_event is InputEventMouseButton and mouse_event.button_index == 1 and mouse_event.is_pressed():
						if not started:
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
	

