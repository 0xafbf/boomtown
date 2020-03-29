extends Spatial

onready var arrow = $BrushArrow
onready var bomb = $BrushBomb

func set_preview(element):
	arrow.visible = (element == arrow)
	bomb.visible = (element == bomb)
	
