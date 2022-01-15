local ActionKind = require(script.Parent.Parent.ActionKind)

local ButtonControl = {
	_actionKind = ActionKind.Button,
}
ButtonControl.__index = ButtonControl

function ButtonControl.new(inputType)
	return setmetatable({
		_inputType = inputType,
		_value = false,
		_actuation = 0,
	}, ButtonControl)
end

function ButtonControl:_update(input)
	self._value = input.UserInputState == Enum.UserInputState.Begin
	self._actuation = if self._value then 1 else 0
end

function ButtonControl:_getValue()
	return self._value
end

function ButtonControl:_getActuation()
	return self._actuation
end

return ButtonControl
