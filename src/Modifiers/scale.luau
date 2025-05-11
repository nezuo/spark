--[=[
	Scales the axis and axis2d values by the given scale factors.

	Use this to adjust the sensitivity of the input.

	@param axisScale number
	@param axis2dScale Vector2
	@return Modifier
	@within Modifiers
]=]
local function scale(
	axisScale: number,
	axis2dScale: Vector2
): (pressed: boolean, axis: number, axis2d: Vector2) -> (boolean, number, Vector2)
	return function(pressed: boolean, axis: number, axis2d: Vector2)
		return pressed, axis * axisScale, axis2d * axis2dScale
	end
end

return scale
