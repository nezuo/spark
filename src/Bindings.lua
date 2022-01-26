local ActionKind = require(script.Parent.ActionKind)
local Composite1d = require(script.Parent.Controls.Composite1d)
local Composite2d = require(script.Parent.Controls.Composite2d)
local Devices = require(script.Parent.Devices)
local ValueKind = require(script.Parent.ValueKind)

local actionKindToValueKind = {
	[ActionKind.Axis1d] = ValueKind.Number,
	[ActionKind.Axis2d] = ValueKind.Vector2,
	[ActionKind.Button] = ValueKind.Boolean,
}

local function pathToControl(path)
	local parts = string.split(path, ".")

	return Devices[parts[1]][parts[2]]
end

--[=[
	@type Control ButtonControl | Axis1dControl | Axis2dControl | Composite1d | Composite2d
	@within Bindings
]=]

--[=[
	Stores a map of actions to their controls.

	Multiple controls can be mapped to the same action and each control can be mapped to multiple actions.

	```lua
	actions.bindings = Bindings.new(actions)
		:bind("Jump", Keyboard.Space)
		:bind("Look", Mouse.Delta)
	```

	@class Bindings
]=]
local Bindings = {}
Bindings.__index = Bindings

--[=[
	Creates a new empty Bindings.

	@param actions Actions
	@return Bindings
]=]
function Bindings.new(actions)
	return setmetatable({
		_actions = actions,
		_bindings = {},
	}, Bindings)
end

--[=[
	Creates a new Bindings with the serialized bindings.

	@param actions Actions
	@param serialized {} -- Serialized bindings returned from [`Bindings:serialize`](/api/Bindings/serialize).
	@return Bindings
]=]
function Bindings.fromSerialized(actions, serialized)
	local self = setmetatable({
		_actions = actions,
		_bindings = {},
	}, Bindings)

	for name, bindings in pairs(serialized) do
		for _, binding in ipairs(bindings) do
			local control
			if binding.isComposite1d then
				control = Composite1d.new({
					positive = pathToControl(binding.positive),
					negative = pathToControl(binding.negative),
				})
			elseif binding.isComposite2d then
				control = Composite2d.new({
					up = pathToControl(binding.positive),
					down = pathToControl(binding.down),
					left = pathToControl(binding.left),
					right = pathToControl(binding.right),
				})
			else
				control = pathToControl(binding.control)
			end

			self:bind(name, control, binding.group)
		end
	end

	return self
end

--[=[
	Adds the `control` to the action's bindings.

	@error "Action 'name' does not exist" -- Thrown when the action does not exist.
	@error "Cannot use control with ActionKind." -- Thrown when the control cannot be used with the action's ActionKind.
	@param name string -- The name of the action.
	@param control Control -- The control that gets mapped to the action.
	@param group string? -- The name of the group the binding belongs to. This is useful for rebinding controls in a specific group.
	@return Bindings -- Returns itself
]=]
function Bindings:bind(name, control, group)
	local action = self:_getAction(name)

	assert(
		actionKindToValueKind[action._actionKind] == control._valueKind,
		string.format(
			"Control of %s cannot be used with action of %s",
			tostring(control._valueKind),
			tostring(action._actionKind)
		)
	)

	if self._bindings[action] == nil then
		self._bindings[action] = {}
	end

	table.insert(self._bindings[action], {
		control = control,
		group = group,
	})

	return self
end

--[=[
	```lua
	-- Remove all bindings with the group "Controller".
	bindings:filter("Move", function(group)
		return group ~= "Controller"
	end)
	```

	@param name string -- The name of the action.
	@param predicate (string) -> boolean -- A function that takes the binding's group and returns `false` if the binding should be removed.
]=]
function Bindings:filter(name, predicate)
	local action = self:_getAction(name)

	if self._bindings[action] == nil then
		return
	end

	local newBindings = {}

	for _, binding in ipairs(self._bindings[action]) do
		if predicate(binding.group) then
			table.insert(newBindings, binding)
		end
	end

	self._bindings[action] = newBindings
end

-- TODO: A problem with the current design is that you can't represent composites with missing controls.
--[=[
	Iterates over every composite in an action's bindings.

	```lua
	-- Change the `up` control of composites with group "Keyboard1".
	bindings:forEachComposite("Move", function(composite, group)
		if group == "Keyboard1" then
			composite.up = Devices.Keyboard.W
		end
	end)
	```

	@param name string -- The name of the action.
	@param forEach (Composite1d | Composite2d, string) -> () -- A function that takes the composite and its group.
]=]
function Bindings:forEachComposite(name, forEach)
	local action = self:_getAction(name)

	if self._bindings[action] == nil then
		return
	end

	for _, binding in ipairs(self._bindings[action]) do
		if binding.control._isComposite then
			forEach(binding.control, binding.group)
		end
	end
end

--[=[
	Returns a serialized version of the bindings for saving.

	@return {}
]=]
function Bindings:serialize()
	local serialized = {}

	for action, bindings in pairs(self._bindings) do
		serialized[action._name] = {}

		for _, binding in ipairs(bindings) do
			if getmetatable(binding.control) == Composite1d then
				table.insert(serialized[action._name], {
					isComposite1d = true,
					positive = binding.control.positive._path,
					negative = binding.control.negative._path,
					group = binding.group,
				})
			elseif getmetatable(binding.control) == Composite2d then
				table.insert(serialized[action._name], {
					isComposite1d = true,
					up = binding.control.up._path,
					down = binding.control.down._path,
					left = binding.control.left._path,
					right = binding.control.right._path,
					group = binding.group,
				})
			else
				table.insert(serialized[action._name], {
					control = binding.control._path,
					group = binding.group,
				})
			end
		end
	end

	return serialized
end

function Bindings:_getAction(name)
	local action = self._actions:get(name)

	assert(action ~= nil, string.format("Action '%s' does not exist", name))

	return action
end

return Bindings
