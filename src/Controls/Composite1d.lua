local ActionKind = require(script.Parent.Parent.ActionKind)

--[=[
	@interface Composite1dOptions
	@within Composite1d
	.positive ButtonControl
	.negative ButtonControl
]=]

--[=[
	A Composite1d uses a positive and negative ButtonControl to mimic a Axis1dControl.

	If both the positive and negative controls are pressed, the Composite1d will have a value of 0.

	@class Composite1d
]=]
local Composite1d = {
	_actionKind = ActionKind.Axis1d,
}
Composite1d.__index = Composite1d

--[=[
	Creates a new Composite1d.

	```lua
	Composite1d.new({
		positive = Keyboard.W,
		negative = Keyboard.S,
	})
	```

	@param options Composite1dOptions
	@return Composite1d
]=]
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
