local getDeviceFromInput = require(script.Parent.getDeviceFromInput)

local function push(list, value)
	local new = table.clone(list)

	table.insert(new, value)

	return table.freeze(new)
end

local function removeValue(list, value)
	local new = {}

	for _, v in list do
		if v ~= value then
			table.insert(new, v)
		end
	end

	return table.freeze(new)
end

local function isInputInDevices(input, devices)
	if typeof(input) == "table" then
		if input.kind == "VirtualAxis" then
			for _, direction in { "positive", "negative" } do
				if table.find(devices, getDeviceFromInput(input[direction])) then
					return true
				end
			end
		elseif input.kind == "VirtualAxis2d" then
			for _, direction in { "up", "down", "left", "right" } do
				if table.find(devices, getDeviceFromInput(input[direction])) then
					return true
				end
			end
		end
	end

	return table.find(devices, getDeviceFromInput(input)) ~= nil
end

local function deepCopy(original)
	local copy = setmetatable({}, getmetatable(original))

	for key, value in original do
		if type(value) == "table" then
			local tableCopy = deepCopy(value)

			setmetatable(tableCopy, getmetatable(value))

			copy[key] = tableCopy
		else
			copy[key] = value
		end
	end

	return copy
end

--[=[
	If `associatedGamepad` is nil, the connected gamepad with the lowest number will be used.

	The [Enum.UserInputType] must represent a gamepad.

	@prop associatedGamepad Enum.UserInputType?
	@within InputMap
]=]

--[=[
	Maps actions to their inputs.

	Multiple inputs can be mapped to the same action and each input can be mapped to multiple actions.

	```lua
	local inputMap = InputMap.new()
		:insert("fire", Enum.UserInputType.MouseButton1)
		:insert("jump", Enum.KeyCode.Space)
	```

	@class InputMap
]=]
local InputMap = {}
InputMap.__index = InputMap

--[=[
	Creates an empty InputMap.

	@return InputMap
]=]
function InputMap.new()
	return setmetatable({
		map = {},
	}, InputMap)
end

--[=[
	Maps inputs to `action`.

	If an input is already mapped to the `action`, it won't be mapped again.

	@param action string
	@param ... Input
	@return InputMap -- Returns self
]=]
function InputMap:insert(action, ...)
	if self.map[action] == nil then
		self.map[action] = table.freeze({})
	end

	for _, input in { ... } do
		if not table.find(self.map[action], input) then
			self.map[action] = push(self.map[action], input)
		end
	end

	return self
end

--[=[
	Removes the mapping from `input` to `action` if it exists.

	@param action string
	@param input Input
]=]
function InputMap:remove(action, input)
	local inputs = self.map[action]

	if inputs == nil then
		return
	end

	self.map[action] = removeValue(inputs, input)
end

--[=[
	Gets the inputs mapped to `action`.

	@param action string
	@return { Input }
]=]
function InputMap:get(action)
	if self.map[action] == nil then
		return table.freeze({})
	end

	return self.map[action]
end

--[=[
	Gets the inputs mapped to `action` that belong to `devices`.

	If a [VirtualAxis] or [VirtualAxis2d] has a [Button] that belongs to `devices` it will be included.

	```lua
	local inputMap = InputMap.new():insert("action", Enum.KeyCode.Space, Enum.UserInputType.MouseButton1)

	print(inputMap:getByDevices("action", { "Keyboard" })) -- { Enum.KeyCode.Space }
	print(inputMap:getByDevices("action", { "Mouse" })) -- { Enum.UserInputType.MouseButton1 }
	```

	@param action string
	@param devices { Device }
	@return { Input }
]=]
function InputMap:getByDevices(action, devices)
	if self.map[action] == nil then
		return table.freeze({})
	end

	local inputs = {}
	for _, input in self.map[action] do
		if isInputInDevices(input, devices) then
			table.insert(inputs, input)
		end
	end

	return table.freeze(inputs)
end

--[=[
	Clones the `InputMap`.

	@return InputMap
]=]
function InputMap:clone()
	return deepCopy(self)
end

return InputMap
