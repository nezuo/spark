--[=[
	Allows you to add modifiers to a set of inputs.

	```lua
	local actions = Actions.new({ "look" }):setRebuildBindings(function(bindings)
		bindings:bind(
			"look",
			Bind.new(Enum.KeyCode.Thumbstick2):addModifiers(scale(0.5, Vector2.new(0.5, 0.5)))
		)
	end)
	```

	@class Bind
]=]
local Bind = {}
Bind.__index = Bind

function Bind.new(...)
	local inputs = { ... }

	if #inputs == 0 then
		error("Expected at least one input")
	end

	return setmetatable({
		kind = "Bind",
		inputs = inputs,
		modifiers = {},
	}, Bind)
end

--[=[
	Adds modifiers to the Bind's inputs.

	@param ... Modifier
	@return Bind -- Returns self
]=]
function Bind:addModifiers(...)
	for _, modifier in { ... } do
		table.insert(self.modifiers, modifier)
	end

	return self
end

return Bind
