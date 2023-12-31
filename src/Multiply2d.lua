--[=[
	An input that wraps an [Input2d] and multiplies its value by `multiplier`.

	```lua
	inputMap:insert("look", Multiply2d.new(Enum.UserInputType.MouseMovement, Vector2.new(0.5, 0.8)))
	```

	@class Multiply2d
]=]
local Multiply2d = {}
Multiply2d.__index = Multiply2d

--[=[
	Creates a new `Multiply2d` given a 2D `input` and `multiplier`.

	@param input Input2d
	@param multiplier Vector2
	@return Multiply2d
]=]
function Multiply2d.new(input, multiplier)
	return {
		kind = "Multiply2d",
		input = input,
		multiplier = multiplier,
	}
end

return Multiply2d
