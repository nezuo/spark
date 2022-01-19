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
	@param name string -- The name of the action
	@param control Control -- The control that gets mapped to the action
	@return Bindings -- Returns itself
]=]
function Bindings:bind(name, control)
	local action = self._actions:get(name)

	assert(action ~= nil, string.format("Action '%s' does not exist", name))
	assert(
		control._actionKind == action._actionKind,
		string.format("Cannot use control with %s", tostring(action._actionKind))
	)

	if self._bindings[action] == nil then
		self._bindings[action] = {}
	end

	table.insert(self._bindings[action], control)

	return self
end

return Bindings
