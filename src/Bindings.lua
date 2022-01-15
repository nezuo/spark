local Bindings = {}
Bindings.__index = Bindings

function Bindings.new(actions)
	return setmetatable({
		_actions = actions,
		_bindings = {},
	}, Bindings)
end

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
