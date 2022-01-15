local ActionKind = require(script.Parent.Parent.ActionKind)

local Axis2dControl = {
	_actionKind = ActionKind.Axis2d,
}
Axis2dControl.__index = Axis2dControl

function Axis2dControl.new(inputType, transform, doesReset)
	return setmetatable({
		_inputType = inputType,
		_transform = transform,
		_doesReset = doesReset,
		_value = Vector2.zero,
		_actuation = 0,
	}, Axis2dControl)
end

function Axis2dControl:_update(input)
	self._value = self._transform(input)
	self._actuation = self._value.Magnitude
end

function Axis2dControl:_getValue()
	return self._value
end

function Axis2dControl:_getActuation()
	return self._actuation
end

return Axis2dControl
