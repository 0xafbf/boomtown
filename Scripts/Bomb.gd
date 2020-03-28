extends KinematicBody

enum {COLOR_BLUE, COLOR_RED}

export var speed = 5
export var placement_distance = 1

export var trail_template : PackedScene

var distance_since_last = 100

func _physics_process(delta):
	var velocity = transform.basis.z * speed
	velocity = move_and_slide(velocity)
	var distance = velocity.length() * delta
	distance_since_last += 	distance 
	if distance_since_last > placement_distance:
		distance_since_last = 0
		var trail_node = trail_template.instance()
		trail_node.translation = translation
		get_node("/root").add_child(trail_node)
