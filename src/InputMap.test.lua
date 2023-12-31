local InputMap = require(script.Parent.InputMap)
local Multiply2d = require(script.Parent.Multiply2d)
local VirtualAxis = require(script.Parent.VirtualAxis)
local VirtualAxis2d = require(script.Parent.VirtualAxis2d)

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

	x.nested("getByDevices", function()
		x.test("gets correct controls", function()
			local inputMap = InputMap.new():insert("action", Enum.KeyCode.Space, Enum.UserInputType.MouseButton1)

			assert(equalsDeep(inputMap:getByDevices("action", {}), {}))
			assert(equalsDeep(inputMap:getByDevices("action", { "Keyboard" }), { Enum.KeyCode.Space }))
			assert(equalsDeep(inputMap:getByDevices("action", { "Mouse" }), { Enum.UserInputType.MouseButton1 }))
		end)

		x.test("gets correct virtual axes", function()
			local mouseKeyboard1d =
				VirtualAxis.new({ positive = Enum.KeyCode.A, negative = Enum.UserInputType.MouseButton1 })
			local gamepad1d = VirtualAxis.new({ negative = Enum.KeyCode.ButtonA, positive = Enum.KeyCode.ButtonB })

			local mouseKeyboard2d = VirtualAxis2d.new({
				up = Enum.KeyCode.W,
				down = Enum.KeyCode.S,
				left = Enum.UserInputType.MouseButton1,
				right = Enum.UserInputType.MouseButton2,
			})
			local dPad = VirtualAxis2d.dPad()

			local inputMap = InputMap.new()
				:insert("virtualAxis", mouseKeyboard1d, gamepad1d)
				:insert("virtualAxis2d", mouseKeyboard2d, dPad)

			assert(equalsDeep(inputMap:getByDevices("virtualAxis", {}), {}))
			assert(equalsDeep(inputMap:getByDevices("virtualAxis", { "Keyboard" }), { mouseKeyboard1d }))
			assert(equalsDeep(inputMap:getByDevices("virtualAxis", { "Mouse" }), { mouseKeyboard1d }))
			assert(equalsDeep(inputMap:getByDevices("virtualAxis", { "Gamepad" }), { gamepad1d }))

			assert(equalsDeep(inputMap:getByDevices("virtualAxis2d", {}), {}))
			assert(equalsDeep(inputMap:getByDevices("virtualAxis2d", { "Keyboard" }), { mouseKeyboard2d }))
			assert(equalsDeep(inputMap:getByDevices("virtualAxis2d", { "Mouse" }), { mouseKeyboard2d }))
			assert(equalsDeep(inputMap:getByDevices("virtualAxis2d", { "Gamepad" }), { dPad }))
		end)
	end)

	x.test("clones InputMap", function()
		local inputMap =
			InputMap.new():insert("action", Enum.KeyCode.Space):insert("other", VirtualAxis.horizontalArrowKeys())
		local clone = inputMap:clone()

		assert(equalsDeep(clone:get("action"), { Enum.KeyCode.Space }))

		local virtualAxis = clone:get("other")[1]

		assertEqual(typeof(virtualAxis), "table")

		-- Clone should not affect old InputMap.
		clone:insert("action", Enum.KeyCode.F)
		assert(equalsDeep(inputMap:get("action"), { Enum.KeyCode.Space }))

		-- Clone should not affect old InputMap.
		virtualAxis.positive = nil
		assertEqual(virtualAxis == inputMap:get("other")[1], false)
	end)

	x.test("serializes and deserializes", function()
		local virtualAxis = VirtualAxis.verticalArrowKeys()
		local virtualAxis2d = VirtualAxis2d.new({
			up = Enum.KeyCode.W,
			down = Enum.UserInputType.MouseButton1,
			left = Enum.KeyCode.A,
		})
		local multiply = Multiply2d.new(Enum.UserInputType.MouseMovement, Vector2.new(0.2, 0.5))

		local serialized = InputMap.new()
			:insert("button", Enum.KeyCode.O, Enum.UserInputType.MouseButton1)
			:insert("axis1d", virtualAxis)
			:insert("axis2d", virtualAxis2d, multiply)
			:serialize()

		assertEqual(typeof(serialized), "buffer")

		local deserialized = InputMap.deserialize(serialized)

		assert(equalsDeep(deserialized:get("button"), { Enum.KeyCode.O, Enum.UserInputType.MouseButton1 }))
		assert(equalsDeep(deserialized:get("axis1d"), { virtualAxis }))
		assert(equalsDeep(deserialized:get("axis2d"), { virtualAxis2d, multiply }))
	end)
end
