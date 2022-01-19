local UserInputService = game:GetService("UserInputService")

local defaultActionValues = require(script.Parent.defaultActionValues)
local Devices = require(script.Parent.Devices)

local function getActionValue(action, bindings)
	if bindings == nil or #bindings == 0 then
		return defaultActionValues[action._actionKind]
	end

	local highestActuation
	local mostActuated
	for _, control in ipairs(bindings) do
		local actuation = control:_getActuation()

		if mostActuated == nil or actuation > highestActuation then
			highestActuation = actuation
			mostActuated = control
		end
	end

	return mostActuated:_getValue()
end

local function updateAction(action, bindings)
	local newValue = getActionValue(action, bindings)

	if action:get() == newValue then
		return
	end

	action._value = newValue
	action._subject:notify(newValue)
end

--[=[
	An InputState updates all controls and actions.

	:::warning
	You should only create one InputState.
	:::

	@class InputState
]=]
local InputState = {}
InputState.__index = InputState

--[=[
	Create a new InputState.

	@return InputState
]=]
function InputState.new()
	local userInputService =
		if InputState._userInputService ~= nil then InputState._userInputService else  UserInputService

	local inputTypeToControls = {}
	local resetableControls = {}
	for _, device in pairs(Devices) do
		for _, control in pairs(device) do
			if inputTypeToControls[control._inputType] == nil then
				inputTypeToControls[control._inputType] = {}
			end

			if control._doesReset then
				table.insert(resetableControls, control)
			end

			table.insert(inputTypeToControls[control._inputType], control)
		end
	end

	local function onInputUpdated(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		local inputType = if input.KeyCode == Enum.KeyCode.Unknown then input.UserInputType else input.KeyCode

		if inputTypeToControls[inputType] ~= nil then
			for _, control in ipairs(inputTypeToControls[inputType]) do
				control:_update(input)
			end
		end
	end

	userInputService.InputBegan:Connect(onInputUpdated)
	userInputService.InputChanged:Connect(onInputUpdated)

	return setmetatable({
		_actions = {},
		_resetableControls = resetableControls,
	}, InputState)
end

--[=[
	Actions added to the InputState will be updated when [`InputState:update`](/api/InputState#update) is called.

	@param actions Actions
]=]
function InputState:addActions(actions)
	table.insert(self._actions, actions)
end

--[=[
	Updates all actions added to the InputState.

	After updating the actions, it will also reset controls like Mouse.Delta (TODO LINK?).
]=]
function InputState:update()
	for _, actions in ipairs(self._actions) do
		for _, action in pairs(actions._actions) do
			local bindings = if actions._bindings ~= nil then actions._bindings._bindings[action] else nil

			updateAction(action, bindings)
		end
	end

	for _, control in ipairs(self._resetableControls) do
		control._value = defaultActionValues[control._actionKind]
		control._actuation = 0
	end
end

return InputState
