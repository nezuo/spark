local ActionKind = require(script.Parent.ActionKind)
local ValueKind = require(script.Parent.ValueKind)

local actionKindToValueKind = {
	[ActionKind.Axis1d] = ValueKind.Number,
	[ActionKind.Axis2d] = ValueKind.Vector2,
	[ActionKind.Button] = ValueKind.Boolean,
}

--[=[
	@type Control ButtonControl | Axis1dControl | Axis2dControl | Composite1d | Composite2d
	@within Bindings
]=]

--[=[
	Stores a map of actions to their controls.

	Multiple controls can be mapped to the same action and each control can be mapped to multiple actions.

	```lua
	local bindings = Bindings.new(actions)
		:bind("Jump", Keyboard.Space)
		:bind("Look", Mouse.Delta)

	actions:setBindings(bindings)
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

function Bindings:_getAction(name)
	local action = self._actions:get(name)

	assert(action ~= nil, string.format("Action '%s' does not exist", name))

	return action
end

return Bindings
