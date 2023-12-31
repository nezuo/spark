local Deserializer = require(script.Parent.Serialization.Deserializer)
local Serializer = require(script.Parent.Serialization.Serializer)
local getDeviceFromInput = require(script.Parent.getDeviceFromInput)

local HEADER = "SPARK"
local SERIALIZATION_VERSION = 0

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
	Deserializes the buffer returned from [InputMap:serialize] back into an InputMap.

	@param serialized buffer
	@return InputMap
]=]
function InputMap.deserialize(serialized)
	local deserializer = Deserializer.new(serialized)

	local header = deserializer:readString(#HEADER)
	local version = deserializer:readU8()

	if header ~= HEADER then
		error("Invalid header", 2)
	end

	if version ~= SERIALIZATION_VERSION then
		error("Invalid serialization version", 2)
	end

	local inputMap = InputMap.new()

	while not deserializer:empty() do
		local action, inputCount = deserializer:readActionHeader()

		for _ = 1, inputCount do
			local input = deserializer:readInput()

			inputMap:insert(action, input)
		end
	end

	return inputMap
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

--[=[
	Returns a serialized version of the `InputMap` as a buffer. This can be used to save or replicate it.

	@return buffer
]=]
function InputMap:serialize()
	local length = #HEADER + 1 -- 1 byte for the version.

	for action, inputs in self.map do
		length += 2 + #action -- The 2 accounts for the length of the name and the input count.

		for _, input in inputs do
			length += 1 -- This accounts for the input kind.

			if typeof(input) == "EnumItem" then
				length += 2
			elseif input.kind == "Multiply2d" then
				length += 3 + 16 -- This accounts for the 3 byte input and the 16 byte Vector2 sensitivity.
			elseif input.kind == "VirtualAxis" then
				length += 2 * 3 -- This accounts for two 3 byte inputs.
			elseif input.kind == "VirtualAxis2d" then
				length += 4 * 3 -- This accounts for four 3 byte inputs.
			end
		end
	end

	local serialized = buffer.create(length)
	local serializer = Serializer.new(serialized)

	serializer:writeString(HEADER)
	serializer:writeU8(SERIALIZATION_VERSION)

	for action, inputs in self.map do
		local inputCount = 0
		for _ in inputs do
			inputCount += 1
		end

		serializer:writeActionHeader(action, inputCount)

		for _, input in inputs do
			if typeof(input) == "EnumItem" then
				serializer:writeEnumInput(input)
			elseif input.kind == "Multiply2d" then
				serializer:writeMultiply2d(input)
			elseif input.kind == "VirtualAxis" then
				serializer:writeVirtualAxis(input)
			elseif input.kind == "VirtualAxis2d" then
				serializer:writeVirtualAxis2d(input)
			end
		end
	end

	return serialized
end

return InputMap
