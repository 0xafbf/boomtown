extends Node

var score = 0
var objects = []
var running = false
var burnt = false

func run_all():
	running = true
	get_tree().call_group("simulate", "play")
	
	
func restore_all():
	running = false
	score = 0
	get_tree().call_group("simulate", "reset")
	current_time_for_report = 0
	report_now = false
	burnt = false

var time_for_report = 3
var current_time_for_report = 0
var report_now = false

func _physics_process(delta):
	if running && burnt:
		current_time_for_report += delta
		if current_time_for_report > time_for_report:
			report_now = true

func report_action():
	current_time_for_report = 0
	
