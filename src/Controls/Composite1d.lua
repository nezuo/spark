local ValueKind = require(script.Parent.Parent.ValueKind)

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

--[=[
	@prop positive ButtonControl
	@within Composite1d
]=]

--[=[
	@prop negative ButtonControl
	@within Composite1d
]=]
local Composite1d = {
	_valueKind = ValueKind.Number,
	_isComposite = true,
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
function Composite1d.new(options)
	return setmetatable({
		positive = options.positive, -- TODO: document
		negative = options.negative, -- TODO: document
	}, Composite1d)
end

function Composite1d:_getValue()
	local value = 0

	if self.positive ~= nil and self.positive:_getValue() then
		value += 1
	end

	if self.negative ~= nil and self.negative:_getValue() then
		value -= 1
	end

	return value
end

function Composite1d:_getActuation()
	return math.abs(self:_getValue())
end

return Composite1d
