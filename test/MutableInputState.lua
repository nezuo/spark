local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputState = require(ReplicatedStorage.Packages.Spark.InputState)
local Inputs = require(ReplicatedStorage.Packages.Spark.Inputs)

local MutableInputState = setmetatable({}, { __index = InputState })
MutableInputState.__index = MutableInputState

function MutableInputState.new()
	local gamepadButtons = {}
	for keyCode in Inputs.GAMEPAD_BUTTONS do
		gamepadButtons[keyCode] = {}
	end

	return setmetatable({
		state = {
			keycodes = {},
			mouseWheel = 0,
			mouseDelta = Vector2.zero,
			gamepadButtons = gamepadButtons,
		},
	}, MutableInputState)
end

function MutableInputState:press(keycode)
	self.state.keycodes[keycode] = true
end

function MutableInputState:release(keycode)
	self.state.keycodes[keycode] = false
end

function MutableInputState:scroll(delta)
	self.state.mouseWheel = delta
end

function MutableInputState:moveMouse(delta)
	self.state.mouseDelta = delta
end

function MutableInputState:pressGamepad(keycode, gamepad)
	self.state.gamepadButtons[keycode][gamepad] = true
end

function MutableInputState:releaseGamepad(keycode, gamepad)
	self.state.gamepadButtons[keycode][gamepad] = false
end

return MutableInputState
