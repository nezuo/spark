local UserInputService = game:GetService("UserInputService")

local Inputs = require(script.Parent.Inputs)

local DEFAULT_DEADZONE = 0.1

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

	local state = {
		keycodes = {},
		mouseButtons = {},
		mouseWheel = 0,
		mouseDelta = Vector2.zero,
		gamepadButtons = gamepadButtons,
		gamepadThumbsticks = {
			[Enum.KeyCode.Thumbstick1] = {},
			[Enum.KeyCode.Thumbstick2] = {},
		},
	}

	local function onInputBeganOrEnded(inputObject, sunk)
		if sunk then
			return
		end

		local keyCode = inputObject.KeyCode

		if Inputs.MOUSE_BUTTONS[inputObject.UserInputType] then
			state.mouseButtons[inputObject.UserInputType] = inputObject.UserInputState == Enum.UserInputState.Begin
		elseif Inputs.GAMEPAD_BUTTONS[keyCode] then
			local gamepad = inputObject.UserInputType

			gamepadButtons[keyCode][gamepad] = inputObject.UserInputState == Enum.UserInputState.Begin
		elseif keyCode ~= Enum.KeyCode.Unknown then
			state.keycodes[keyCode] = inputObject.UserInputState == Enum.UserInputState.Begin
		end
	end

	local function onInputChanged(inputObject, sunk)
		if sunk then
			return
		end

		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			state.mouseDelta = Vector2.new(inputObject.Delta.X, -inputObject.Delta.Y)
		elseif inputObject.UserInputType == Enum.UserInputType.MouseWheel then
			state.mouseWheel = inputObject.Position.Z
		elseif inputObject.KeyCode == Enum.KeyCode.Thumbstick1 or inputObject.KeyCode == Enum.KeyCode.Thumbstick2 then
			local gamepad = inputObject.UserInputType

			state.gamepadThumbsticks[inputObject.KeyCode][gamepad] =
				Vector2.new(inputObject.Position.X, inputObject.Position.Y)
		end
	end

	UserInputService.InputBegan:Connect(onInputBeganOrEnded)
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

				return if value == nil then false else value.Magnitude >= DEFAULT_DEADZONE
			elseif Inputs.GAMEPAD_BUTTONS[input] then
				if gamepad == nil then
					return false
				end

				return self.state.gamepadButtons[input][gamepad] == true
			else
				return self.state.keycodes[input]
			end
		elseif Inputs.MOUSE_BUTTONS[input] then
			return self.state.mouseButtons[input]
		elseif input == Enum.UserInputType.MouseMovement then
			return self.state.mouseDelta.Magnitude > 0
		elseif input == Enum.UserInputType.MouseWheel then
			return self.state.mouseWheel ~= 0
		end
	elseif input.kind == "VirtualAxis" then
		return self:value(input, gamepad) ~= 0
	elseif input.kind == "VirtualAxis2d" or input.kind == "Multiply2d" then
		local value = self:axis2d(input, gamepad)

		return if value == nil then false else value.Magnitude > 0
	end

	error("Invalid input")
end

function InputState:value(input, gamepad)
	if typeof(input) == "EnumItem" then
		if input:IsA("KeyCode") then
			if input == Enum.KeyCode.Thumbstick1 or input == Enum.KeyCode.Thumbstick2 then
				if gamepad == nil then
					return 0
				end

				local value = self.state.gamepadThumbsticks[input][gamepad]

				if value == nil or value.Magnitude < DEFAULT_DEADZONE then
					return 0
				else
					return value.Magnitude
				end
			elseif Inputs.GAMEPAD_BUTTONS[input] then
				if gamepad == nil then
					return 0
				end

				return if self.state.gamepadButtons[input][gamepad] then 1 else 0
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
		local positive = if input.positive then self:value(input.positive, gamepad) else 0
		local negative = if input.negative then self:value(input.negative, gamepad) else 0

		return positive - negative
	elseif input.kind == "VirtualAxis2d" or input.kind == "Multiply2d" then
		local value = self:axis2d(input, gamepad)

		return if value == nil then 0 else value.Magnitude
	end

	error("Invalid input")
end

function InputState:axis2d(input, gamepad)
	if input == Enum.UserInputType.MouseMovement then
		return self.state.mouseDelta
	elseif input == Enum.KeyCode.Thumbstick1 or input == Enum.KeyCode.Thumbstick2 then
		local value = self.state.gamepadThumbsticks[input][gamepad]

		if value ~= nil and value.Magnitude >= DEFAULT_DEADZONE then
			return value
		end
	elseif typeof(input) == "table" then
		if input.kind == "VirtualAxis2d" then
			local right = if input.right then self:value(input.right, gamepad) else 0
			local left = if input.left then self:value(input.left, gamepad) else 0
			local up = if input.up then self:value(input.up, gamepad) else 0
			local down = if input.down then self:value(input.down, gamepad) else 0

			return Vector2.new(right - left, up - down)
		elseif input.kind == "Multiply2d" then
			local value = self:axis2d(input.input, gamepad)

			if value ~= nil then
				return value * input.multiplier
			end
		end
	end

	return nil
end

function InputState:anyPressed(inputs, gamepad)
	for _, input in inputs do
		if self:pressed(input, gamepad) then
			return true
		end
	end

	return false
end

return InputState
