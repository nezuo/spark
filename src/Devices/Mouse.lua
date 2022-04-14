local Axis1dInput = require(script.Parent.Parent.Inputs.Axis1dInput)
local Axis2dInput = require(script.Parent.Parent.Inputs.Axis2dInput)
local ButtonInput = require(script.Parent.Parent.Inputs.ButtonInput)

--[=[
	@class Mouse
]=]

--[=[
	@prop LeftButton ButtonInput
	@within Mouse
]=]

--[=[
	@prop RightButton ButtonInput
	@within Mouse
]=]

--[=[
	@prop MiddleButton ButtonInput
	@within Mouse
]=]

--[=[
	@prop ScrollWheel Axis1dInput
	@within Mouse
]=]

--[=[
	@prop Delta Axis2dInput
	@within Mouse
]=]
local Mouse = {}

Mouse.LeftButton = ButtonInput.new(Mouse, "Mouse.LeftButton", Enum.UserInputType.MouseButton1)
Mouse.RightButton = ButtonInput.new(Mouse, "Mouse.RightButton", Enum.UserInputType.MouseButton2)
Mouse.MiddleButton = ButtonInput.new(Mouse, "Mouse.MiddleButton", Enum.UserInputType.MouseButton3)
Mouse.ScrollWheel = Axis1dInput.new(Mouse, "Mouse.ScrollWheel", Enum.UserInputType.MouseWheel, function(inputObject)
	return inputObject.Position.Z
end, true)
Mouse.Delta = Axis2dInput.new(Mouse, "Mouse.Delta", Enum.UserInputType.MouseMovement, function(inputObject)
	return Vector2.new(inputObject.Delta.X, inputObject.Delta.Y)
end, true)

return Mouse
