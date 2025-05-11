local ActionConfig = require(script.Parent.ActionConfig)
local Bind = require(script.Parent.Bind)

--[=[
	Bind inputs to actions.

	```lua
	local actions = Actions.new({ "move", "jump" }):setRebuildBindings(function(bindings)
		bindings:bind("move", VirtualAxis2d.new({
			up = Enum.KeyCode.W,
			down = Enum.KeyCode.S,
			left = Enum.KeyCode.A,
			right = Enum.KeyCode.D
		}))
		bindings:bind("jump", Enum.KeyCode.Space)
	end)
	```

	@class Bindings
]=]
local Bindings = {}
Bindings.__index = Bindings

function Bindings.new()
	return setmetatable({
		actionToBinds = {},
		actionToModifiers = {},
	}, Bindings)
end

--[=[
	@param action string
	@param ... Bind | Input -- Inputs to bind to the action
]=]
function Bindings:bind(action, ...)
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

	return ActionConfig.new(action, self)
end

return Bindings
