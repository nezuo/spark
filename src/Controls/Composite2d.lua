local ActionKind = require(script.Parent.Parent.ActionKind)

local Composite2d = {
	_actionKind = ActionKind.Axis2d,
}
Composite2d.__index = Composite2d

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
