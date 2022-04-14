local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MockUserInputService = require(ReplicatedStorage.MockUserInputService)
local Spark = require(script.Parent)

local ActionKind = Spark.ActionKind
local InputMap = Spark.InputMap
local InputState = Spark.InputState
local Actions = Spark.Actions
local ValueKind = Spark.ValueKind
local Composite1d = Spark.Composite1d
local Keyboard = Spark.Devices.Keyboard
local Mouse = Spark.Devices.Mouse

return function()
	local actions, defaultInputMap, inputState, mockUserInputService, button, axis1d, axis2d
	beforeEach(function(context)
		for _, device in pairs(Spark.Devices) do
			for _, input in pairs(device) do
				input._actuation = 0

				if input._valueKind == ValueKind.Boolean then
					input._value = false
				elseif input._valueKind == ValueKind.Number then
					input._value = 0
				elseif input._valueKind == ValueKind.Vector2 then
					input._value = Vector2.zero
				end
			end
		end

		mockUserInputService = MockUserInputService.new()
		InputState._userInputService = mockUserInputService

		actions = Actions.new()
			:createAction("button", ActionKind.Button)
			:createAction("axis1d", ActionKind.Axis1d)
			:createAction("axis2d", ActionKind.Axis2d)

		button = actions:get("button")
		axis1d = actions:get("axis1d")
		axis2d = actions:get("axis2d")

		defaultInputMap = InputMap.new()
			:insertMultiple("button", { Keyboard.Space, Keyboard.W })
			:insert("axis1d", Mouse.ScrollWheel)
			:insert("axis2d", Mouse.Delta)

		inputState = InputState.new()
		inputState:addActions(actions)

		context.press = function(keyCodeOrUserInputType)
			mockUserInputService:press(keyCodeOrUserInputType)
		end

		context.release = function(keyCodeOrUserInputType)
			mockUserInputService:release(keyCodeOrUserInputType)
		end

		context.moveMouse = function(delta)
			mockUserInputService:moveMouse(delta)
		end

		context.moveScrollWheel = function(delta)
			mockUserInputService:moveScrollWheel(delta)
		end
	end)

	it("actions should have default values", function()
		expect(button:get()).to.equal(false)
		expect(axis1d:get()).to.equal(0)
		expect(axis2d:get()).to.equal(Vector2.zero)
	end)

	it("should not notify actions when value hasn't changed", function()
		local didNotify = false
		button:subscribe(function()
			didNotify = true
		end)

		inputState:update()

		expect(didNotify).to.equal(false)
	end)

	it("should throw when an input map contains an invalid action", function()
		actions.inputMap:insert("unknown", Keyboard.Space)

		expect(function()
			inputState:update()
		end).to.throw("InputMap contains invalid action called 'unknown'")
	end)

	it("should throw when using number input on a button action", function()
		actions.inputMap:insert("button", Composite1d.new({ positive = Keyboard.E, negative = Keyboard.Q }))

		expect(function()
			inputState:update()
		end).throw("Input of ValueKind.Number cannot be used with action 'button' of ActionKind.Button")
	end)

	it("should throw when using vector2 input on a button action", function()
		actions.inputMap:insert("button", Mouse.Delta)

		expect(function()
			inputState:update()
		end).throw("Input of ValueKind.Vector2 cannot be used with action 'button' of ActionKind.Button")
	end)

	it("should throw when using boolean input on a axis1d action", function()
		actions.inputMap:insert("axis1d", Keyboard.Space)

		expect(function()
			inputState:update()
		end).throw("Input of ValueKind.Boolean cannot be used with action 'axis1d' of ActionKind.Axis1d")
	end)

	it("should throw when using vector2 input on a axis1d action", function()
		actions.inputMap:insert("axis1d", Mouse.Delta)

		expect(function()
			inputState:update()
		end).throw("Input of ValueKind.Vector2 cannot be used with action 'axis1d' of ActionKind.Axis1d")
	end)

	it("should throw when using boolean input on a axis2d action", function()
		actions.inputMap:insert("axis2d", Keyboard.Space)

		expect(function()
			inputState:update()
		end).throw("Input of ValueKind.Boolean cannot be used with action 'axis2d' of ActionKind.Axis2d")
	end)

	it("should throw when using number input on a axis2d action", function()
		actions.inputMap:insert("axis2d", Mouse.ScrollWheel)

		expect(function()
			inputState:update()
		end).throw("Input of ValueKind.Number cannot be used with action 'axis2d' of ActionKind.Axis2d")
	end)

	describe("ActionKind.Button", function()
		beforeEach(function()
			actions.inputMap = defaultInputMap
		end)

		it("should update value", function(context)
			context.press(Enum.KeyCode.Space)
			inputState:update()

			expect(button:get()).to.equal(true)

			context.release(Enum.KeyCode.Space)
			inputState:update()

			expect(button:get()).to.equal(false)
		end)

		it("should notify subscribers when value changes", function(context)
			local values = {}
			button:subscribe(function(value)
				table.insert(values, value)
			end)

			context.press(Enum.KeyCode.Space)
			inputState:update()

			context.release(Enum.KeyCode.Space)
			inputState:update()

			expect(values[1]).to.equal(true)
			expect(values[2]).to.equal(false)
		end)

		it("should stay true if one button releases while another is pressed", function(context)
			context.press(Enum.KeyCode.Space)
			context.press(Enum.KeyCode.W)
			inputState:update()

			context.release(Enum.KeyCode.Space)
			inputState:update()

			expect(button:get()).to.equal(true)
		end)
	end)

	describe("ActionKind.Axis1d", function()
		beforeEach(function()
			actions.inputMap = defaultInputMap
		end)

		it("should update value", function(context)
			context.moveScrollWheel(0.5)
			inputState:update()

			expect(axis1d:get()).to.equal(0.5)

			inputState:update()

			expect(axis1d:get()).to.equal(0)
		end)

		it("should notify subscribers when value changes", function(context)
			local values = {}
			axis1d:subscribe(function(value)
				table.insert(values, value)
			end)

			context.moveScrollWheel(0.5)
			inputState:update()
			inputState:update()

			expect(values[1]).to.equal(0.5)
			expect(values[2]).to.equal(0)
		end)
	end)

	describe("ActionKind.Axis2d", function()
		beforeEach(function()
			actions.inputMap = defaultInputMap
		end)

		it("should update value", function(context)
			context.moveMouse(Vector2.one)
			inputState:update()

			expect(axis2d:get()).to.equal(Vector2.one)

			inputState:update()

			expect(axis2d:get()).to.equal(Vector2.zero)
		end)

		it("should notify subscribers when value changes", function(context)
			local values = {}
			axis2d:subscribe(function(value)
				table.insert(values, value)
			end)

			context.moveMouse(Vector2.one)
			inputState:update()
			inputState:update()

			expect(values[1]).to.equal(Vector2.one)
			expect(values[2]).to.equal(Vector2.zero)
		end)
	end)
end
