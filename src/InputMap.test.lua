local InputMap = require(script.Parent.InputMap)

local function equalsDeep(a, b)
	if type(a) ~= "table" or type(b) ~= "table" then
		return a == b
	end

	for key, value in a do
		if not equalsDeep(b[key], value) then
			return false
		end
	end

	for key, value in b do
		if not equalsDeep(a[key], value) then
			return false
		end
	end

	return true
end

return function(x)
	local assertEqual = x.assertEqual

	x.test("inserts inputs", function()
		local inputMap1 = InputMap.new():insert("jump", Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
		local inputMap2 = InputMap.new():insert("jump", Enum.KeyCode.Space):insert("jump", Enum.KeyCode.ButtonA)

		assert(equalsDeep(inputMap1:get("jump"), { Enum.KeyCode.Space, Enum.KeyCode.ButtonA }))
		assert(equalsDeep(inputMap2:get("jump"), { Enum.KeyCode.Space, Enum.KeyCode.ButtonA }))
	end)

	x.test("doesn't duplicate inputs", function()
		local inputMap = InputMap.new():insert("jump", Enum.KeyCode.Space)

		inputMap:insert("jump", Enum.KeyCode.Space)

		assert(equalsDeep(inputMap:get("jump"), { Enum.KeyCode.Space }))

		inputMap:insert("jump", Enum.KeyCode.F, Enum.KeyCode.F)

		assert(equalsDeep(inputMap:get("jump"), { Enum.KeyCode.Space, Enum.KeyCode.F }))
	end)

	x.test("should freeze inputs", function()
		local inputMap = InputMap.new()

		assertEqual(table.isfrozen(inputMap:get("jump")), true)

		inputMap:insert("jump", Enum.KeyCode.Space)

		assertEqual(table.isfrozen(inputMap:get("jump")), true)
	end)

	x.test("remove inputs", function()
		local inputMap = InputMap.new():insert("jump", Enum.KeyCode.Space):insert("jump", Enum.KeyCode.F)

		inputMap:remove("jump", Enum.KeyCode.Space)
		assert(equalsDeep(inputMap:get("jump"), { Enum.KeyCode.F }))

		-- Removing an input that doesn't exist should do nothing
		inputMap:remove("jump", Enum.KeyCode.Unknown)
		assert(equalsDeep(inputMap:get("jump"), { Enum.KeyCode.F }))
	end)
end
