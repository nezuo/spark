local function scale(valueScale: number, axis2dScale: Vector2)
	return function(pressed, value, axis2d)
		return pressed, value * valueScale, axis2d * axis2dScale
	end
end

return scale
