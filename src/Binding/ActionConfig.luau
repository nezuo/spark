--[=[
	`ActionConfig` allows you to configure an action with modifiers.

	```lua
	local actions = Actions.new({ "look" }):setRebuildBindings(function(bindings)
		bindings:bind("look")
			-- ActionConfig is returned by Bindings:bind.
			:addModifiers(scale(0.5, Vector2.new(0.5, 0.5)))
	end)
	```

	@class ActionConfig
]=]
local ActionConfig = {}
ActionConfig.__index = ActionConfig

function ActionConfig.new(action, bindings)
	return setmetatable({ action = action, bindings = bindings }, ActionConfig)
end

--[=[
	Adds modifiers to the action.

	@param ... Modifier
	@return ActionConfig -- Returns self
]=]
function ActionConfig:addModifiers(...)
	if self.bindings.actionToModifiers[self.action] == nil then
		self.bindings.actionToModifiers[self.action] = {}
	end

	for _, modifier in { ... } do
		table.insert(self.bindings.actionToModifiers[self.action], modifier)
	end

	return self
end

return ActionConfig
