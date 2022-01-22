local Action = require(script.Parent.Action)
local Bindings = require(script.Parent.Bindings)

--[=[
	Stores actions and a [Bindings](/api/Bindings).

	@class Actions
]=]

--[=[
	@prop bindings Bindings
	@within Actions
]=]
local Actions = {}
Actions.__index = Actions

function Actions.new()
	local self = setmetatable({
		_actions = {},
	}, Actions)

	self.bindings = Bindings.new(self)

	return self
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
	Returns the Action corresponding to the `name`.

	@param name string
	@return Action?
]=]
function Actions:get(name)
	return self._actions[name]
end

return Actions
