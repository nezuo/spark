export type Button = Enum.KeyCode | Enum.UserInputType
export type VirtualAxis = {
	kind: "VirtualAxis",
	positive: Button?,
	negative: Button?,
}
export type VirtualAxis2d = {
	kind: "VirtualAxis2d",
	up: Button?,
	down: Button?,
	left: Button?,
	right: Button?,
}
export type Input = Button | VirtualAxis | VirtualAxis2d

export type Modifier = (pressed: boolean, axis: number, axis2d: Vector2) -> (boolean, number, Vector2)

export type Bind = {
	addModifiers: (self: Bind, ...Modifier) -> Bind,
}

export type ActionConfig = {
	addModifiers: (self: ActionConfig, ...Modifier) -> ActionConfig,
}

export type Bindings<T> = {
	bind: (self: Bindings<T>, action: T, ...Input | Bind) -> ActionConfig,
}

export type Actions<T> = {
	setRebuildBindings: (self: Actions<T>, rebuildBindings: (bindings: Bindings<T>) -> ()) -> Actions<T>,
	rebuildBindings: (self: Actions<T>) -> (),
	update: (self: Actions<T>, inputState: InputState) -> (),
	pressed: (self: Actions<T>, action: T) -> boolean,
	released: (self: Actions<T>, action: T) -> boolean,
	justPressedSignal: (self: Actions<T>, action: T) -> Signal,
	justReleasedSignal: (self: Actions<T>, action: T) -> Signal,
	axis: (self: Actions<T>, action: T) -> number,
	axis2d: (self: Actions<T>, action: T) -> Vector2,
	normalizedAxis2d: (self: Actions<T>, action: T) -> Vector2,
	clampedAxis2d: (self: Actions<T>, action: T) -> Vector2,
	press: (self: Actions<T>, action: T) -> (),
	moveAxis: (self: Actions<T>, action: T, value: number) -> (),
	moveAxis2d: (self: Actions<T>, action: T, value: Vector2) -> (),
	getInputsByDevices: (self: Actions<T>, action: T, devices: { Device }) -> { Input },
}

export type Device = "Gamepad" | "Mouse" | "Keyboard"

export type Signal = {
	connect: (self: Signal, connection: () -> () | thread) -> () -> (),
}

export type InputState = {
	clear: (self: InputState) -> (),
}

export type Rebind = {
	withDevices: (self: Rebind, devices: { Device }) -> Rebind,
	withoutInputs: (self: Rebind, inputs: { Button }) -> Rebind,
	setRetainInput: (self: Rebind, callback: (input: Button, sunk: boolean) -> boolean) -> Rebind,
	start: (self: Rebind) -> any,
}

--[=[
    @class Spark
]=]

--[=[
    [Enum.UserInputType] must represent a button. Inputs like [Enum.UserInputType.MouseMovement] will not work as a button.

    @type Button Enum.KeyCode | Enum.UserInputType
    @within Spark
]=]

--[=[
    @type Input Enum.KeyCode | Enum.UserInputType | VirtualAxis | VirtualAxis2d
    @within Spark
]=]

--[=[
	@type Modifier (pressed: boolean, axis: number, axis2d: Vector2) -> (boolean, number, Vector2)
	@within Spark
]=]

--[=[
    @type Device "Keyboard" | "Mouse" | "Gamepad"
    @within Spark
]=]

--[=[

	@class Modifiers
]=]

--[=[
    @prop Modifiers Modifiers
    @within Spark
]=]

--[=[
    @prop Actions Actions
    @within Spark
]=]

--[=[
    @prop InputMap InputMap
    @within Spark
]=]

--[=[
    @prop InputState InputState
    @within Spark
]=]

--[=[
    @prop Rebind Rebind
    @within Spark
]=]

--[=[
    @prop Signal Signal
    @within Spark
]=]

--[=[
    @prop VirtualAxis VirtualAxis
    @within Spark
]=]

--[=[
    @prop VirtualAxis2d VirtualAxis2d
    @within Spark
]=]
return {
	Modifiers = {
		scale = require(script.Modifiers.scale),
		deadZone = require(script.Modifiers.deadZone),
	},
	Actions = require(script.Actions) :: {
		new: <T>(actions: { T }) -> Actions<T>,
	},
	Bind = require(script.Binding.Bind) :: {
		new: (...Input) -> Bind,
	},
	InputState = require(script.InputState) :: {
		new: () -> InputState,
	},
	Rebind = require(script.Rebind) :: {
		new: () -> Rebind,
	},
	VirtualAxis = require(script.VirtualAxis) :: {
		new: (options: {
			positive: Button?,
			negative: Button?,
		}) -> VirtualAxis,
		horizontalArrowKeys: () -> VirtualAxis,
		verticalArrowKeys: () -> VirtualAxis,
	},
	VirtualAxis2d = require(script.VirtualAxis2d) :: {
		new: (options: {
			up: Button?,
			down: Button?,
			left: Button?,
			right: Button?,
		}) -> VirtualAxis2d,
		arrowKeys: () -> VirtualAxis2d,
		wasd: () -> VirtualAxis2d,
		dPad: () -> VirtualAxis2d,
	},
	getDeviceFromInput = require(script.getDeviceFromInput) :: (Button) -> Device?,
}
