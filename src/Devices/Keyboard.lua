local ButtonControl = require(script.Parent.Parent.Controls.ButtonControl)

local Keyboard = {}

local keyCodes = Enum.KeyCode:GetEnumItems()
for index = 2, 140 do
	local keyCode = keyCodes[index]
	Keyboard[keyCode.Name] = ButtonControl.new(keyCode)
end

return Keyboard
