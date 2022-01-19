local Action = require(script.Parent.Action)

--[=[
	Stores actions and a [Bindings](/api/Bindings).

	@class Actions
]=]
local Actions = {}
Actions.__index = Actions

function Actions.new()
	return setmetatable({
		_actions = {},
	}, Actions)
end

--[=[
	Creates a new Action with the `actionKind` and returns itself.

	```lua
	Actions.new()
		:createAction("button", ActionKind.Button)
		:createAction("axis1d", ActionKind.Axis1d)
		:createAction("axis2d", ActionKind.Axis2d)
	```

	@param name string
	@param actionKind ActionKind
	@return Actions -- Returns itself
]=]
function Actions:createAction(name, actionKind)
	self._actions[name] = Action.new(actionKind)

	return self
end

--[=[
	Sets the [Bindings](/api/Bindings) that is associated with the actions.

	@param bindings Bindings
]=]
function Actions:setBindings(bindings)
	self._bindings = bindings
end

--[=[
	Returns the Action corresponding to the `name`.

	@param name string
	@return Action?
]=]
function Actions:get(name)
	return self._actions[name]
end

return Actions
