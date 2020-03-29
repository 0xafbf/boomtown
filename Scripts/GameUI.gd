extends ColorRect

func _ready():
	$ButtonPlay.connect("pressed", self, "on_play")
	$ButtonStop.connect("pressed", self, "on_stop")
	
func on_play():
	Global.run_all()
	
func on_stop():
	Global.restore_all()

func _process(_delta):
	$TextScore.text = "%d" % Global.score
