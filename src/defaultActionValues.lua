local ActionKind = require(script.Parent.ActionKind)

return {
	[ActionKind.Button] = false,
	[ActionKind.Axis1d] = 0,
	[ActionKind.Axis2d] = Vector2.new(0, 0),
}
