local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MockUserInputService = require(ReplicatedStorage.MockUserInputService)
local Spark = require(script.Parent)

local ActionKind = Spark.ActionKind
local Bindings = Spark.Bindings
local Devices = Spark.Devices
local InputState = Spark.InputState
local Actions = Spark.Actions
local ValueKind = Spark.ValueKind

return function()
	local actions, defaultBindings, inputState, mockUserInputService, button, axis1d, axis2d
	beforeEach(function(context)
		-- TODO: I don't like that Devices/Controls are global state. Right now they global so that Composites can read them easily.
		for _, device in pairs(Devices) do
			for _, control in pairs(device) do
				control._actuation = 0

				if control._valueKind == ValueKind.Boolean then
					control._value = false
				elseif control._valueKind == ValueKind.Number then
					control._value = 0
				elseif control._valueKind == ValueKind.Vector2 then
					control._value = Vector2.zero
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

		defaultBindings = Bindings.new(actions)
			:bind("button", Devices.Keyboard.Space)
			:bind("button", Devices.Keyboard.W)
			:bind("axis1d", Devices.Mouse.ScrollWheel)
			:bind("axis2d", Devices.Mouse.Delta)

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

	describe("ActionKind.Button", function()
		beforeEach(function()
			actions.bindings = defaultBindings
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
			actions.bindings = defaultBindings
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
			actions.bindings = defaultBindings
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
