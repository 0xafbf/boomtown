extends Area

var current_bomb:Bomb = null
var current_distance = 0


func play():
	pass
func reset():
	current_bomb = null

func _ready():
	var _key = connect("body_entered", self, "body_entered")

func body_entered(body):
	if body is Bomb:
		current_bomb = body
		current_distance = (current_bomb.translation - translation).length_squared()
		
func _physics_process(_delta):
	if current_bomb:
		var new_distance = (current_bomb.translation - translation).length_squared()
		if new_distance > current_distance:
			# we passed the center, so change direction now
			current_bomb.rotation.y = rotation.y
			current_bomb = null
		else :
			current_distance = new_distance
