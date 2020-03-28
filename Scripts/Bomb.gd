extends KinematicBody
class_name Bomb

enum {COLOR_BLUE, COLOR_RED}

export var speed = 5
export var placement_distance = 1

export var trail_template : PackedScene

var distance_since_last = 100
var last_placed_powder
var destroyed = false

func _physics_process(delta):
	if destroyed:
		return
		
	var velocity = transform.basis.z * speed
	velocity = move_and_slide(velocity)
	var distance = velocity.length() * delta
	distance_since_last += 	distance 
	if distance_since_last > placement_distance:
		distance_since_last = 0
		
		if last_placed_powder:
			last_placed_powder.bomb = null
		
		last_placed_powder = trail_template.instance()
		last_placed_powder.translation = translation
		get_node("/root").add_child(last_placed_powder)
		last_placed_powder.bomb = self

func explode():
	$CollisionShape/Particles.emitting = true
	destroyed = true
