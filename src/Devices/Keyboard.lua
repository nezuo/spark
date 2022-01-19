local ButtonControl = require(script.Parent.Parent.Controls.ButtonControl)

--[=[
	Exports a ButtonControl for `KeyCode` 2 to 140. For example, `Keyboard.Space`.

	@class Keyboard
]=]
local Keyboard = {}

local keyCodes = Enum.KeyCode:GetEnumItems()
for index = 2, 140 do
	local keyCode = keyCodes[index]
	Keyboard[keyCode.Name] = ButtonControl.new(keyCode)
end

return Keyboard
