local ValueKind = require(script.Parent.Parent.ValueKind)

local Axis1dInput = {
	_valueKind = ValueKind.Number,
}
Axis1dInput.__index = Axis1dInput

function Axis1dInput.new(device, path, inputType, transform, doesReset)
	return setmetatable({
		device = device,
		_path = path,
		_inputType = inputType,
		_transform = transform,
		_doesReset = doesReset,
		_value = 0,
		_actuation = 0,
	}, Axis1dInput)
end

function Axis1dInput:_update(inputObject)
	self._value = self._transform(inputObject)
	self._actuation = math.abs(self._value)
end

function Axis1dInput:_getValue()
	return self._value
end

function Axis1dInput:_getActuation()
	return self._actuation
end

return Axis1dInput
