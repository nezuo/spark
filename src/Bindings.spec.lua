local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Spark = require(script.Parent)
local equalsDeep = require(ReplicatedStorage.equalsDeep)

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

	describe("Bindings:bind", function()
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

	describe("Bindings:filter", function()
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

	describe("Bindings:forEachComposite", function()
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

	describe("Bindings:serialize", function()
		-- TODO: This tests the internal implementation!
		itFOCUS("should serialize and deserialize", function()
			local serialized = actions.bindings:serialize()

			local oldBindings = actions.bindings._bindings
			local newBindings = Bindings.fromSerialized(actions, serialized)._bindings

			assert(equalsDeep(oldBindings, newBindings))

			-- for action, bindings in pairs(oldBindings) do
			-- 	assert(#bindings == #newBindings[action], "Both bindings should have some number of controls")

			-- 	for index, binding in pairs(bindings) do
			-- 		print(binding)
			-- 		local newBinding = newBindings[action][index]

			-- 		assert(binding.control == newBinding.control, "Bindings' controls are not the same")
			-- 	end
			-- end

			-- for action in pairs(newBindings) do
			-- 	assert(oldBindings[action] ~= nil, "New bindings have an extra action")
			-- end
		end)
	end)
end
