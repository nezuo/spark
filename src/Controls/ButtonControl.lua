local ValueKind = require(script.Parent.Parent.ValueKind)

local ButtonControl = {
	_valueKind = ValueKind.Boolean,
}
ButtonControl.__index = ButtonControl

function ButtonControl.new(path, inputType)
	return setmetatable({
		_path = path,
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
