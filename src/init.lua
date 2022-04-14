--[=[
	@class Spark
]=]

--[=[
	@type Input ButtonInput | Axis1dInput | Axis2dInput | Composite1d | Composite2d
	@within Spark
]=]

--[=[
	@type Device Keyboard | Mouse | Gamepad
	@within Spark
]=]

--[=[
	@within Spark
	@prop InputState InputState
]=]

--[=[
	@within Spark
	@prop Actions Actions
]=]

--[=[
	@within Spark
	@prop InputMap InputMap
]=]

--[=[
	@within Spark
	@prop Rebind Rebind
]=]

--[=[
	@within Spark
	@prop Devices Devices
]=]

--[=[
	@within Spark
	@prop Composite1d Composite1d
]=]

--[=[
	@within Spark
	@prop Composite2d Composite2d
]=]
return {
	InputState = require(script.InputState),
	Actions = require(script.Actions),
	InputMap = require(script.InputMap),
	Rebind = require(script.Rebind),
	ActionKind = require(script.ActionKind),
	ValueKind = require(script.ValueKind),
	Devices = require(script.Devices),
	Composite1d = require(script.Inputs.Composite1d),
	Composite2d = require(script.Inputs.Composite2d),
}
