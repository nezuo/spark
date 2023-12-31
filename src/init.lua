--[=[
    @class Spark
]=]

--[=[
    [Enum.UserInputType] must represent a button. Inputs like [Enum.UserInputType.MouseMovement] will not work as a button.

    @type Button Enum.KeyCode | Enum.UserInputType
    @within Spark
]=]

--[=[
    [Enum.UserInputType] must represent a 2D value. Inputs like [Enum.UserInputType.MouseButton1] will not work as a 2D value.

    @type Input2d Enum.UserInputType | VirtualAxis2d
    @within Spark
]=]

--[=[
    @type Input Enum.KeyCode | Enum.UserInputType | VirtualAxis | VirtualAxis2d | Multiply2d
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
    @prop Multiply2d Multiply2d
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
	Actions = require(script.Actions),
	InputMap = require(script.InputMap),
	InputState = require(script.InputState),
	Multiply2d = require(script.Multiply2d),
	Rebind = require(script.Rebind),
	VirtualAxis = require(script.VirtualAxis),
	VirtualAxis2d = require(script.VirtualAxis2d),
}
