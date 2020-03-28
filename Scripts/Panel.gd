extends Area


func _ready():
	connect("body_entered", self, "body_entered")

func body_entered(body):
	print(body)
