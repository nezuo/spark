local Promise = require(script.Parent.Parent.Promise)
local Spark = require(script.Parent)

local Rebind = Spark.Rebind
local ValueKind = Spark.ValueKind
local Keyboard = Spark.Devices.Keyboard
local Mouse = Spark.Devices.Mouse

return function()
	it("should return Keyboard.Space", function(context)
		context.press(Enum.KeyCode.Space)

		local input = Rebind.new(ValueKind.Boolean):withDevices({ Keyboard }):start():expect()

		expect(input).to.equal(Keyboard.Space)
	end)

	it("should return input with correct ValueKind", function(context)
		local promise = Rebind.new(ValueKind.Vector2):withDevices({ Keyboard, Mouse }):start()

		context.press(Enum.KeyCode.Space)
		task.wait(0.1)
		expect(promise:getStatus()).to.equal(Promise.Status.Started)

		context.moveMouse(Vector2.one)
		promise:expect()
	end)

	it("should only return a input from a specified device", function(context)
		local promise = Rebind.new(ValueKind.Boolean):withDevices({ Mouse }):start()

		context.press(Enum.KeyCode.Space)
		task.wait(0.1)
		expect(promise:getStatus()).to.equal(Promise.Status.Started)

		context.press(Enum.UserInputType.MouseButton1)
		promise:expect()
	end)

	it("should not return an excluded input", function(context)
		local promise = Rebind.new(ValueKind.Boolean)
			:withDevices({ Keyboard })
			:withoutInputs({ Keyboard.Space })
			:start()

		context.press(Enum.KeyCode.Space)
		task.wait(0.1)
		expect(promise:getStatus()).to.equal(Promise.Status.Started)

		context.press(Enum.KeyCode.W)
		promise:expect()
	end)
end
