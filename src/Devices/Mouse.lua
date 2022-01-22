local Axis1dControl = require(script.Parent.Parent.Controls.Axis1dControl)
local Axis2dControl = require(script.Parent.Parent.Controls.Axis2dControl)
local ButtonControl = require(script.Parent.Parent.Controls.ButtonControl)

--[=[
	@class Mouse
]=]

--[=[
	@prop LeftButton ButtonControl
	@within Mouse
]=]

--[=[
	@prop RightButton ButtonControl
	@within Mouse
]=]

--[=[
	@prop MiddleButton ButtonControl
	@within Mouse
]=]

--[=[
	@prop ScrollWheel Axis1dControl
	@within Mouse
]=]

--[=[
	@prop Delta Axis2dControl
	@within Mouse
]=]
return {
	LeftButton = ButtonControl.new("Mouse.LeftButton", Enum.UserInputType.MouseButton1),
	RightButton = ButtonControl.new("Mouse.RightButton", Enum.UserInputType.MouseButton2),
	MiddleButton = ButtonControl.new("Mouse.MiddleButton", Enum.UserInputType.MouseButton3),
	ScrollWheel = Axis1dControl.new("Mouse.ScrollWheel", Enum.UserInputType.MouseWheel, function(input)
		return input.Position.Z
	end, true),
	Delta = Axis2dControl.new("Mouse.Delta", Enum.UserInputType.MouseMovement, function(input)
		return Vector2.new(input.Delta.X, input.Delta.Y)
	end, true),
}
