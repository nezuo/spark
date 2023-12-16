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

	@param action string -- Name of the action
	@param ... Input -- Inputs that get mapped to the action
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

	@param action string -- Name of the action
	@param input Input -- Input to remove
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

	@param action string -- Name of the action
	@return { Input }
]=]
function InputMap:get(action)
	if self.map[action] == nil then
		return table.freeze({})
	end

	return self.map[action]
end

return InputMap
