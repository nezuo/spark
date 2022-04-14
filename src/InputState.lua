local UserInputService = game:GetService("UserInputService")

local ActionKind = require(script.Parent.ActionKind)
local defaultActionValues = require(script.Parent.defaultActionValues)
local Devices = require(script.Parent.Devices)
local ValueKind = require(script.Parent.ValueKind)

local defaultInputValues = {
	[ValueKind.Boolean] = false,
	[ValueKind.Number] = 0,
	[ValueKind.Vector2] = Vector2.zero,
}

local actionKindToValueKind = {
	[ActionKind.Axis1d] = ValueKind.Number,
	[ActionKind.Axis2d] = ValueKind.Vector2,
	[ActionKind.Button] = ValueKind.Boolean,
}

local function getActionValue(action, inputs)
	if inputs == nil or #inputs == 0 then
		return defaultActionValues[action._actionKind]
	end

	local highestActuation
	local mostActuated
	for _, input in pairs(inputs) do
		local actuation = input:_getActuation()

		if mostActuated == nil or actuation > highestActuation then
			highestActuation = actuation
			mostActuated = input
		end
	end

	return mostActuated:_getValue()
end

local function updateAction(action, inputs)
	local newValue = getActionValue(action, inputs)

	if action:get() == newValue then
		return
	end

	action._value = newValue
	action._subject:notify(newValue)
end

local function validateInputMap(actions)
	for name, inputs in pairs(actions.inputMap._map) do
		local action = actions:get(name)

		if action == nil then
			error(string.format("InputMap contains invalid action called '%s'", name))
		end

		for _, input in ipairs(inputs) do
			assert(
				actionKindToValueKind[action._actionKind] == input._valueKind,
				string.format(
					"Input of %s cannot be used with action '%s' of %s",
					tostring(input._valueKind),
					name,
					tostring(action._actionKind)
				)
			)
		end
	end
end

--[=[
	An InputState updates all inputs and actions.

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
	local userInputService = if InputState._userInputService ~= nil
		then InputState._userInputService
		else UserInputService

	local inputTypeToInputs = {}
	local resetableInputs = {}
	for _, device in pairs(Devices) do
		for _, input in pairs(device) do
			if inputTypeToInputs[input._inputType] == nil then
				inputTypeToInputs[input._inputType] = {}
			end

			if input._doesReset then
				table.insert(resetableInputs, input)
			end

			table.insert(inputTypeToInputs[input._inputType], input)
		end
	end

	local function onInputUpdated(inputObject, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		local inputType = if inputObject.KeyCode == Enum.KeyCode.Unknown
			then inputObject.UserInputType
			else inputObject.KeyCode

		if inputTypeToInputs[inputType] ~= nil then
			for _, input in ipairs(inputTypeToInputs[inputType]) do
				input:_update(inputObject)
			end
		end
	end

	userInputService.InputBegan:Connect(onInputUpdated)
	userInputService.InputEnded:Connect(onInputUpdated)
	userInputService.InputChanged:Connect(onInputUpdated)

	return setmetatable({
		_actions = {},
		_resetableInputs = resetableInputs,
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

	After updating the actions, it will also reset inputs like [`Mouse.Delta`](/api/Mouse#Delta).

	@error Invalid action in InputMap -- Throws when an Action's InputMap contains an invalid action
	@error Invalid input in InputMap -- Throws when an Action's InputMap contains an input that does not match the corresponding action's ActionKind.
]=]
function InputState:update()
	for _, actions in ipairs(self._actions) do
		validateInputMap(actions)

		for name, action in pairs(actions._actions) do
			updateAction(action, actions.inputMap._map[name])
		end
	end

	for _, input in ipairs(self._resetableInputs) do
		input._value = defaultInputValues[input._valueKind]
		input._actuation = 0
	end
end

return InputState
