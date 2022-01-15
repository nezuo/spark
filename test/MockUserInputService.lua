local Signal = require(script.Parent.Signal)

local MockUserInputService = {}
MockUserInputService.__index = MockUserInputService

function MockUserInputService.new()
	return setmetatable({
		InputBegan = Signal.new(),
		InputChanged = Signal.new(),
		InputEnded = Signal.new(),
		_inputObjects = {},
	}, MockUserInputService)
end

function MockUserInputService:_getOrCreateInputObject(keyCode, userInputType)
	if self._inputObjects[keyCode] == nil then
		self._inputObjects[keyCode] = {
			Delta = Vector3.zero, -- Is this not zero if we move the mouse in the same frame?
			KeyCode = keyCode,
			Position = Vector3.zero, -- todo?
			UserInputType = userInputType,
		}
	end

	return self._inputObjects[keyCode]
end

function MockUserInputService:press(keyCode)
	local inputObject = self:_getOrCreateInputObject(keyCode, Enum.UserInputType.Keyboard)

	inputObject.UserInputState = Enum.UserInputState.Begin

	self.InputBegan:Fire(inputObject, false)
end

function MockUserInputService:release(keyCode)
	local inputObject = self:_getOrCreateInputObject(keyCode, Enum.UserInputType.Keyboard)

	inputObject.UserInputState = Enum.UserInputState.End

	self.InputBegan:Fire(inputObject, false)
end

function MockUserInputService:moveMouse(delta)
	local inputObject = {
		Delta = delta,
		KeyCode = Enum.KeyCode.Unknown,
		Position = Vector3.zero, -- todo?
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
