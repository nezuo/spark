local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Spark = require(ReplicatedStorage.Packages.Spark)

local InputMap = Spark.InputMap
local VirtualAxis2d = Spark.VirtualAxis2d

local DEFAULT_INPUT_MAP =
	InputMap.new():insert("move", VirtualAxis2d.wasd()):insert("jump", Enum.KeyCode.ButtonA, Enum.KeyCode.Space)

local BINDINGS = {
	{ name = "Jump", action = "jump" },
	{ name = "Move Up", action = "move", direction = "up" },
	{ name = "Move Down", action = "move", direction = "down" },
	{ name = "Move Left", action = "move", direction = "left" },
	{ name = "Move Right", action = "move", direction = "right" },
}

local function getKeyboardMouseInput(inputMap, action)
	-- We use getByDevices to return the first input that belongs to either the Keyboard or Mouse.
	return inputMap:getByDevices(action, { "Keyboard", "Mouse" })[1]
end

local function rebind(inputMap, binding, newInput)
	local oldInput = getKeyboardMouseInput(inputMap, binding.action)
	if oldInput ~= nil then
		if binding.direction == nil then
			inputMap:remove(binding.action, oldInput)
		else
			-- Binding has a direction so we remove the specific direction from the VirtualAxis2d.
			oldInput[binding.direction] = nil
		end
	end

	-- If they chose Delete, we don't want to insert a new input.
	if newInput ~= Enum.KeyCode.Delete then
		if binding.direction == nil then
			inputMap:insert(binding.action, newInput)
		else
			-- Binding has a direction so we set the specific direction of the VirtualAxis2d to the new input .
			oldInput[binding.direction] = newInput
		end
	end
end

return {
	DEFAULT_INPUT_MAP = DEFAULT_INPUT_MAP,
	BINDINGS = BINDINGS,
	getKeyboardMouseInput = getKeyboardMouseInput,
	rebind = rebind,
}
