local ActionKind = require(script.Parent.Parent.ActionKind)

local Composite1d = {
	_actionKind = ActionKind.Axis1d,
}
Composite1d.__index = Composite1d

function Composite1d.new(options) -- TODO: assert controls are buttonControls
	return setmetatable({
		_positive = options.positive,
		_negative = options.negative,
	}, Composite1d)
end

function Composite1d:_getValue()
	local value = 0

	if self._positive:_getValue() then
		value += 1
	end

	if self._negative:_getValue() then
		value -= 1
	end

	return value
end

function Composite1d:_getActuation()
	return math.abs(self:_getValue())
end

return Composite1d
