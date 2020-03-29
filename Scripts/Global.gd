extends Node

var score = 0
var objects = []
var running = false


func run_all():
	running = true
	get_tree().call_group("simulate", "play")
	
func restore_all():
	running = false
	score = 0
	get_tree().call_group("simulate", "reset")
