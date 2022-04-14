local Action = require(script.Parent.Action)
local InputMap = require(script.Parent.InputMap)

--[=[
	Stores actions and an [InputMap](/api/InputMap).

	@class Actions
]=]

--[=[
	@prop inputMap InputMap
	@within Actions
]=]
local Actions = {}
Actions.__index = Actions

function Actions.new()
	local self = setmetatable({
		_actions = {},
	}, Actions)

	self.inputMap = InputMap.new()

	return self
end

--[=[
	Creates a new [`Action`](/api/Action) with the `actionKind` and returns itself.

	```lua
	Actions.new()
		:createAction("button", ActionKind.Button)
		:createAction("axis1d", ActionKind.Axis1d)
		:createAction("axis2d", ActionKind.Axis2d)
	```

	@param name string
	@param actionKind ActionKind
	@return Actions -- Returns itself.
]=]
function Actions:createAction(name, actionKind)
	self._actions[name] = Action.new(name, actionKind)

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
