local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Parent.Promise)

local REQUIRED_ACTUATION = 0.2

--[=[
	@type Control ButtonControl | Axis1dControl | Axis2dControl | Composite1d | Composite2d
	@within Rebind
]=]

--[=[
	@type Device { [string]: Control }
	@within Rebind
]=]

--[=[
	A Rebind is used for getting a control the user actuates.

	You specify what devices you care about and can exclude controls. Then you call the [`Rebind:start`](/api/Rebind/start) method to get
	a promise that resolves with the first control the user actuates.

	```lua
	local control = Rebind.new(ValueKind.Boolean)
		:withDevices({ Devices.Keyboard })
		:withoutControls({ Devices.Keyboard.Space })
		:start()
		:expect()
	```

	@class Rebind
]=]
local Rebind = {} -- TODO: Come up with a better name.
Rebind.__index = Rebind

--[=[
	Creates a new Rebind.

	@param valueKind ValueKind -- Rebind returns controls that are `valueKind`.
	@return Rebind
]=]
function Rebind.new(valueKind)
	return setmetatable({
		_valueKind = valueKind,
		_excludedControls = {},
		_devices = {},
	}, Rebind)
end

--[=[
	Excludes all `controls`.

	@param controls { Control }
	@return Rebind
]=]
function Rebind:withoutControls(controls)
	for _, control in ipairs(controls) do
		self._excludedControls[control] = true
	end

	return self
end

--[=[
	Uses controls from the `devices`.

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
	Returns a promise that resolves with a Control that matches the query.

	The promise will reject if there are no controls that match the query.

	@return Promise
]=]
function Rebind:start()
	local validControls = {}

	for device in pairs(self._devices) do
		for _, control in pairs(device) do
			if self._excludedControls[control] == nil and control._valueKind == self._valueKind then
				table.insert(validControls, control)
			end
		end
	end

	if #validControls == 0 then
		return Promise.reject("There are no valid controls.")
	end

	return Promise.new(function(resolve, _, onCancel)
		local connection
		connection = RunService.Heartbeat:Connect(function()
			for _, control in ipairs(validControls) do
				if control:_getActuation() >= REQUIRED_ACTUATION then
					connection:Disconnect()
					resolve(control)
				end
			end
		end)

		onCancel(function()
			connection:Disconnect()
		end)
	end)
end

return Rebind
