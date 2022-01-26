local ButtonControl = require(script.Parent.Parent.Controls.ButtonControl)
local Axis2dControl = require(script.Parent.Parent.Controls.Axis2dControl)

--[=[
	@class Gamepad
]=]

--[=[
	@prop North ButtonControl
	@within Gamepad
]=]

--[=[
	@prop West ButtonControl
	@within Gamepad
]=]

--[=[
	@prop South ButtonControl
	@within Gamepad
]=]

--[=[
	@prop East ButtonControl
	@within Gamepad
]=]

--[=[
	@prop Start ButtonControl
	@within Gamepad
]=]

--[=[
	@prop Select ButtonControl
	@within Gamepad
]=]

--[=[
	@prop DPadUp ButtonControl
	@within Gamepad
]=]

--[=[
	@prop DPadDown ButtonControl
	@within Gamepad
]=]

--[=[
	@prop DPadLeft ButtonControl
	@within Gamepad
]=]

--[=[
	@prop DPadRight ButtonControl
	@within Gamepad
]=]

--[=[
	@prop LeftBumper ButtonControl
	@within Gamepad
]=]

--[=[
	@prop LeftTrigger ButtonControl
	@within Gamepad
]=]

--[=[
	@prop LeftThumb ButtonControl
	@within Gamepad
]=]

--[=[
	@prop RightBumper ButtonControl
	@within Gamepad
]=]

--[=[
	@prop RightTrigger ButtonControl
	@within Gamepad
]=]

--[=[
	@prop RightThumb ButtonControl
	@within Gamepad
]=]

--[=[
	@prop LeftThumbstick Axis2dControl
	@within Gamepad
]=]

--[=[
	@prop RightThumbstick Axis2dControl
	@within Gamepad
]=]
return {
	North = ButtonControl.new("Gamepad.North", Enum.KeyCode.ButtonY),
	West = ButtonControl.new("Gamepad.West", Enum.KeyCode.ButtonX),
	South = ButtonControl.new("Gamepad.South", Enum.KeyCode.ButtonA),
	East = ButtonControl.new("Gamepad.East", Enum.KeyCode.ButtonB),
	Start = ButtonControl.new("Gamepad.Start", Enum.KeyCode.ButtonStart),
	Select = ButtonControl.new("Gamepad.Select", Enum.KeyCode.ButtonSelect),
	DPadUp = ButtonControl.new("Gamepad.DPadUp", Enum.KeyCode.DPadUp),
	DPadDown = ButtonControl.new("Gamepad.DPadDown", Enum.KeyCode.DPadDown),
	DPadLeft = ButtonControl.new("Gamepad.DPadLeft", Enum.KeyCode.DPadLeft),
	DPadRight = ButtonControl.new("Gamepad.DPadRight", Enum.KeyCode.DPadRight),
	LeftBumper = ButtonControl.new("Gamepad.LeftBumpber", Enum.KeyCode.ButtonL1),
	LeftTrigger = ButtonControl.new("Gamepad.LeftTrigger", Enum.KeyCode.ButtonL2),
	LeftThumb = ButtonControl.new("Gamepad.LeftThumb", Enum.KeyCode.ButtonL3),
	RightBumper = ButtonControl.new("Gamepad.RightBumper", Enum.KeyCode.ButtonR1),
	RightTrigger = ButtonControl.new("Gamepad.RightTrigger", Enum.KeyCode.ButtonR2),
	RightThumb = ButtonControl.new("Gamepad.RightThumb", Enum.KeyCode.ButtonR3),
	LeftThumbstick = Axis2dControl.new("Gamepad.LeftThumbstick", Enum.KeyCode.Thumbstick1, function(input)
		return Vector2.new(input.Position.X, input.Position.Y)
	end, false), -- TODO: This and RightThumbstick aren't normalized... should they be?
	RightThumbstick = Axis2dControl.new("Gamepad.RightThumbstick", Enum.KeyCode.Thumbstick2, function(input)
		return Vector2.new(input.Position.X, input.Position.Y)
	end, false),
}
