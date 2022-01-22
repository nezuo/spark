--[=[
	@class Spark
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
	@prop Bindings Bindings
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
	Bindings = require(script.Bindings),
	Rebind = require(script.Rebind),
	ActionKind = require(script.ActionKind),
	ValueKind = require(script.ValueKind),
	Devices = require(script.Devices),
	Composite1d = require(script.Controls.Composite1d),
	Composite2d = require(script.Controls.Composite2d),
}
