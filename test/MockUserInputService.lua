local Signal = require(script.Parent.Signal)

local MockUserInputService = {}
MockUserInputService.__index = MockUserInputService

function MockUserInputService.new()
	return setmetatable({
		InputBegan = Signal.new(),
		InputChanged = Signal.new(),
		InputEnded = Signal.new(),
		_buttonToInputObject = {},
	}, MockUserInputService)
end

function MockUserInputService:getButtonInputObject(button)
	if self._buttonToInputObject[button] == nil then
		local isKeyCode = button:IsA("KeyCode")

		self._buttonToInputObject[button] = {
			Delta = Vector3.zero,
			Position = Vector3.zero,
			KeyCode = if isKeyCode then button else Enum.KeyCode.Unknown,
			UserInputState = Enum.UserInputState.Begin,
			UserInputType = if isKeyCode then Enum.UserInputType.Keyboard else button,
		}
	end

	return self._buttonToInputObject[button]
end

function MockUserInputService:press(button)
	local inputObject = self:getButtonInputObject(button)

	inputObject.UserInputState = Enum.UserInputState.Begin

	self.InputBegan:Fire(inputObject, false)
end

function MockUserInputService:release(button)
	local inputObject = self:getButtonInputObject(button)

	inputObject.UserInputState = Enum.UserInputState.End

	self.InputEnded:Fire(inputObject, false)
end

function MockUserInputService:moveMouse(delta)
	local inputObject = {
		Delta = delta,
		KeyCode = Enum.KeyCode.Unknown,
		Position = Vector3.zero,
		UserInputType = Enum.UserInputType.MouseMovement,
		UserInputState = Enum.UserInputState.Change,
	}

	self.InputBegan:Fire(inputObject, false)
end

function MockUserInputService:moveScrollWheel(delta)
	local inputObject = {
		Delta = Vector3.zero,
		KeyCode = Enum.KeyCode.Unknown,
		Position = Vector3.new(0, 0, delta),
		UserInputType = Enum.UserInputType.MouseWheel,
		UserInputState = Enum.UserInputState.Change,
	}

	self.InputBegan:Fire(inputObject, false)
end

return MockUserInputService
