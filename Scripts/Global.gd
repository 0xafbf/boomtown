extends Node

var score = 0
var objects = []
var running = false

func register_object(ob):
	objects.append(ob)

func run_all():
	if running:
		return
	running = true
	for obj in objects:
		obj.play()
	
func restore_all():
	score = 0
	var old_objects = objects
	objects = []
	for obj in old_objects:
		obj.reset()
	running = false
