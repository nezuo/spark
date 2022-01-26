local ValueKind = require(script.Parent.Parent.ValueKind)

--[=[
	@interface Composite2dOptions
	@within Composite2d
	.up ButtonControl
	.down ButtonControl
	.left ButtonControl
	.right ButtonControl
]=]

--[=[
	A Composite2d uses a up, down, left, and right ButtonControl to mimic a Axis2dControl.

	The value of the Composite2d is normalized. If the up and down controls or the left and right controls are both pressed that axis will be 0.

	@class Composite2d
]=]

--[=[
	@prop up ButtonControl
	@within Composite2d
]=]

--[=[
	@prop down ButtonControl
	@within Composite2d
]=]

--[=[
	@prop left ButtonControl
	@within Composite2d
]=]

--[=[
	@prop right ButtonControl
	@within Composite2d
]=]
local Composite2d = {
	_valueKind = ValueKind.Vector2,
	_isComposite = true,
}
Composite2d.__index = Composite2d

--[=[
	Creates a new Composite2d.

	```lua
	Composite2d.new({
		up = Keyboard.W,
		down = Keyboard.S,
		left = Keyboard.A,
		right = Keyboard.D,
	})
	```

	@param options Composite2dOptions
	@return Composite2d
]=]
function Composite2d.new(options)
	return setmetatable({
		up = options.up,
		down = options.down,
		left = options.left,
		right = options.right,
	}, Composite2d)
end

function Composite2d:_getValue()
	local x = 0
	local y = 0

	if self.up:_getValue() then
		y += 1
	end

	if self.down:_getValue() then
		y -= 1
	end

	if self.left:_getValue() then
		x -= 1
	end

	if self.right:_getValue() then
		x += 1
	end

	if x ~= 0 or y ~= 0 then
		return Vector2.new(x, y).Unit
	else
		return Vector2.zero
	end
end

function Composite2d:_getActuation()
	return self:_getValue().Magnitude
end

return Composite2d
