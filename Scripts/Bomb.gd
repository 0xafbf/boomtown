extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum {COLOR_BLUE, COLOR_RED}

export var speed = 5
export var placement_distance = 1

export var trail_template : PackedScene

var distance_since_last = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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
