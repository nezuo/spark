local UserInputService = game:GetService("UserInputService")

local Bindings = require(script.Parent.Binding.Bindings)
local Signal = require(script.Parent.Signal)
local getDeviceFromInput = require(script.Parent.getDeviceFromInput)

local function isInputInDevices(input, devices)
	if typeof(input) == "table" then
		if input.kind == "VirtualAxis" then
			for _, direction in { "positive", "negative" } do
				if table.find(devices, getDeviceFromInput(input[direction])) then
					return true
				end
			end
		elseif input.kind == "VirtualAxis2d" then
			for _, direction in { "up", "down", "left", "right" } do
				if table.find(devices, getDeviceFromInput(input[direction])) then
					return true
				end
			end
		end
	end

	return table.find(devices, getDeviceFromInput(input)) ~= nil
end

--[=[
	`Actions` allows you to bind inputs to actions and read their state.

	```lua
	local actions = Actions.new({ "move", "jump" }):setRebuildBindings(function(bindings)
		bindings:bind("move", VirtualAxis2d.new({
			up = Enum.KeyCode.W,
			down = Enum.KeyCode.S,
			left = Enum.KeyCode.A,
			right = Enum.KeyCode.D
		}))
		bindings:bind("jump", Enum.KeyCode.Space)
	end)

	local disconnect = actions:justPressedSignal("jump"):connect(function()
		print("Jumped!")
	end)

	local moveVector = actions:axis2d("move")
	```

	To get auto-completion and type checking for the action names, cast Actions like this:
	```lua
	local actions = (Actions.new({ "move", "jump" }) :: any) :: Spark.Actions<"move" | "jump">
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
	local states = {}
	local justPressedSignals = {}
	local justReleasedSignals = {}
	for _, action in actions do
		states[action] = {
			manualPresses = 0,
			manualMoveAxis = 0,
			manualMoveAxis2d = Vector2.zero,
			pressed = false,
			axis = 0,
			axis2d = Vector2.zero,
		}
		justPressedSignals[action] = Signal.new()
		justReleasedSignals[action] = Signal.new()
	end

	return setmetatable({
		states = states,
		justPressedSignals = justPressedSignals,
		justReleasedSignals = justReleasedSignals,

		rebuildBindingsCallback = function() end,

		actionToBinds = {},
		actionToModifiers = {},

		associatedGamepad = nil,
	}, Actions)
end

--[=[
	Sets the gamepad that will be used to check for gamepad inputs.

	```lua
	local actions = Actions.new({ "move", "jump" })
	actions:setAssociatedGamepad(Enum.UserInputType.Gamepad1)
	```

	@param gamepad Enum.UserInputType
]=]
function Actions:setAssociatedGamepad(gamepad)
	self.associatedGamepad = gamepad
end

--[=[
	Removes the associated gamepad and instead uses the first connected gamepad.

]=]
function Actions:removeAssociatedGamepad()
	self.associatedGamepad = nil
end

--[=[
	Sets the callback that binds inputs to actions.

	The callback will be called in this function and whenever [Actions:rebuildBindings] is called.

	```lua
	local actions = Actions.new({ "move", "jump" }):setRebuildBindings(function(bindings)
		bindings:bind("jump", Enum.KeyCode.Space)
	end)
	```

	@param rebuildBindings (bindings: Bindings) -> ()
	@return Actions -- Returns self
]=]
function Actions:setRebuildBindings(rebuildBindings)
	self.rebuildBindingsCallback = rebuildBindings

	self:rebuildBindings()

	return self
end

--[=[
	Updates action bindings by calling the callback set by [Actions:setRebuildBindings].
]=]
function Actions:rebuildBindings()
	local bindings = Bindings.new()

	self.rebuildBindingsCallback(bindings)

	table.clear(self.actionToBinds)
	table.clear(self.actionToModifiers)

	for action in self.states do
		self.actionToBinds[action] = bindings.actionToBinds[action] or {}
		self.actionToModifiers[action] = bindings.actionToModifiers[action] or {}
	end
end

--[=[
	Updates action states.

	This should be called once every frame before calling [InputState:clear].

	@param inputState InputState
]=]
function Actions:update(inputState)
	local gamepad = self.associatedGamepad
	if gamepad == nil then
		for _, candidateGamepad in UserInputService:GetConnectedGamepads() do
			if gamepad == nil or candidateGamepad.Value < gamepad.Value then
				gamepad = candidateGamepad
			end
		end
	end

	for action, state in self.states do
		local pressed = state.manualPresses > 0
			or state.manualMoveAxis2d.Magnitude > 0
			or math.abs(state.manualMoveAxis) > 0
		local axis = state.manualMoveAxis2d.Magnitude + state.manualPresses + state.manualMoveAxis

		local axis2d = state.manualMoveAxis2d
		for _, bind in self.actionToBinds[action] do
			for _, input in bind.inputs do
				local inputPressed = inputState:pressed(input, gamepad)
				local inputAxis = inputState:axis(input, gamepad)
				local inputAxis2d = inputState:axis2d(input, gamepad) or Vector2.zero

				for _, modifier in bind.modifiers do
					inputPressed, inputAxis, inputAxis2d = modifier(inputPressed, inputAxis, inputAxis2d)
				end

				pressed = pressed or inputPressed
				axis += inputAxis
				axis2d += inputAxis2d
			end
		end

		for _, modifier in self.actionToModifiers[action] do
			pressed, axis, axis2d = modifier(pressed, axis, axis2d)
		end

		local wasPressed = state.pressed

		state.pressed = pressed
		state.axis = axis
		state.axis2d = axis2d

		state.manualPresses = 0
		state.manualMoveAxis = 0
		state.manualMoveAxis2d = Vector2.zero

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
	return self.states[action].pressed
end

--[=[
	Returns whether `action` is currently released.

	@param action string
	@return boolean
]=]
function Actions:released(action)
	return not self.states[action].pressed
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
	Returns the sum of the axis values of each input bound to `action`.

	The axis value of an input depends on its kind:
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
function Actions:axis(action)
	return self.states[action].axis
end

--[=[
	Returns the sum of axis 2D values of each input bound to `action`.

	The axis 2D value of an input depends on its kind:
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
	return self.states[action].axis2d
end

--[=[
	Returns the [Actions:axis2d] value but normalized. If the value is `Vector2.zero`, `Vector2.zero` will be returned.

	@param action string
	@return Vector2
]=]
function Actions:normalizedAxis2d(action)
	local state = self.states[action].axis2d

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
	local state = self.states[action].axis2d

	if state.Magnitude > 1 then
		return state.Unit
	else
		return state
	end
end

function Actions:press(action)
	self.states[action].manualPresses += 1
end

--[=[
	Increases the axis value of `action` by `value`.

	This value resets after [Actions:update] is called.

	@param action string
	@param value number
]=]
function Actions:moveAxis(action, value)
	self.states[action].manualMoveAxis += value
end

--[=[
	Increases the axis 2D value of `action` by `value`.

	This value resets after [Actions:update] is called.

	@param action string
	@param value Vector2
]=]
function Actions:moveAxis2d(action, value)
	self.states[action].manualMoveAxis2d += value
end

--[=[
	Returns the list of inputs bound to `action` that belong to the given `devices`.

	If a [VirtualAxis] or [VirtualAxis2d] has a [Button] that belongs to `deviecs` it will be included.

	```lua
	local actions = Actions.new({ "action" }):setRebuildBindings(function(bindings)
		bindings:bind("action", Enum.KeyCode.Space, Enum.UserInputType.MouseButton1)
	end)

	print(actions:getInputsByDevices("action", { "Keyboard" })) -- { Enum.KeyCode.Space }
	print(actions:getInputsByDevices("action", { "Mouse" })) -- { Enum.UserInputType.MouseButton1 }
	```

	@param action string
	@param devices { Device }
	@return { Input }
]=]
function Actions:getInputsByDevices(action, devices)
	local inputs = {}
	for _, bind in self.actionToBinds[action] do
		for _, input in bind.inputs do
			if isInputInDevices(input, devices) then
				table.insert(inputs, input)
			end
		end
	end

	return table.freeze(inputs)
end

return Actions
