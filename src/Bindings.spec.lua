local Spark = require(script.Parent)

local ActionKind = Spark.ActionKind
local Bindings = Spark.Bindings
local Composite1d = Spark.Composite1d
local Composite2d = Spark.Composite2d
local Devices = Spark.Devices
local Actions = Spark.Actions

return function()
	describe("Binding:bind", function()
		it("should thrown when the action doesn't exist", function()
			local actions = Actions.new()

			expect(function()
				Bindings.new(actions):bind("unknown", Devices.Keyboard.Space)
			end).to.throw("Action 'unknown' does not exist")
		end)

		it("should throw when control doesn't match action's ActionKind", function()
			local actions = Actions.new()
				:createAction("button", ActionKind.Button)
				:createAction("axis1d", ActionKind.Axis1d)
				:createAction("axis2d", ActionKind.Axis2d)

			local button = Devices.Keyboard.Space
			local axis1d = Devices.Mouse.ScrollWheel
			local axis2d = Devices.Mouse.Delta
			local composite1d = Composite1d.new({ positive = Devices.Keyboard.D, negative = Devices.Keyboard.A })
			local composite2d = Composite2d.new({
				up = Devices.Keyboard.W,
				down = Devices.Keyboard.S,
				left = Devices.Keyboard.A,
				right = Devices.Keyboard.D,
			})

			expect(function()
				Bindings.new(actions):bind("button", axis1d)
			end).to.throw("Cannot use control with ActionKind.Button")
			expect(function()
				Bindings.new(actions):bind("button", axis2d)
			end).to.throw("Cannot use control with ActionKind.Button")
			expect(function()
				Bindings.new(actions):bind("button", composite1d)
			end).to.throw("Cannot use control with ActionKind.Button")
			expect(function()
				Bindings.new(actions):bind("button", composite2d)
			end).to.throw("Cannot use control with ActionKind.Button")

			expect(function()
				Bindings.new(actions):bind("axis1d", button)
			end).to.throw("Cannot use control with ActionKind.Axis1d")
			expect(function()
				Bindings.new(actions):bind("axis1d", axis2d)
			end).to.throw("Cannot use control with ActionKind.Axis1d")
			expect(function()
				Bindings.new(actions):bind("axis1d", composite2d)
			end).to.throw("Cannot use control with ActionKind.Axis1d")

			expect(function()
				Bindings.new(actions):bind("axis2d", button)
			end).to.throw("Cannot use control with ActionKind.Axis2d")
			expect(function()
				Bindings.new(actions):bind("axis2d", axis1d)
			end).to.throw("Cannot use control with ActionKind.Axis2d")
			expect(function()
				Bindings.new(actions):bind("axis2d", composite1d)
			end).to.throw("Cannot use control with ActionKind.Axis2d")
		end)
	end)
end
