local Spark = require(script.Parent)

local ActionKind = Spark.ActionKind
local Actions = Spark.Actions
local Bindings = Spark.Bindings
local InputState = Spark.InputState
local Keyboard = Spark.Devices.Keyboard
local Mouse = Spark.Devices.Mouse
local Composite1d = Spark.Composite1d

return function()
	local actions, inputState
	beforeEach(function()
		actions = Actions.new()
			:createAction("button", ActionKind.Button)
			:createAction("axis1d", ActionKind.Axis1d)
			:createAction("axis2d", ActionKind.Axis2d)

		inputState = InputState.new()
		inputState:addActions(actions)

		actions.bindings:bind("button", Keyboard.Space):bind("button", Keyboard.Tab, "Group"):bind(
			"axis1d",
			Composite1d.new({
				positive = Keyboard.D,
				negative = Keyboard.A,
			})
		)
	end)

	describe("Binding:bind", function()
		it("should throw when the action doesn't exist", function()
			expect(function()
				Bindings.new(actions):bind("unknown", Keyboard.Space)
			end).to.throw("Action 'unknown' does not exist")
		end)

		it("should throw when control doesn't match action's ActionKind", function()
			expect(function()
				actions.bindings:bind("button", Mouse.ScrollWheel)
			end).to.throw("Control of ValueKind.Number cannot be used with action of ActionKind.Button")
			expect(function()
				actions.bindings:bind("button", Mouse.Delta)
			end).to.throw("Control of ValueKind.Vector2 cannot be used with action of ActionKind.Button")

			expect(function()
				actions.bindings:bind("axis1d", Keyboard.Space)
			end).to.throw("Control of ValueKind.Boolean cannot be used with action of ActionKind.Axis1d")
			expect(function()
				actions.bindings:bind("axis1d", Mouse.Delta)
			end).to.throw("Control of ValueKind.Vector2 cannot be used with action of ActionKind.Axis1d")

			expect(function()
				actions.bindings:bind("axis2d", Keyboard.Space)
			end).to.throw("Control of ValueKind.Boolean cannot be used with action of ActionKind.Axis2d")
			expect(function()
				actions.bindings:bind("axis2d", Mouse.ScrollWheel)
			end).to.throw("Control of ValueKind.Number cannot be used with action of ActionKind.Axis2d")
		end)
	end)

	describe("Binding:filter", function()
		it("should throw when the action doesn't exist", function()
			expect(function()
				actions.bindings:filter("unknown", function()
					return true
				end)
			end).to.throw("Action 'unknown' does not exist")
		end)

		it("should remove all controls", function(context)
			actions.bindings:filter("button", function()
				return false
			end)

			context.press(Enum.KeyCode.Space)
			inputState:update()
			expect(actions:get("button"):get()).to.equal(false)
		end)

		it("should remove all controls in group", function(context)
			actions.bindings:filter("button", function(group)
				return group ~= "Group"
			end)

			context.press(Enum.KeyCode.Tab)
			inputState:update()
			expect(actions:get("button"):get()).to.equal(false)

			context.press(Enum.KeyCode.Space)
			inputState:update()
			expect(actions:get("button"):get()).to.equal(true)
		end)
	end)

	describe("Binding:forEachComposite", function()
		it("should throw when the action doesn't exist", function()
			expect(function()
				actions.bindings:forEachComposite("unknown", function(composite)
					return composite
				end)
			end).to.throw("Action 'unknown' does not exist")
		end)

		it("should rebind composite's positive control", function(context)
			actions.bindings:forEachComposite("axis1d", function(composite)
				composite.positive = Keyboard.F
			end)

			context.press(Enum.KeyCode.F)
			inputState:update()
			expect(actions:get("axis1d"):get()).to.equal(1)
		end)
	end)
end
