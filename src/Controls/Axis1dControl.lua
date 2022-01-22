local ValueKind = require(script.Parent.Parent.ValueKind)

local Axis1dControl = {
	_valueKind = ValueKind.Number,
}
Axis1dControl.__index = Axis1dControl

function Axis1dControl.new(path, inputType, transform, doesReset)
	return setmetatable({
		_path = path,
		_inputType = inputType,
		_transform = transform,
		_doesReset = doesReset,
		_value = 0,
		_actuation = 0,
	}, Axis1dControl)
end

function Axis1dControl:_update(input)
	self._value = self._transform(input)
	self._actuation = math.abs(self._value)
end

function Axis1dControl:_getValue()
	return self._value
end

function Axis1dControl:_getActuation()
	return self._actuation
end

return Axis1dControl
