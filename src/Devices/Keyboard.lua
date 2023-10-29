local ButtonInput = require(script.Parent.Parent.Inputs.ButtonInput)

--[=[
	Exports a ButtonInput for every `KeyCode`. For example, `Keyboard.Space`.

	@class Keyboard
]=]
local Keyboard = {}

for _, keyCode in Enum.KeyCode:GetEnumItems() do
	Keyboard[keyCode.Name] = ButtonInput.new(Keyboard, "Keyboard." .. keyCode.Name, keyCode)
end

return Keyboard
