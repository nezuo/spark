local ActionBind = require(script.Parent.ActionBind)
local Bind = require(script.Parent.Bind)

local Bindings = {}
Bindings.__index = Bindings

function Bindings.new()
	return setmetatable({
		actionToBinds = {},
		actionToModifiers = {},
		actionToConditions = {},
	}, Bindings)
end

function Bindings:insert(action, ...)
	if self.actionToBinds[action] == nil then
		self.actionToBinds[action] = {}
	end

	for _, bind in { ... } do
		if typeof(bind) == "table" and bind.kind == "Bind" then
			table.insert(self.actionToBinds[action], bind)
		else
			table.insert(self.actionToBinds[action], Bind.new(bind))
		end
	end

	return ActionBind.new(action, self)
end

return Bindings
