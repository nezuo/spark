local UserInputService = game:GetService("UserInputService")

local Inputs = require(script.Parent.Inputs)

--[=[
	Stores input state derived from [UserInputService] and is used to update [Actions].

	:::note
	You should only ever create one `InputState`.
	:::

	@class InputState
]=]
local InputState = {}
InputState.__index = InputState

--[=[
	Creates a new `InputState`.

	@return InputState
]=]
function InputState.new()
	local gamepadButtons = {}
	for keyCode in Inputs.GAMEPAD_BUTTONS do
		gamepadButtons[keyCode] = {}
	end

	local gamepadTriggers = {}
	for keyCode in Inputs.GAMEPAD_TRIGGERS do
		gamepadTriggers[keyCode] = {}
	end

	local state = {
		keycodes = {},
		mouseButtons = {},
		mouseWheel = 0,
		mouseDelta = Vector2.zero,
		gamepadButtons = gamepadButtons,
		gamepadTriggers = gamepadTriggers,
		gamepadThumbsticks = {
			[Enum.KeyCode.Thumbstick1] = {},
			[Enum.KeyCode.Thumbstick2] = {},
		},
	}

	local function onInputBeganOrEnded(inputObject)
		local keyCode = inputObject.KeyCode

		if Inputs.MOUSE_BUTTONS[inputObject.UserInputType] then
			state.mouseButtons[inputObject.UserInputType] = inputObject.UserInputState == Enum.UserInputState.Begin
		elseif Inputs.GAMEPAD_BUTTONS[keyCode] then
			local gamepad = inputObject.UserInputType

			gamepadButtons[keyCode][gamepad] = inputObject.UserInputState == Enum.UserInputState.Begin
		elseif Inputs.GAMEPAD_TRIGGERS[keyCode] then
			local gamepad = inputObject.UserInputType

			gamepadTriggers[keyCode][gamepad] = inputObject.Position.Z
		elseif keyCode ~= Enum.KeyCode.Unknown then
			state.keycodes[keyCode] = inputObject.UserInputState == Enum.UserInputState.Begin
		end
	end

	local function onInputChanged(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			state.mouseDelta = Vector2.new(inputObject.Delta.X, -inputObject.Delta.Y)
		elseif inputObject.UserInputType == Enum.UserInputType.MouseWheel then
			state.mouseWheel = inputObject.Position.Z
		elseif Inputs.GAMEPAD_TRIGGERS[inputObject.KeyCode] then
			local gamepad = inputObject.UserInputType

			gamepadTriggers[inputObject.KeyCode][gamepad] = inputObject.Position.Z
		elseif inputObject.KeyCode == Enum.KeyCode.Thumbstick1 or inputObject.KeyCode == Enum.KeyCode.Thumbstick2 then
			local gamepad = inputObject.UserInputType

			state.gamepadThumbsticks[inputObject.KeyCode][gamepad] =
				Vector2.new(inputObject.Position.X, inputObject.Position.Y)
		end
	end

	UserInputService.InputBegan:Connect(function(inputObject, sunk)
		if not sunk then
			onInputBeganOrEnded(inputObject)
		end
	end)
	UserInputService.InputEnded:Connect(onInputBeganOrEnded)
	UserInputService.InputChanged:Connect(onInputChanged)

	return setmetatable({
		state = state,
	}, InputState)
end

--[=[
	This clears mouse wheel and mouse delta data so it doesn't persist across frames. This should be called once every frame after [Actions:update] is called.
]=]
function InputState:clear()
	self.state.mouseWheel = 0
	self.state.mouseDelta = Vector2.zero
end

function InputState:pressed(input, gamepad)
	if typeof(input) == "EnumItem" then
		if input:IsA("KeyCode") then
			if input == Enum.KeyCode.Thumbstick1 or input == Enum.KeyCode.Thumbstick2 then
				if gamepad == nil then
					return false
				end

				local value = self.state.gamepadThumbsticks[input][gamepad]

				return not not value
			elseif Inputs.GAMEPAD_BUTTONS[input] then
				if gamepad == nil then
					return false
				end

				return self.state.gamepadButtons[input][gamepad] == true
			elseif Inputs.GAMEPAD_TRIGGERS[input] then
				if gamepad == nil or self.state.gamepadTriggers[input][gamepad] == nil then
					return false
				end

				return self.state.gamepadTriggers[input][gamepad] > 0
			else
				return self.state.keycodes[input] == true
			end
		elseif Inputs.MOUSE_BUTTONS[input] then
			return self.state.mouseButtons[input] == true
		elseif input == Enum.UserInputType.MouseMovement then
			return self.state.mouseDelta.Magnitude > 0
		elseif input == Enum.UserInputType.MouseWheel then
			return self.state.mouseWheel ~= 0
		end
	elseif input.kind == "VirtualAxis" then
		return self:axis(input, gamepad) ~= 0
	elseif input.kind == "VirtualAxis2d" then
		local value = self:axis2d(input, gamepad)

		return if value == nil then false else value.Magnitude > 0
	end

	error("Invalid input")
end

function InputState:axis(input, gamepad)
	if typeof(input) == "EnumItem" then
		if input:IsA("KeyCode") then
			if input == Enum.KeyCode.Thumbstick1 or input == Enum.KeyCode.Thumbstick2 then
				if gamepad == nil then
					return 0
				end

				local value = self.state.gamepadThumbsticks[input][gamepad]

				if value == nil then
					return 0
				else
					return value.Magnitude
				end
			elseif Inputs.GAMEPAD_BUTTONS[input] then
				if gamepad == nil then
					return 0
				end

				return if self.state.gamepadButtons[input][gamepad] then 1 else 0
			elseif Inputs.GAMEPAD_TRIGGERS[input] then
				if gamepad == nil then
					return 0
				end

				return self.state.gamepadTriggers[input][gamepad] or 0
			else
				return if self.state.keycodes[input] then 1 else 0
			end
		elseif Inputs.MOUSE_BUTTONS[input] then
			return if self.state.mouseButtons[input] then 1 else 0
		elseif input == Enum.UserInputType.MouseMovement then
			return self.state.mouseDelta.Magnitude
		elseif input == Enum.UserInputType.MouseWheel then
			return self.state.mouseWheel
		end
	elseif input.kind == "VirtualAxis" then
		local positive = if input.positive then self:axis(input.positive, gamepad) else 0
		local negative = if input.negative then self:axis(input.negative, gamepad) else 0

		return positive - negative
	elseif input.kind == "VirtualAxis2d" then
		local value = self:axis2d(input, gamepad)

		return if value == nil then 0 else value.Magnitude
	end

	error("Invalid input")
end

function InputState:axis2d(input, gamepad)
	if input == Enum.UserInputType.MouseMovement then
		return self.state.mouseDelta
	elseif input == Enum.KeyCode.Thumbstick1 or input == Enum.KeyCode.Thumbstick2 then
		return self.state.gamepadThumbsticks[input][gamepad]
	elseif typeof(input) == "table" and input.kind == "VirtualAxis2d" then
		local right = if input.right then self:axis(input.right, gamepad) else 0
		local left = if input.left then self:axis(input.left, gamepad) else 0
		local up = if input.up then self:axis(input.up, gamepad) else 0
		local down = if input.down then self:axis(input.down, gamepad) else 0

		return Vector2.new(right - left, up - down)
	end

	return nil
end

return InputState
