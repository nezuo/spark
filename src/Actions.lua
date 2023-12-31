local UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Signal)

--[=[
	Updates and reads action state.

	```lua
	local actions = Actions.new({ "move", "jump" })

	local disconnect = actions:justPressedSignal("jump"):connect(function()
		print("Jumped!")
	end)

	local moveVector = actions:axis2d("move")
	```

	:::note
	[Actions:update] should be called every frame before calling [InputState:clear].
	:::

	@class Actions
]=]
local Actions = {}
Actions.__index = Actions

--[=[
	Creates a new `Actions`.

	@param actions { string } -- List of action names
	@return Actions
]=]
function Actions.new(actions)
	local state = {}
	local justPressedSignals = {}
	local justReleasedSignals = {}

	for _, action in actions do
		state[action] = {
			manualHolds = 0,
			manualMove = Vector2.zero,
			pressed = false,
			value = 0,
			axis2d = Vector2.zero,
		}
		justPressedSignals[action] = Signal.new()
		justReleasedSignals[action] = Signal.new()
	end

	return setmetatable({
		state = state,
		justPressedSignals = justPressedSignals,
		justReleasedSignals = justReleasedSignals,
	}, Actions)
end

--[=[
	Updates action states.

	This should be called once every frame before calling [InputState:clear].

	@param inputState InputState
	@param inputMap InputMap -- The associated InputMap
]=]
function Actions:update(inputState, inputMap)
	local gamepad = inputMap.associatedGamepad
	if gamepad == nil then
		for _, candidateGamepad in UserInputService:GetConnectedGamepads() do
			if gamepad == nil or candidateGamepad.Value < gamepad.Value then
				gamepad = candidateGamepad
			end
		end
	end

	for action, state in self.state do
		local inputs = inputMap:get(action)
		local pressed = state.manualHolds > 0
			or state.manualMove.Magnitude > 0
			or inputState:anyPressed(inputs, gamepad)
		local wasPressed = state.pressed

		state.pressed = pressed

		local value = 0
		for _, input in inputs do
			value += inputState:value(input, gamepad)
		end

		state.value = value + state.manualMove.Magnitude + state.manualHolds

		local axis2d = state.manualMove
		for _, input in inputs do
			local inputValue = inputState:axis2d(input, gamepad)

			if inputValue ~= nil then
				axis2d += inputValue
			end
		end

		state.axis2d = axis2d

		state.manualMove = Vector2.zero

		if pressed and not wasPressed then
			self.justPressedSignals[action]:fire()
		elseif not pressed and wasPressed then
			self.justReleasedSignals[action]:fire()
		end
	end
end

--[=[
	Returns whether `action` is currently pressed.

	@param action string
	@return boolean
]=]
function Actions:pressed(action)
	return self.state[action].pressed
end

--[=[
	Returns whether `action` is currently released.

	@param action string
	@return boolean
]=]
function Actions:released(action)
	return not self.state[action].pressed
end

--[=[
	Returns a [Signal] that is fired when `action` is pressed.

	```lua
	local disconnect = actions:justPressedSignal("jump"):connect(function()
		print("Jump pressed!")
	end)

	disconnect()
	```

	@param action string
	@return Signal
]=]
function Actions:justPressedSignal(action)
	return self.justPressedSignals[action]
end

--[=[
	Returns a [Signal] that is fired when `action` is released.

	```lua
	local disconnect = actions:justReleasedSignal("jump"):connect(function()
		print("Jump released!")
	end)

	disconnect()
	```

	@param action string
	@return Signal
]=]
function Actions:justReleasedSignal(action)
	return self.justReleasedSignals[action]
end

--[=[
	Returns the sum of the values of each input bound to `action`.

	The value of an input depends on its kind:
	- Buttons have a value of `0` when released and `1` when pressed.
	- [Enum.UserInputType.MouseWheel] returns the `Z` value of [InputObject.Position].
	- [VirtualAxis] returns the value of the positive input minus the value of the negative input.
	- 2D axis values like [Enum.UserInputType.MouseMovement], [Enum.KeyCode.Thumbstick1], or [VirutalAxis2d] will return their magnitude.

	:::warning
	The return value is not clamped to any range.
	:::

	@param action string
	@return number
]=]
function Actions:value(action)
	return self.state[action].value
end

--[=[
	Returns the sum of `Vector2` values of each input bound to `action`.

	The value of an input depends on its kind:
	- Buttons and 1D axis values like [Enum.UserInputType.MouseWheel] or [VirtualAxis] will always return [Vector2.zero].
	- [Enum.KeyCode.Thumbstick1] and [Enum.KeyCode.Thumbstick2] returns the `(X, Y)` value of [InputObject.Position].
	- [Enum.UserInputType.MouseMovement] returns the `(X, -Y)` value of [InputObject.Delta].
	- [VirtualAxis2d] returns `Vector2.new(rightValue - leftValue, upValue - downValue)`.

	:::warning
	The returned Vector2 is not clamped to any range. Consider using [Actions:normalizedAxis2d] or [Actions:clampedAxis2d].
	:::

	@param action string
	@return Vector2
]=]
function Actions:axis2d(action)
	return self.state[action].axis2d
end

--[=[
	Returns the [Actions:axis2d] value but normalized. If the value is `Vector2.zero`, `Vector2.zero` will be returned.

	@param action string
	@return Vector2
]=]
function Actions:normalizedAxis2d(action)
	local state = self.state[action].axis2d

	if state.Magnitude > 0 then
		return state.Unit
	else
		return state
	end
end

--[=[
	Returns the [Actions:axis2d] value but with the length clamped to `1`. This allows for `Vector2s` with a length less than `1` which is useful for gamepad and mobile thumbsticks.

	@param action string
	@return Vector2
]=]
function Actions:clampedAxis2d(action)
	local state = self.state[action].axis2d

	if state.Magnitude > 1 then
		return state.Unit
	else
		return state
	end
end

--[=[
	Presses `action` manually like a button. It returns a function to cancel the hold.

	This can be called more than once at the same time and each call will represent a different button press.

	This is useful to implement mobile buttons.

	:::warning
	The returned function will error if called more than once.
	:::

	@param action string
	@return () -> () -- A function that when called, stops the hold.
]=]
function Actions:hold(action)
	local state = self.state[action]

	state.manualHolds += 1

	local called = false

	return function()
		if called then
			error("Cannot cancel hold instance more than once")
		end

		called = true
		state.manualHolds -= 1
	end
end

--[=[
	Increases the axis2d value of `action` by `vector`.

	This value resets after [Actions:update] is called.

	This is useful to implement a mobile thumbstick.

	@param action string
	@param vector Vector2
	@return Vector2
]=]
function Actions:move(action, vector)
	self.state[action].manualMove += vector
end

return Actions
