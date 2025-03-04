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
		conditions = {},
	}, Bind)
end

function Bind:addModifiers(...)
	for _, modifier in { ... } do
		table.insert(self.modifiers, modifier)
	end

	return self
end

function Bind:addConditions(...)
	for _, condition in { ... } do
		table.insert(self.conditions, condition)
	end

	return self
end

return Bind
