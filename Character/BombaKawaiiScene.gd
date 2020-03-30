extends Spatial



func walk(amount: float):
	var node: AnimationTree = $AnimationTree
	node["parameters/moving/blend_amount"] = amount
