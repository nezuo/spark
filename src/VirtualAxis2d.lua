--[=[
	@prop up Button?
	@within VirtualAxis2d
]=]

--[=[
	@prop down Button?
	@within VirtualAxis2d
]=]

--[=[
	@prop left Button?
	@within VirtualAxis2d
]=]

--[=[
	@prop right Button?
	@within VirtualAxis2d
]=]

--[=[
	A virtual 2D axis input.

	If `up` and `down` are both pressed, the `Y` value will be `0`. If `left` and `right` are both presed, the `X` value will be `0`.

	@class VirtualAxis2d
]=]
local VirtualAxis2d = {}
VirtualAxis2d.__index = VirtualAxis2d

--[=[
	Creates a `VirtualAxis2d` with the corresponding `options`.

	@param options { up: Button?, down: Button?, left: Button?, right: Button? }
	@return VirtualAxis2d
]=]
function VirtualAxis2d.new(options)
	return setmetatable({
		kind = "VirtualAxis2d",
		up = options.up,
		down = options.down,
		left = options.left,
		right = options.right,
	}, VirtualAxis2d)
end

--[=[
	Creates a `VirtualAxis2d` corresponding to the arrow keys.

	@return VirtualAxis2d
]=]
function VirtualAxis2d.arrowKeys()
	return VirtualAxis2d.new({
		up = Enum.KeyCode.Up,
		down = Enum.KeyCode.Down,
		left = Enum.KeyCode.Left,
		right = Enum.KeyCode.Right,
	})
end

--[=[
	Creates a `VirtualAxis2d` corresponding to the `WASD` keys.

	@return VirtualAxis2d
]=]
function VirtualAxis2d.wasd()
	return VirtualAxis2d.new({
		up = Enum.KeyCode.W,
		down = Enum.KeyCode.S,
		left = Enum.KeyCode.A,
		right = Enum.KeyCode.D,
	})
end

--[=[
	Creates a `VirtualAxis2d` corresponding to the `DPad` on gamepads.

	@return VirtualAxis2d
]=]
function VirtualAxis2d.dPad()
	return VirtualAxis2d.new({
		up = Enum.KeyCode.DPadUp,
		down = Enum.KeyCode.DPadDown,
		left = Enum.KeyCode.DPadLeft,
		right = Enum.KeyCode.DPadRight,
	})
end

return VirtualAxis2d
