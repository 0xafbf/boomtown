extends StaticBody
class_name Powder

export var burn_time = 0.5
var connected_powder = []
var current_burn_time = 0
export var burning: bool = false
var bomb = null
var burnt = false

func _ready():
	var space_state = get_world().direct_space_state
	var query_params = PhysicsShapeQueryParameters.new()
	query_params.set_shape($CollisionShape.shape)
	query_params.transform = $CollisionShape.global_transform
	
	query_params.collision_mask = 2
	query_params.collide_with_bodies = true
	var results = space_state.intersect_shape(query_params)
	
	for result in results:
		var area = result["collider"]
		if area == self: 
			continue
		
		if typeof(self) == typeof(area):
			connected_powder.append(area)
			if !area.connected_powder.has(self):
				area.connected_powder.append(self)
		
func _physics_process(delta):
	if burnt:
		return
	if burning:
		current_burn_time += delta
		if current_burn_time > burn_time:
			for powder in connected_powder:
				powder.burn()
			if bomb:
				bomb.explode()
			burnt = true
				
				
func burn():
	burning = true
	$CollisionShape/MeshInstance2.visible = true
