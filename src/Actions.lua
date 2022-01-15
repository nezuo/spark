local Action = require(script.Parent.Action)

local Actions = {}
Actions.__index = Actions

function Actions.new()
	return setmetatable({
		_actions = {},
	}, Actions)
end

function Actions:createAction(name, actionKind)
	self._actions[name] = Action.new(actionKind)

	return self
end

function Actions:setBindings(bindings)
	self._bindings = bindings
end

function Actions:get(name)
	return self._actions[name]
end

return Actions
