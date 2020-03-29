extends StaticBody
class_name Destructible
export var score = 5
export var intact_path: NodePath
export var destroyed_path: NodePath

onready var intact_object: Spatial = get_node(intact_path)
onready var destroyed_object: Spatial = get_node(destroyed_path)

var destroyed: bool = false
	

func reset():
	destroyed = false
	intact_object.visible = !destroyed
	destroyed_object.visible = destroyed
	
func destroy():
	if destroyed:
		return
	destroyed = true
	
	intact_object.visible = !destroyed
	destroyed_object.visible = destroyed
	Global.score += score
	
