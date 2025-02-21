local ActionBind = {}
ActionBind.__index = ActionBind

function ActionBind.new(action, bindings)
	return setmetatable({ action = action, bindings = bindings }, ActionBind)
end

function ActionBind:addModifiers(...)
	if self.bindings.actionToModifiers[self.action] == nil then
		self.bindings.actionToModifiers[self.action] = {}
	end

	for _, modifier in { ... } do
		table.insert(self.bindings.actionToModifiers[self.action], modifier)
	end

	return self
end

function ActionBind:addConditions(...)
	if self.bindings.actionToConditions[self.action] == nil then
		self.bindings.actionToConditions[self.action] = {}
	end

	for _, condition in { ... } do
		table.insert(self.bindings.actionToConditions[self.action], condition)
	end

	return self
end

return ActionBind
