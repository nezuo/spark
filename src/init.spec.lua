local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Spark = require(script.Parent)
local MockUserInputService = require(ReplicatedStorage.MockUserInputService)

local ActionKind = Spark.ActionKind
local Bindings = Spark.Bindings
local Devices = Spark.Devices
local InputState = Spark.InputState
local Actions = Spark.Actions

return function()
	local actions, defaultBindings, inputState, mockUserInputService, button, axis1d, axis2d
	beforeEach(function()
		mockUserInputService = MockUserInputService.new()

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

		inputState = InputState.new(mockUserInputService)
		inputState:addActions(actions)
	end)

	local function press(keyCode)
		mockUserInputService:press(keyCode)
	end

	local function release(keyCode)
		mockUserInputService:release(keyCode)
	end

	local function moveMouse(delta)
		mockUserInputService:moveMouse(delta)
	end

	local function moveScrollWheel(delta)
		mockUserInputService:moveScrollWheel(delta)
	end

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
			actions:setBindings(defaultBindings)
		end)

		it("should update value", function()
			press(Enum.KeyCode.Space)
			inputState:update()

			expect(button:get()).to.equal(true)

			release(Enum.KeyCode.Space)
			inputState:update()

			expect(button:get()).to.equal(false)
		end)

		it("should notify subscribers when value changes", function()
			local values = {}
			button:subscribe(function(value)
				table.insert(values, value)
			end)

			press(Enum.KeyCode.Space)
			inputState:update()

			release(Enum.KeyCode.Space)
			inputState:update()

			expect(values[1]).to.equal(true)
			expect(values[2]).to.equal(false)
		end)

		it("should stay true if one button releases while another is pressed", function()
			press(Enum.KeyCode.Space)
			press(Enum.KeyCode.W)
			inputState:update()

			release(Enum.KeyCode.Space)
			inputState:update()

			expect(button:get()).to.equal(true)
		end)
	end)

	describe("ActionKind.Axis1d", function()
		beforeEach(function()
			actions:setBindings(defaultBindings)
		end)

		it("should update value", function()
			moveScrollWheel(0.5)
			inputState:update()

			expect(axis1d:get()).to.equal(0.5)

			inputState:update()

			expect(axis1d:get()).to.equal(0)
		end)

		it("should notify subscribers when value changes", function()
			local values = {}
			axis1d:subscribe(function(value)
				table.insert(values, value)
			end)

			moveScrollWheel(0.5)
			inputState:update()
			inputState:update()

			expect(values[1]).to.equal(0.5)
			expect(values[2]).to.equal(0)
		end)
	end)

	describe("ActionKind.Axis2d", function()
		beforeEach(function()
			actions:setBindings(defaultBindings)
		end)

		it("should update value", function()
			moveMouse(Vector2.one)
			inputState:update()

			expect(axis2d:get()).to.equal(Vector2.one)

			inputState:update()

			expect(axis2d:get()).to.equal(Vector2.zero)
		end)

		it("should notify subscribers when value changes", function()
			local values = {}
			axis2d:subscribe(function(value)
				table.insert(values, value)
			end)

			moveMouse(Vector2.one)
			inputState:update()
			inputState:update()

			expect(values[1]).to.equal(Vector2.one)
			expect(values[2]).to.equal(Vector2.zero)
		end)
	end)
end
