local function scaledDeadZone(value: number, lowerThreshold: number): number
	local lowerBound = math.max(math.abs(value) - lowerThreshold, 0)
	local scaledValue = lowerBound / (1 - lowerThreshold)

	return math.min(scaledValue, 1) * math.sign(value)
end

--[=[
	Applies a deadzone to the input, then rescales the remainder to 0-1.

	* Radial: Applies the deadzone to the magnitude of the vector which preserves the direction.
	* Axial: Applies the deadzone to each axis independently which yields a square region.

	For a deeper comparison, see:
	<https://www.gamedeveloper.com/business/doing-thumbstick-dead-zones-right>

	@param kind "Radial" | "Axial" -- The shape of the deadzone
	@param lowerThreshold number -- Threshold to cut off the input
	@return Modifier
	@within Modifiers
]=]
local function deadZone(
	kind: "Radial" | "Axial",
	lowerThreshold: number
): (pressed: boolean, axis: number, axis2d: Vector2) -> (boolean, number, Vector2)
	assert(lowerThreshold < 1, "lowerThreshold must be < 1")

	return function(pressed: boolean, axis: number, axis2d: Vector2)
		local newAxis = scaledDeadZone(axis, lowerThreshold)

		local newAxis2d = Vector2.zero
		if kind == "Axial" then
			local x = scaledDeadZone(axis2d.X, lowerThreshold)
			local y = scaledDeadZone(axis2d.Y, lowerThreshold)

			newAxis2d = Vector2.new(x, y)
		elseif kind == "Radial" then
			local magnitude = axis2d.Magnitude

			if magnitude == 0 then
				newAxis2d = Vector2.zero
			else
				newAxis2d = axis2d.Unit * scaledDeadZone(magnitude, lowerThreshold)
			end
		end

		return pressed and (math.abs(newAxis) > 0 or newAxis2d.Magnitude > 0), newAxis, newAxis2d
	end
end

return deadZone
