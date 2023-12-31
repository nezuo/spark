local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Spark = require(script.Parent)
local VirtualAxis = require(script.Parent.VirtualAxis)
local VirtualAxis2d = require(script.Parent.VirtualAxis2d)
local MutableInputState = require(ReplicatedStorage.MutableInputState)

local Actions = Spark.Actions
local InputMap = Spark.InputMap

return function(x)
	local assertEqual = x.assertEqual
	local shouldThrow = x.shouldThrow

	x.test("button presses", function()
		local actions = Actions.new({ "jump" })

		local inputState = MutableInputState.new()
		local inputMap = InputMap.new():insert("jump", Enum.KeyCode.Space)

		local counter = 0
		local disconnect = actions:justPressedSignal("jump"):connect(function()
			counter += 1
		end)

		actions:update(inputState, inputMap)
		assertEqual(counter, 0)
		assertEqual(actions:pressed("jump"), false)

		inputState:press(Enum.KeyCode.Space)
		actions:update(inputState, inputMap)
		assertEqual(counter, 1)
		assertEqual(actions:pressed("jump"), true)

		actions:update(inputState, inputMap)
		assertEqual(counter, 1)
		assertEqual(actions:pressed("jump"), true)

		inputState:release(Enum.KeyCode.Space)
		actions:update(inputState, inputMap)
		assertEqual(actions:pressed("jump"), false)

		disconnect()

		inputState:press(Enum.KeyCode.Space)
		actions:update(inputState, inputMap)
		assertEqual(counter, 1)
		assertEqual(actions:pressed("jump"), true)
	end)

	x.test("button releases", function()
		local actions = Actions.new({ "jump" })

		local inputState = MutableInputState.new()
		local inputMap = InputMap.new():insert("jump", Enum.KeyCode.Space)

		local counter = 0
		local disconnect = actions:justReleasedSignal("jump"):connect(function()
			counter += 1
		end)

		actions:update(inputState, inputMap)
		assertEqual(counter, 0)
		assertEqual(actions:released("jump"), true)

		inputState:press(Enum.KeyCode.Space)
		actions:update(inputState, inputMap)
		assertEqual(counter, 0)
		assertEqual(actions:released("jump"), false)

		inputState:release(Enum.KeyCode.Space)
		actions:update(inputState, inputMap)
		assertEqual(counter, 1)
		assertEqual(actions:released("jump"), true)

		actions:update(inputState, inputMap)
		assertEqual(counter, 1)
		assertEqual(actions:released("jump"), true)

		disconnect()

		inputState:press(Enum.KeyCode.Space)
		actions:update(inputState, inputMap)
		assertEqual(actions:released("jump"), false)

		inputState:release(Enum.KeyCode.Space)
		actions:update(inputState, inputMap)
		assertEqual(counter, 1)
		assertEqual(actions:released("jump"), true)
	end)

	x.test("handles mouse wheel", function()
		local actions = Actions.new({ "scroll" })

		local inputState = MutableInputState.new()
		local inputMap = InputMap.new():insert("scroll", Enum.UserInputType.MouseWheel)

		actions:update(inputState, inputMap)
		assertEqual(actions:value("scroll"), 0)

		inputState:scroll(4)

		actions:update(inputState, inputMap)
		assertEqual(actions:value("scroll"), 4)

		-- Updating InputState should reset the mouse wheel.
		inputState:clear()
		actions:update(inputState, inputMap)
		assertEqual(actions:value("scroll"), 0)
	end)

	x.test("handles axis2d values", function()
		local actions = Actions.new({ "mouse" })

		local inputState = MutableInputState.new()
		local inputMap = InputMap.new():insert("mouse", Enum.UserInputType.MouseMovement)

		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("mouse"), Vector2.zero)
		assertEqual(actions:normalizedAxis2d("mouse"), Vector2.zero)

		inputState:moveMouse(Vector2.new(4, 3))

		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("mouse"), Vector2.new(4, 3))
		assertEqual(actions:normalizedAxis2d("mouse"), Vector2.new(4, 3).Unit)

		-- Updating InputState should reset mouse movement.
		inputState:clear()
		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("mouse"), Vector2.zero)
		assertEqual(actions:normalizedAxis2d("mouse"), Vector2.zero)
	end)

	x.test("handles VirtualAxis", function()
		local input = VirtualAxis.horizontalArrowKeys()

		local actions = Actions.new({ "action" })
		local inputMap = InputMap.new():insert("action", input)
		local inputState = MutableInputState.new()

		actions:update(inputState, inputMap)
		assertEqual(actions:value("action"), 0)

		inputState:press(Enum.KeyCode.Left)
		actions:update(inputState, inputMap)
		assertEqual(actions:value("action"), -1)

		inputState:press(Enum.KeyCode.Right)
		actions:update(inputState, inputMap)
		assertEqual(actions:value("action"), 0)

		inputState:release(Enum.KeyCode.Left)
		actions:update(inputState, inputMap)
		assertEqual(actions:value("action"), 1)

		-- nil inputs should work
		input.negative = nil
		actions:update(inputState, inputMap)
		assertEqual(actions:value("action"), 1)
	end)

	x.test("handles VirtualAxis2d", function()
		local input = VirtualAxis2d.wasd()

		local actions = Actions.new({ "action" })
		local inputMap = InputMap.new():insert("action", input)
		local inputState = MutableInputState.new()

		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("action"), Vector2.zero)

		inputState:press(Enum.KeyCode.W)
		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("action"), Vector2.yAxis)

		inputState:press(Enum.KeyCode.D)
		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("action"), Vector2.one)

		inputState:press(Enum.KeyCode.S)
		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("action"), Vector2.xAxis)

		-- nil inputs should work
		input.down = nil
		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("action"), Vector2.one)
	end)

	x.test("clampedAxis2d", function()
		local actions = Actions.new({ "mouse" })

		local inputState = MutableInputState.new()
		local inputMap = InputMap.new():insert("mouse", Enum.UserInputType.MouseMovement)

		inputState:moveMouse(Vector2.new(0.25, 0.5))
		actions:update(inputState, inputMap)
		assertEqual(actions:clampedAxis2d("mouse"), Vector2.new(0.25, 0.5))

		inputState:clear()
		inputState:moveMouse(Vector2.new(0.9, 0.8))
		actions:update(inputState, inputMap)
		assertEqual(actions:clampedAxis2d("mouse"), Vector2.new(0.9, 0.8).Unit)
	end)

	x.test("gamepad buttons", function()
		local actions = Actions.new({ "jump" })

		local inputState = MutableInputState.new()
		local inputMap = InputMap.new():insert("jump", Enum.KeyCode.ButtonA)

		local counter = 0
		actions:justPressedSignal("jump"):connect(function()
			counter += 1
		end)

		inputState:pressGamepad(Enum.KeyCode.ButtonA, Enum.UserInputType.Gamepad1)
		actions:update(inputState, inputMap)
		assertEqual(counter, 0)

		inputState:releaseGamepad(Enum.KeyCode.ButtonA, Enum.UserInputType.Gamepad1)
		inputMap.associatedGamepad = Enum.UserInputType.Gamepad1

		inputState:pressGamepad(Enum.KeyCode.ButtonA, Enum.UserInputType.Gamepad1)
		actions:update(inputState, inputMap)
		assertEqual(counter, 1)
	end)

	x.test("handles manual hold", function()
		local actions = Actions.new({ "jump" })

		local inputState = MutableInputState.new()
		local inputMap = InputMap.new():insert("jump", Enum.KeyCode.Space)

		local pressedCount = 0
		actions:justPressedSignal("jump"):connect(function()
			pressedCount += 1
		end)

		local releasedCount = 0
		actions:justReleasedSignal("jump"):connect(function()
			releasedCount += 1
		end)

		local stopHold = actions:hold("jump")
		assertEqual(pressedCount, 0)

		actions:update(inputState, inputMap)
		assertEqual(pressedCount, 1)
		assertEqual(actions:value("jump"), 1)

		-- The action should not be released by an input if being held manually.
		inputState:press(Enum.KeyCode.Space)
		actions:update(inputState, inputMap)
		inputState:release(Enum.KeyCode.Space)
		assertEqual(releasedCount, 0)

		stopHold()

		actions:update(inputState, inputMap)
		assertEqual(releasedCount, 1)

		-- Should handle multiple holds.
		local stop1 = actions:hold("jump")
		local stop2 = actions:hold("jump")

		actions:update(inputState, inputMap)
		assertEqual(pressedCount, 2)
		assertEqual(actions:pressed("jump"), true)

		stop1()

		actions:update(inputState, inputMap)
		assertEqual(pressedCount, 2)
		assertEqual(actions:pressed("jump"), true)

		stop2()

		actions:update(inputState, inputMap)
		assertEqual(pressedCount, 2)
		assertEqual(actions:pressed("jump"), false)

		-- Stopping a hold more than once should error.
		shouldThrow(function()
			stop2()
		end)
	end)

	x.test("handles manual move", function()
		local actions = Actions.new({ "move" })

		local inputState = MutableInputState.new()
		local inputMap = InputMap.new():insert("move", Enum.UserInputType.MouseMovement)

		actions:move("move", Vector2.new(1, 0))
		assertEqual(actions:axis2d("move"), Vector2.zero)

		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("move"), Vector2.new(1, 0))
		assertEqual(actions:pressed("move"), true)
		assertEqual(actions:value("move"), 1)

		-- Manual moves should reset the next update
		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("move"), Vector2.zero)

		-- Manual moves should stack
		actions:move("move", Vector2.new(1, 0))
		actions:move("move", Vector2.new(2, 0))
		inputState:moveMouse(Vector2.new(0, 1))
		actions:update(inputState, inputMap)
		assertEqual(actions:axis2d("move"), Vector2.new(3, 1))
	end)

	x.test("justPressedSignal and justReleasedSignal should fire after values have updated", function()
		local actions = Actions.new({ "action" })

		local inputState = MutableInputState.new()
		local inputMap = InputMap.new():insert("action", Enum.UserInputType.MouseMovement)

		actions:move("action", Vector2.xAxis)

		local pressedFired = false
		actions:justPressedSignal("action"):connect(function()
			pressedFired = true
			assertEqual(actions:pressed("action"), true)
			assertEqual(actions:value("action"), 1)
			assertEqual(actions:axis2d("action"), Vector2.xAxis)
		end)

		actions:update(inputState, inputMap)

		assertEqual(pressedFired, true)

		local releasedFired = false
		actions:justReleasedSignal("action"):connect(function()
			releasedFired = true
			assertEqual(actions:pressed("action"), false)
			assertEqual(actions:value("action"), 0)
			assertEqual(actions:axis2d("action"), Vector2.zero)
		end)

		actions:update(inputState, inputMap)

		assertEqual(releasedFired, true)
	end)
end
