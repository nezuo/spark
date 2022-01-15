local Axis1dControl = require(script.Parent.Parent.Controls.Axis1dControl)
local Axis2dControl = require(script.Parent.Parent.Controls.Axis2dControl)
local ButtonControl = require(script.Parent.Parent.Controls.ButtonControl)

return {
	LeftButton = ButtonControl.new(Enum.UserInputType.MouseButton1),
	RightButton = ButtonControl.new(Enum.UserInputType.MouseButton2),
	MiddleButton = ButtonControl.new(Enum.UserInputType.MouseButton3),
	ScrollWheel = Axis1dControl.new(Enum.UserInputType.MouseWheel, function(input)
		return input.Position.Z
	end, true),
	Delta = Axis2dControl.new(Enum.UserInputType.MouseMovement, function(input)
		return Vector2.new(input.Delta.X, input.Delta.Y)
	end, true),
}
