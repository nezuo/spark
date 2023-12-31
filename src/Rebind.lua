local UserInputService = game:GetService("UserInputService")

local getDeviceFromInput = require(script.Parent.getDeviceFromInput)
local Inputs = require(script.Parent.Inputs)
local Promise = require(script.Parent.Parent.Promise)

--[=[
    @type Device "Keyboard" | "Mouse" | "Gamepad"
    @within Rebind
]=]

--[=[
	Queries for the first button a user presses. This is useful for rebinding based on user input.

	```lua
	Rebind.new()
		:withDevices({ "Keyboard", "Mouse" })
		:withoutInputs({ Enum.KeyCode.Escape })
		:start()
		:andThen(function(button)
			print("User pressed", button)
		end)
	```

	@class Rebind
]=]
local Rebind = {}
Rebind.__index = Rebind

--[=[
	Creates a new `Rebind`. To query for a button, call [Rebind:start].

	@return Rebind
]=]
function Rebind.new()
	return setmetatable({
		devices = {},
		excludedInputs = {},
	}, Rebind)
end

--[=[
	By default, inputs from all devices are included. When called, this method will only include the specified `devices`.

	@param devices { Device }
	@return Rebind -- Returns self
]=]
function Rebind:withDevices(devices)
	for _, device in devices do
		self.devices[device] = true
	end

	return self
end

--[=[
	Excludes `inputs` from being chosen.

	@param inputs { Button }
	@return Rebind -- Returns self
]=]
function Rebind:withoutInputs(inputs)
	for _, input in inputs do
		self.excludedInputs[input] = true
	end

	return self
end

--[=[
	Returns a [Promise](https://eryn.io/roblox-lua-promise/api/Promise) that resolves with the first [Button] the user presses.

	The promise can be cancelled if you no longer need the result.

	@return Promise<Button>
]=]
function Rebind:start()
	return Promise.new(function(resolve, _, onCancel)
		local connection
		connection = UserInputService.InputBegan:Connect(function(inputObject)
			local input = if inputObject.KeyCode == Enum.KeyCode.Unknown
				then inputObject.UserInputType
				else inputObject.KeyCode

			-- The only UserInputType buttons are mouse buttons.
			if input:IsA("UserInputType") and Inputs.MOUSE_BUTTONS[input] == nil then
				return
			end

			if self.excludedInputs[input] then
				return
			end

			if next(self.devices) and self.devices[getDeviceFromInput(input)] == nil then
				return
			end

			resolve(input)
			connection:Disconnect()
		end)

		onCancel(function()
			connection:Disconnect()
		end)
	end)
end

return Rebind
