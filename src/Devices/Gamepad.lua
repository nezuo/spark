local ButtonInput = require(script.Parent.Parent.Inputs.ButtonInput)
local Axis2dInput = require(script.Parent.Parent.Inputs.Axis2dInput)

--[=[
	@class Gamepad
]=]

--[=[
	@prop North ButtonInput
	@within Gamepad
]=]

--[=[
	@prop West ButtonInput
	@within Gamepad
]=]

--[=[
	@prop South ButtonInput
	@within Gamepad
]=]

--[=[
	@prop East ButtonInput
	@within Gamepad
]=]

--[=[
	@prop Start ButtonInput
	@within Gamepad
]=]

--[=[
	@prop Select ButtonInput
	@within Gamepad
]=]

--[=[
	@prop DPadUp ButtonInput
	@within Gamepad
]=]

--[=[
	@prop DPadDown ButtonInput
	@within Gamepad
]=]

--[=[
	@prop DPadLeft ButtonInput
	@within Gamepad
]=]

--[=[
	@prop DPadRight ButtonInput
	@within Gamepad
]=]

--[=[
	@prop LeftBumper ButtonInput
	@within Gamepad
]=]

--[=[
	@prop LeftTrigger ButtonInput
	@within Gamepad
]=]

--[=[
	@prop LeftThumb ButtonInput
	@within Gamepad
]=]

--[=[
	@prop RightBumper ButtonInput
	@within Gamepad
]=]

--[=[
	@prop RightTrigger ButtonInput
	@within Gamepad
]=]

--[=[
	@prop RightThumb ButtonInput
	@within Gamepad
]=]

--[=[
	@prop LeftThumbstick Axis2dInput
	@within Gamepad
]=]

--[=[
	@prop RightThumbstick Axis2dInput
	@within Gamepad
]=]
local Gamepad = {}
Gamepad.North = ButtonInput.new(Gamepad, "Gamepad.North", Enum.KeyCode.ButtonY)
Gamepad.West = ButtonInput.new(Gamepad, "Gamepad.West", Enum.KeyCode.ButtonX)
Gamepad.South = ButtonInput.new(Gamepad, "Gamepad.South", Enum.KeyCode.ButtonA)
Gamepad.East = ButtonInput.new(Gamepad, "Gamepad.East", Enum.KeyCode.ButtonB)
Gamepad.Start = ButtonInput.new(Gamepad, "Gamepad.Start", Enum.KeyCode.ButtonStart)
Gamepad.Select = ButtonInput.new(Gamepad, "Gamepad.Select", Enum.KeyCode.ButtonSelect)
Gamepad.DPadUp = ButtonInput.new(Gamepad, "Gamepad.DPadUp", Enum.KeyCode.DPadUp)
Gamepad.DPadDown = ButtonInput.new(Gamepad, "Gamepad.DPadDown", Enum.KeyCode.DPadDown)
Gamepad.DPadLeft = ButtonInput.new(Gamepad, "Gamepad.DPadLeft", Enum.KeyCode.DPadLeft)
Gamepad.DPadRight = ButtonInput.new(Gamepad, "Gamepad.DPadRight", Enum.KeyCode.DPadRight)
Gamepad.LeftBumper = ButtonInput.new(Gamepad, "Gamepad.LeftBumpber", Enum.KeyCode.ButtonL1)
Gamepad.LeftTrigger = ButtonInput.new(Gamepad, "Gamepad.LeftTrigger", Enum.KeyCode.ButtonL2)
Gamepad.LeftThumb = ButtonInput.new(Gamepad, "Gamepad.LeftThumb", Enum.KeyCode.ButtonL3)
Gamepad.RightBumper = ButtonInput.new(Gamepad, "Gamepad.RightBumper", Enum.KeyCode.ButtonR1)
Gamepad.RightTrigger = ButtonInput.new(Gamepad, "Gamepad.RightTrigger", Enum.KeyCode.ButtonR2)
Gamepad.RightThumb = ButtonInput.new(Gamepad, "Gamepad.RightThumb", Enum.KeyCode.ButtonR3)
Gamepad.LeftThumbstick = Axis2dInput.new(
	Gamepad,
	"Gamepad.LeftThumbstick",
	Enum.KeyCode.Thumbstick1,
	function(inputObject)
		return Vector2.new(inputObject.Position.X, inputObject.Position.Y)
	end,
	false
) -- TODO: This and RightThumbstick aren't normalized... should they be?
Gamepad.RightThumbstick = Axis2dInput.new(
	Gamepad,
	"Gamepad.RightThumbstick",
	Enum.KeyCode.Thumbstick2,
	function(inputObject)
		return Vector2.new(inputObject.Position.X, inputObject.Position.Y)
	end,
	false
)

return Gamepad
