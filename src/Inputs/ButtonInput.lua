local ValueKind = require(script.Parent.Parent.ValueKind)

local ButtonInput = {
	_valueKind = ValueKind.Boolean,
}
ButtonInput.__index = ButtonInput

function ButtonInput.new(device, path, inputType)
	return setmetatable({
		device = device,
		_path = path,
		_inputType = inputType,
		_value = false,
		_actuation = 0,
	}, ButtonInput)
end

function ButtonInput:_update(inputObject)
	self._value = inputObject.UserInputState == Enum.UserInputState.Begin
	self._actuation = if self._value then 1 else 0
end

function ButtonInput:_getValue()
	return self._value
end

function ButtonInput:_getActuation()
	return self._actuation
end

return ButtonInput
