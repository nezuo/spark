local ValueKind = require(script.Parent.Parent.ValueKind)

local Axis2dInput = {
	_valueKind = ValueKind.Vector2,
}
Axis2dInput.__index = Axis2dInput

function Axis2dInput.new(device, path, inputType, transform, doesReset)
	return setmetatable({
		device = device,
		_path = path,
		_inputType = inputType,
		_transform = transform,
		_doesReset = doesReset,
		_value = Vector2.zero,
		_actuation = 0,
	}, Axis2dInput)
end

function Axis2dInput:_update(inputObject)
	self._value = self._transform(inputObject)
	self._actuation = self._value.Magnitude
end

function Axis2dInput:_getValue()
	return self._value
end

function Axis2dInput:_getActuation()
	return self._actuation
end

return Axis2dInput
