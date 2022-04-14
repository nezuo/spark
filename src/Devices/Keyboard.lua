local ButtonInput = require(script.Parent.Parent.Inputs.ButtonInput)

--[=[
	Exports a ButtonInput for `KeyCode` 2 to 140. For example, `Keyboard.Space`.

	@class Keyboard
]=]
local Keyboard = {}

local keyCodes = Enum.KeyCode:GetEnumItems()
for index = 2, 140 do
	local keyCode = keyCodes[index]
	Keyboard[keyCode.Name] = ButtonInput.new(Keyboard, "Keyboard." .. keyCode.Name, keyCode)
end

return Keyboard
