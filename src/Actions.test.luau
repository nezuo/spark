local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Spark = require(script.Parent)
local VirtualAxis = require(script.Parent.VirtualAxis)
local VirtualAxis2d = require(script.Parent.VirtualAxis2d)
local MutableInputState = require(ReplicatedStorage.MutableInputState)

local Actions = Spark.Actions

return function(x)
	local assertEqual = x.assertEqual

	x.test("button presses", function()
		local actions = Actions.new({ "jump" }):setRebuildBindings(function(bindings)
			bindings:bind("jump", Enum.KeyCode.Space)
		end)

		local inputState = MutableInputState.new()

		local counter = 0
		local disconnect = actions:justPressedSignal("jump"):connect(function()
			counter += 1
		end)

		actions:update(inputState)
		assertEqual(counter, 0)
		assertEqual(actions:pressed("jump"), false)

		inputState:press(Enum.KeyCode.Space)
		actions:update(inputState)
		assertEqual(counter, 1)
		assertEqual(actions:pressed("jump"), true)

		actions:update(inputState)
		assertEqual(counter, 1)
		assertEqual(actions:pressed("jump"), true)

		inputState:release(Enum.KeyCode.Space)
		actions:update(inputState)
		assertEqual(actions:pressed("jump"), false)

		disconnect()

		inputState:press(Enum.KeyCode.Space)
		actions:update(inputState)
		assertEqual(counter, 1)
		assertEqual(actions:pressed("jump"), true)
	end)

	x.test("button releases", function()
		local actions = Actions.new({ "jump" }):setRebuildBindings(function(bindings)
			bindings:bind("jump", Enum.KeyCode.Space)
		end)

		local inputState = MutableInputState.new()

		local counter = 0
		local disconnect = actions:justReleasedSignal("jump"):connect(function()
			counter += 1
		end)

		actions:update(inputState)
		assertEqual(counter, 0)
		assertEqual(actions:released("jump"), true)

		inputState:press(Enum.KeyCode.Space)
		actions:update(inputState)
		assertEqual(counter, 0)
		assertEqual(actions:released("jump"), false)

		inputState:release(Enum.KeyCode.Space)
		actions:update(inputState)
		assertEqual(counter, 1)
		assertEqual(actions:released("jump"), true)

		actions:update(inputState)
		assertEqual(counter, 1)
		assertEqual(actions:released("jump"), true)

		disconnect()

		inputState:press(Enum.KeyCode.Space)
		actions:update(inputState)
		assertEqual(actions:released("jump"), false)

		inputState:release(Enum.KeyCode.Space)
		actions:update(inputState)
		assertEqual(counter, 1)
		assertEqual(actions:released("jump"), true)
	end)

	x.test("handles mouse wheel", function()
		local actions = Actions.new({ "scroll" }):setRebuildBindings(function(bindings)
			bindings:bind("scroll", Enum.UserInputType.MouseWheel)
		end)

		local inputState = MutableInputState.new()

		actions:update(inputState)
		assertEqual(actions:axis("scroll"), 0)

		inputState:scroll(4)

		actions:update(inputState)
		assertEqual(actions:axis("scroll"), 4)

		-- Updating InputState should reset the mouse wheel.
		inputState:clear()
		actions:update(inputState)
		assertEqual(actions:axis("scroll"), 0)
	end)

	x.test("handles axis2d values", function()
		local actions = Actions.new({ "mouse" }):setRebuildBindings(function(bindings)
			bindings:bind("mouse", Enum.UserInputType.MouseMovement)
		end)

		local inputState = MutableInputState.new()

		actions:update(inputState)
		assertEqual(actions:axis2d("mouse"), Vector2.zero)
		assertEqual(actions:normalizedAxis2d("mouse"), Vector2.zero)

		inputState:moveMouse(Vector2.new(4, 3))

		actions:update(inputState)
		assertEqual(actions:axis2d("mouse"), Vector2.new(4, 3))
		assertEqual(actions:normalizedAxis2d("mouse"), Vector2.new(4, 3).Unit)

		-- Updating InputState should reset mouse movement.
		inputState:clear()
		actions:update(inputState)
		assertEqual(actions:axis2d("mouse"), Vector2.zero)
		assertEqual(actions:normalizedAxis2d("mouse"), Vector2.zero)
	end)

	x.test("handles VirtualAxis", function()
		local removeNegative = false
		local actions = Actions.new({ "action" }):setRebuildBindings(function(bindings)
			local input = VirtualAxis.horizontalArrowKeys()
			if removeNegative then
				input.negative = nil
			end

			bindings:bind("action", input)
		end)

		local inputState = MutableInputState.new()

		actions:update(inputState)
		assertEqual(actions:axis("action"), 0)

		inputState:press(Enum.KeyCode.Left)
		actions:update(inputState)
		assertEqual(actions:axis("action"), -1)

		inputState:press(Enum.KeyCode.Right)
		actions:update(inputState)
		assertEqual(actions:axis("action"), 0)

		inputState:release(Enum.KeyCode.Left)
		actions:update(inputState)
		assertEqual(actions:axis("action"), 1)

		-- nil inputs should work
		removeNegative = true
		actions:rebuildBindings()

		actions:update(inputState)
		assertEqual(actions:axis("action"), 1)
	end)

	x.test("handles VirtualAxis2d", function()
		local removeDown = false
		local actions = Actions.new({ "action" }):setRebuildBindings(function(bindings)
			local input = VirtualAxis2d.wasd()
			if removeDown then
				input.down = nil
			end

			bindings:bind("action", input)
		end)

		local inputState = MutableInputState.new()

		actions:update(inputState)
		assertEqual(actions:axis2d("action"), Vector2.zero)

		inputState:press(Enum.KeyCode.W)
		actions:update(inputState)
		assertEqual(actions:axis2d("action"), Vector2.yAxis)

		inputState:press(Enum.KeyCode.D)
		actions:update(inputState)
		assertEqual(actions:axis2d("action"), Vector2.one)

		inputState:press(Enum.KeyCode.S)
		actions:update(inputState)
		assertEqual(actions:axis2d("action"), Vector2.xAxis)

		-- nil inputs should work
		removeDown = true
		actions:rebuildBindings()

		actions:update(inputState)
		assertEqual(actions:axis2d("action"), Vector2.one)
	end)

	x.test("clampedAxis2d", function()
		local actions = Actions.new({ "mouse" }):setRebuildBindings(function(bindings)
			bindings:bind("mouse", Enum.UserInputType.MouseMovement)
		end)

		local inputState = MutableInputState.new()

		inputState:moveMouse(Vector2.new(0.25, 0.5))
		actions:update(inputState)
		assertEqual(actions:clampedAxis2d("mouse"), Vector2.new(0.25, 0.5))

		inputState:clear()
		inputState:moveMouse(Vector2.new(0.9, 0.8))
		actions:update(inputState)
		assertEqual(actions:clampedAxis2d("mouse"), Vector2.new(0.9, 0.8).Unit)
	end)

	x.test("gamepad buttons", function()
		local actions = Actions.new({ "jump" }):setRebuildBindings(function(bindings)
			bindings:bind("jump", Enum.KeyCode.ButtonA)
		end)

		local inputState = MutableInputState.new()

		actions:setAssociatedGamepad(Enum.UserInputType.Gamepad2)

		local counter = 0
		actions:justPressedSignal("jump"):connect(function()
			counter += 1
		end)

		inputState:pressGamepad(Enum.KeyCode.ButtonA, Enum.UserInputType.Gamepad1)
		actions:update(inputState)
		assertEqual(counter, 0)

		inputState:releaseGamepad(Enum.KeyCode.ButtonA, Enum.UserInputType.Gamepad1)

		actions:setAssociatedGamepad(Enum.UserInputType.Gamepad1)

		inputState:pressGamepad(Enum.KeyCode.ButtonA, Enum.UserInputType.Gamepad1)
		actions:update(inputState)
		assertEqual(counter, 1)
	end)

	x.test("handles manual press", function()
		local actions = Actions.new({ "jump" }):setRebuildBindings(function(bindings)
			bindings:bind("jump", Enum.KeyCode.Space)
		end)

		local inputState = MutableInputState.new()

		local pressedCount = 0
		actions:justPressedSignal("jump"):connect(function()
			pressedCount += 1
		end)

		local releasedCount = 0
		actions:justReleasedSignal("jump"):connect(function()
			releasedCount += 1
		end)

		actions:press("jump")
		assertEqual(pressedCount, 0)

		actions:update(inputState)
		assertEqual(pressedCount, 1)
		assertEqual(actions:axis("jump"), 1)

		-- The action should not be released by an input if being held manually.
		actions:press("jump")
		inputState:press(Enum.KeyCode.Space)
		actions:update(inputState)
		inputState:release(Enum.KeyCode.Space)
		assertEqual(releasedCount, 0)

		actions:update(inputState)
		assertEqual(releasedCount, 1)
	end)

	x.test("handles manual moveAxis", function()
		local actions = Actions.new({ "zoom" }):setRebuildBindings(function(bindings)
			bindings:bind("zoom", VirtualAxis.verticalArrowKeys())
		end)

		local inputState = MutableInputState.new()

		actions:moveAxis("zoom", 1)
		assertEqual(actions:axis("zoom"), 0)

		actions:update(inputState)
		assertEqual(actions:axis2d("zoom"), Vector2.zero)
		assertEqual(actions:pressed("zoom"), true)
		assertEqual(actions:axis("zoom"), 1)

		-- Manual moves should reset the next update
		actions:update(inputState)
		assertEqual(actions:axis("zoom"), 0)

		-- Manual moves should stack
		actions:moveAxis("zoom", 1)
		actions:moveAxis("zoom", 2)
		inputState:press(Enum.KeyCode.Up)
		actions:update(inputState)
		assertEqual(actions:axis("zoom"), 4)

		-- Should handle negative values properly
		inputState:release(Enum.KeyCode.Up)
		actions:moveAxis("zoom", -1)
		actions:update(inputState)
		assertEqual(actions:axis("zoom"), -1)
		assertEqual(actions:pressed("zoom"), true)
	end)

	x.test("handles manual moveAxis2d", function()
		local actions = Actions.new({ "move" }):setRebuildBindings(function(bindings)
			bindings:bind("move", Enum.UserInputType.MouseMovement)
		end)

		local inputState = MutableInputState.new()

		actions:moveAxis2d("move", Vector2.new(1, 0))
		assertEqual(actions:axis2d("move"), Vector2.zero)

		actions:update(inputState)
		assertEqual(actions:axis2d("move"), Vector2.new(1, 0))
		assertEqual(actions:pressed("move"), true)
		assertEqual(actions:axis("move"), 1)

		-- Manual moves should reset the next update
		actions:update(inputState)
		assertEqual(actions:axis2d("move"), Vector2.zero)

		-- Manual moves should stack
		actions:moveAxis2d("move", Vector2.new(1, 0))
		actions:moveAxis2d("move", Vector2.new(2, 0))
		inputState:moveMouse(Vector2.new(0, 1))
		actions:update(inputState)
		assertEqual(actions:axis2d("move"), Vector2.new(3, 1))
	end)

	x.test("justPressedSignal and justReleasedSignal should fire after values have updated", function()
		local actions = Actions.new({ "action" }):setRebuildBindings(function(bindings)
			bindings:bind("action", Enum.UserInputType.MouseMovement)
		end)

		local inputState = MutableInputState.new()

		actions:moveAxis2d("action", Vector2.xAxis)

		local pressedFired = false
		actions:justPressedSignal("action"):connect(function()
			pressedFired = true
			assertEqual(actions:pressed("action"), true)
			assertEqual(actions:axis("action"), 1)
			assertEqual(actions:axis2d("action"), Vector2.xAxis)
		end)

		actions:update(inputState)

		assertEqual(pressedFired, true)

		local releasedFired = false
		actions:justReleasedSignal("action"):connect(function()
			releasedFired = true
			assertEqual(actions:pressed("action"), false)
			assertEqual(actions:axis("action"), 0)
			assertEqual(actions:axis2d("action"), Vector2.zero)
		end)

		actions:update(inputState)

		assertEqual(releasedFired, true)
	end)

	x.test("getInputsByDevices", function()
		local actions = Actions.new({ "action" }):setRebuildBindings(function(bindings)
			bindings:bind("action", Enum.KeyCode.Space, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonA)
		end)

		assertEqual(#actions:getInputsByDevices("action", {}), 0)

		assertEqual(#actions:getInputsByDevices("action", { "Keyboard" }), 1)
		assertEqual(actions:getInputsByDevices("action", { "Keyboard" })[1], Enum.KeyCode.Space)

		assertEqual(#actions:getInputsByDevices("action", { "Mouse" }), 1)
		assertEqual(actions:getInputsByDevices("action", { "Mouse" })[1], Enum.UserInputType.MouseButton1)

		assertEqual(#actions:getInputsByDevices("action", { "Gamepad" }), 1)
		assertEqual(actions:getInputsByDevices("action", { "Gamepad" })[1], Enum.KeyCode.ButtonA)

		assertEqual(#actions:getInputsByDevices("action", { "Keyboard", "Mouse" }), 2)
		assert(table.find(actions:getInputsByDevices("action", { "Keyboard", "Mouse" }), Enum.KeyCode.Space) ~= nil, "")
		assert(
			table.find(actions:getInputsByDevices("action", { "Keyboard", "Mouse" }), Enum.UserInputType.MouseButton1)
				~= nil,
			""
		)
	end)

	x.test("getInputsByDevices + virtual axes", function()
		local useKeyboard = false
		local actions = Actions.new({ "action" }):setRebuildBindings(function(bindings)
			if useKeyboard then
				bindings:bind("action", VirtualAxis.horizontalArrowKeys())
				bindings:bind("action", VirtualAxis2d.arrowKeys())
			else
				bindings:bind(
					"action",
					VirtualAxis.new({ positive = Enum.KeyCode.ButtonA, negative = Enum.KeyCode.ButtonB })
				)
				bindings:bind(
					"action",
					VirtualAxis.new({
						up = Enum.KeyCode.ButtonY,
						down = Enum.KeyCode.ButtonA,
						left = Enum.KeyCode.ButtonX,
						right = Enum.KeyCode.ButtonB,
					})
				)
			end
		end)

		assertEqual(#actions:getInputsByDevices("action", { "Keyboard" }), 0)

		useKeyboard = true
		actions:rebuildBindings()

		assertEqual(#actions:getInputsByDevices("action", { "Keyboard" }), 2)
	end)

	x.test("scale modifier", function()
		local actions = Actions.new({ "inputLevel", "actionLevel" }):setRebuildBindings(function(bindings)
			local modifier = Spark.Modifiers.scale(0.5, Vector2.new(0.75, 0.5))

			bindings:bind(
				"inputLevel",
				Enum.UserInputType.MouseWheel,
				Spark.Bind.new(Enum.UserInputType.MouseMovement):addModifiers(modifier)
			)

			bindings
				:bind("actionLevel", Enum.UserInputType.MouseWheel, Enum.UserInputType.MouseMovement)
				:addModifiers(modifier)
		end)

		local inputState = MutableInputState.new()

		inputState:scroll(4)
		inputState:moveMouse(Vector2.new(4, 4))

		actions:update(inputState)

		assertEqual(actions:axis("inputLevel"), Vector2.new(4, 4).Magnitude * 0.5 + 4)
		assertEqual(actions:axis("actionLevel"), (Vector2.new(4, 4).Magnitude + 4) * 0.5)

		assertEqual(actions:axis2d("inputLevel"), Vector2.new(4 * 0.75, 4 * 0.5))
		assertEqual(actions:axis2d("actionLevel"), Vector2.new(4 * 0.75, 4 * 0.5))

		inputState:clear()

		-- Action level modifier should apply to manual moves
		actions:moveAxis("actionLevel", 1)
		actions:moveAxis2d("actionLevel", Vector2.new(1, 1))
		actions:update(inputState)

		assertEqual(actions:axis("actionLevel"), (Vector2.new(1, 1).Magnitude + 1) * 0.5)
		assertEqual(actions:axis2d("actionLevel"), Vector2.new(0.75, 0.5))
	end)

	x.test("deadzone modifier", function()
		local actions = Actions.new({ "action" }):setRebuildBindings(function(bindings)
			bindings:bind(
				"action",
				Spark.Bind.new(Enum.UserInputType.MouseMovement):addModifiers(Spark.Modifiers.deadzone("Radial", 0.2))
			)
		end)

		local inputState = MutableInputState.new()

		inputState:moveMouse(Vector2.new(0.1, 0.1))

		actions:update(inputState)

		assertEqual(actions:axis("action"), 0)
		assertEqual(actions:axis2d("action"), Vector2.zero)

		inputState:clear()
		inputState:moveMouse(Vector2.new(0.2, 0.2))

		actions:update(inputState)

		assertEqual(actions:axis("action") > 0 and actions:axis("action") < 0.2, true)
		assertEqual(actions:axis2d("action").Magnitude > 0 and actions:axis2d("action").Magnitude < 0.2, true)
	end)
end
