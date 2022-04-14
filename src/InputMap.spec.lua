local Spark = require(script.Parent)

local InputMap = Spark.InputMap
local Keyboard = Spark.Devices.Keyboard
local Composite1d = Spark.Composite1d
local Composite2d = Spark.Composite2d

return function()
	local inputMap
	beforeEach(function()
		inputMap = InputMap.new()
	end)

	describe("InputMap:insert", function()
		it("should remove and re-insert input when it already exists", function()
			inputMap:insert("action", Keyboard.Space)
			inputMap:insert("action", Keyboard.A)
			inputMap:insert("action", Keyboard.Space)

			local inputs = inputMap:get("action")

			expect(inputs[1]).to.equal(Keyboard.A)
			expect(inputs[2]).to.equal(Keyboard.Space)
			expect(#inputs).to.equal(2)
		end)
	end)

	describe("InputMap:insertMultiple", function()
		it("should insert multiple inputs", function()
			inputMap:insertMultiple("action", { Keyboard.E, Keyboard.F })

			local inputs = inputMap:get("action")

			expect(inputs[1]).to.equal(Keyboard.E)
			expect(inputs[2]).to.equal(Keyboard.F)
		end)
	end)

	describe("InputMap:get", function()
		it("should return an empty table", function()
			local inputs = inputMap:get("foo")

			expect(inputs).to.be.a("table")
			expect(#inputs).to.equal(0)
		end)

		it("should return correct inputs", function()
			inputMap:insert("action", Keyboard.Space)

			local inputs = inputMap:get("action")

			expect(inputs).to.be.a("table")
			expect(#inputs).to.equal(1)
			expect(inputs[1]).to.equal(Keyboard.Space)
		end)
	end)

	describe("InputMap:remove", function()
		it("should remove input from input map", function()
			inputMap:insert("action", Keyboard.Space)
			inputMap:remove("action", Keyboard.Space)

			expect(#inputMap:get("action")).to.equal(0)
		end)
	end)

	describe("InputMap:serialize", function()
		it("should serialize and deserialize", function()
			inputMap
				:insertMultiple("button", { Keyboard.O, Keyboard.I })
				:insertMultiple("axis1d", {
					Composite1d.new({
						positive = Keyboard.W,
						negative = Keyboard.S,
					}),
					Composite1d.new({
						positive = Keyboard.A,
					}),
				})
				:insertMultiple("axis2d", {
					Composite2d.new({
						up = Keyboard.W,
						down = Keyboard.S,
						left = Keyboard.A,
						right = Keyboard.D,
					}),
					Composite2d.new({
						up = Keyboard.E,
						down = Keyboard.Q,
					}),
				})

			local deserialized = InputMap.fromSerialized(inputMap:serialize())

			local buttonInputs = deserialized:get("button")

			expect(#buttonInputs).to.equal(2)
			expect(buttonInputs[1]).to.equal(Keyboard.O)
			expect(buttonInputs[2]).to.equal(Keyboard.I)

			local axis1dInputs = deserialized:get("axis1d")

			expect(#axis1dInputs).to.equal(2)
			expect(axis1dInputs[1].positive).to.equal(Keyboard.W)
			expect(axis1dInputs[1].negative).to.equal(Keyboard.S)
			expect(axis1dInputs[2].positive).to.equal(Keyboard.A)
			expect(axis1dInputs[2].negative).never.to.be.ok()

			local axis2dInputs = deserialized:get("axis2d")

			expect(#axis2dInputs).to.equal(2)
			expect(axis2dInputs[1].up).to.equal(Keyboard.W)
			expect(axis2dInputs[1].down).to.equal(Keyboard.S)
			expect(axis2dInputs[1].left).to.equal(Keyboard.A)
			expect(axis2dInputs[1].right).to.equal(Keyboard.D)
			expect(axis2dInputs[2].up).to.equal(Keyboard.E)
			expect(axis2dInputs[2].down).to.equal(Keyboard.Q)
			expect(axis2dInputs[2].left).never.to.be.ok()
			expect(axis2dInputs[2].right).never.to.be.ok()
		end)
	end)
end
