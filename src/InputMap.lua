local Composite1d = require(script.Parent.Inputs.Composite1d)
local Composite2d = require(script.Parent.Inputs.Composite2d)
local Devices = require(script.Parent.Devices)

local function pathToInput(path)
	if path == nil then
		return nil
	end

	local parts = string.split(path, ".")

	return Devices[parts[1]][parts[2]]
end

local function getDeserializedInput(serializedInput)
	if serializedInput.isComposite1d then
		return Composite1d.new({
			positive = pathToInput(serializedInput.positive),
			negative = pathToInput(serializedInput.negative),
		})
	elseif serializedInput.isComposite2d then
		return Composite2d.new({
			up = pathToInput(serializedInput.up),
			down = pathToInput(serializedInput.down),
			left = pathToInput(serializedInput.left),
			right = pathToInput(serializedInput.right),
		})
	else
		return pathToInput(serializedInput.input)
	end
end

--[=[
	Stores a map of actions to their inputs.

	Multiple inputs can be mapped to the same action and each input can be mapped to multiple actions.

	```lua
	actions.inputMap = InputMap.new(actions)
		:insert("Jump", Keyboard.Space)
		:insert("Look", Mouse.Delta)
	```

	@class InputMap
]=]
local InputMap = {}
InputMap.__index = InputMap

--[=[
	Creates a new empty InputMap.

	@return InputMap
]=]
function InputMap.new()
	return setmetatable({
		_map = {},
	}, InputMap)
end

--[=[
	Creates a new InputMap from a serialized input map.

	@param serialized {} -- Serialized input map returned from [`InputMap:serialize`](/api/InputMap/serialize).
	@return InputMap
]=]
function InputMap.fromSerialized(serialized)
	local self = setmetatable({
		_map = {},
	}, InputMap)

	for name, serializedInputs in pairs(serialized) do
		for _, serializedInput in ipairs(serializedInputs) do
			self:insert(name, getDeserializedInput(serializedInput))
		end
	end

	return self
end

--[=[
	Inserts a mapping between an action an an input.

	If the action already has the input, it will be removed and re-inserted at the end of the inputs.

	@param name string -- The name of the action.
	@param input Input -- The input that gets mapped to the action.
	@return InputMap -- Returns itself.
]=]
function InputMap:insert(name, input)
	if self._map[name] == nil then
		self._map[name] = {}
	end

	self:remove(name, input)

	table.insert(self._map[name], input)

	return self
end

--[=[
	Inserts mappings between an action and the provided inputs.

	@param name string -- The name of the action.
	@param inputs { Input } -- The inputs that get mapped to the action.
	@return InputMap -- Returns itself.
]=]
function InputMap:insertMultiple(name, inputs)
	for _, input in ipairs(inputs) do
		self:insert(name, input)
	end

	return self
end

--[=[
	Gets the inputs for a given action.

	@param name string -- The name of the action.
	@return { Input } -- Returns the action's inputs.
]=]
function InputMap:get(name)
	if self._map[name] == nil then
		self._map[name] = {}
	end

	return self._map[name]
end

--[=[
	Removes an input from an action if the action has that input.

	@param name string -- The name of the action.
	@param input Input -- The input to remove from the action.
]=]
function InputMap:remove(name, input)
	if self._map[name] == nil then
		return
	end

	local index = table.find(self._map[name], input)

	if index ~= nil then
		table.remove(self._map[name], index)
	end
end

--[=[
	Returns a serialized version of the input map that can be saved and loaded with [`InputMap.fromSerialized`](/api/InputMap/fromSerialized).

	@return {}
]=]
function InputMap:serialize()
	local serialized = {}

	local function getPath(input)
		if input ~= nil then
			return input._path
		end
	end

	for name, inputs in pairs(self._map) do
		local serializedInputs = {}

		for _, input in ipairs(inputs) do
			if getmetatable(input) == Composite1d then
				table.insert(serializedInputs, {
					isComposite1d = true,
					positive = getPath(input.positive),
					negative = getPath(input.negative),
				})
			elseif getmetatable(input) == Composite2d then
				table.insert(serializedInputs, {
					isComposite2d = true,
					up = getPath(input.up),
					down = getPath(input.down),
					left = getPath(input.left),
					right = getPath(input.right),
				})
			else
				table.insert(serializedInputs, {
					input = getPath(input),
				})
			end
		end

		serialized[name] = serializedInputs
	end

	return serialized
end

return InputMap
