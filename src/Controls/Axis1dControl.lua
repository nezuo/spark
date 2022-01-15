local ActionKind = require(script.Parent.Parent.ActionKind)

local Axis1dControl = {
	_actionKind = ActionKind.Axis1d,
}
Axis1dControl.__index = Axis1dControl

function Axis1dControl.new(inputType, transform, doesReset)
	return setmetatable({
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
