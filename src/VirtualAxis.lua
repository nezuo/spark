--[=[
	@prop positive Button?
	@within VirtualAxis
]=]

--[=[
	@prop negative Button?
	@within VirtualAxis
]=]

--[=[
	A virtual 1D axis input.

	If `positive` and `negative` are both pressed, the value will be `0`.

	@class VirtualAxis
]=]
local VirtualAxis = {}
VirtualAxis.__index = VirtualAxis

--[=[
	Creates a `VirtualAxis` with the corresponding `options`.

	@param options { postive: Button?, negative: Button? }
	@return VirtualAxis
]=]
function VirtualAxis.new(options)
	return setmetatable({
		kind = "VirtualAxis",
		positive = options.positive,
		negative = options.negative,
	}, VirtualAxis)
end

--[=[
	Creates a `VirtualAxis` corresponding to the left and right arrow keys.

	@return VirtualAxis
]=]
function VirtualAxis.horizontalArrowKeys()
	return VirtualAxis.new({
		positive = Enum.KeyCode.Right,
		negative = Enum.KeyCode.Left,
	})
end

--[=[
	Creates a `VirtualAxis` corresponding to the up and down arrow keys.

	@return VirtualAxis
]=]
function VirtualAxis.verticalArrowKeys()
	return VirtualAxis.new({
		positive = Enum.KeyCode.Up,
		negative = Enum.KeyCode.Down,
	})
end

return VirtualAxis
