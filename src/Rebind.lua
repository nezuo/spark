local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Parent.Promise)

local REQUIRED_ACTUATION = 0.2

--[=[
	A Rebind is used for getting an input the user actuates.

	You can create a query with specific devices and inputs and then call [`Rebind:start`](/api/Rebind/start) to get a promise that
	resolves with the first input matching the query that the user actuates.

	```lua
	local input = Rebind.new(ValueKind.Boolean)
		:withDevices({ Devices.Keyboard })
		:withoutInputs({ Devices.Keyboard.Space })
		:start()
		:expect()
	```

	@class Rebind
]=]
local Rebind = {}
Rebind.__index = Rebind

--[=[
	Creates a new Rebind.

	@param valueKind ValueKind -- Rebind returns inputs that are `valueKind`.
	@return Rebind
]=]
function Rebind.new(valueKind)
	return setmetatable({
		_valueKind = valueKind,
		_excludedInputs = {},
		_devices = {},
	}, Rebind)
end

--[=[
	Excludes all `inputs`.

	@param inputs { Input }
	@return Rebind
]=]
function Rebind:withoutInputs(inputs)
	for _, input in ipairs(inputs) do
		self._excludedInputs[input] = true
	end

	return self
end

--[=[
	Uses inputs from the `devices`.

	@param devices { Device }
	@return Rebind
]=]
function Rebind:withDevices(devices)
	for _, device in ipairs(devices) do
		self._devices[device] = true
	end

	return self
end

--[=[
	Returns a promise that resolves with an [`Input`](/api/Input) that matches the query.

	The promise will reject if there are no inputs that match the query.

	@return Promise
]=]
function Rebind:start()
	local validInputs = {}

	for device in pairs(self._devices) do
		for _, input in pairs(device) do
			if self._excludedInputs[input] == nil and input._valueKind == self._valueKind then
				table.insert(validInputs, input)
			end
		end
	end

	if #validInputs == 0 then
		return Promise.reject("There are no valid inputs.")
	end

	return Promise.new(function(resolve, _, onCancel)
		local connection
		connection = RunService.Heartbeat:Connect(function()
			for _, input in ipairs(validInputs) do
				if input:_getActuation() >= REQUIRED_ACTUATION then
					connection:Disconnect()
					resolve(input)
				end
			end
		end)

		onCancel(function()
			connection:Disconnect()
		end)
	end)
end

return Rebind
