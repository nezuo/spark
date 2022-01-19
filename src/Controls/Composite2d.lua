local ActionKind = require(script.Parent.Parent.ActionKind)

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
local Composite2d = {
	_actionKind = ActionKind.Axis2d,
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
		_up = options.up,
		_down = options.down,
		_left = options.left,
		_right = options.right,
	}, Composite2d)
end

function Composite2d:_getValue()
	local x = 0
	local y = 0

	if self.up:_getValue() then
		x += 1
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

	if x ~= 0 or y ~= nil then
		return Vector2.new(x, y).Unit
	else
		return Vector2.zero
	end
end

function Composite2d:_getActuation(value)
	return value.Magnitude
end

return Composite2d
