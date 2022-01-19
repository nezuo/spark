--[=[
	@class Devices
]=]

--[=[
	@within Devices
	@prop Keyboard Keyboard
]=]

--[=[
	@within Devices
	@prop Mouse Mouse
]=]

--[=[
	@within Devices
	@prop Gamepad Gamepad
]=]
return {
	Keyboard = require(script.Keyboard),
	Mouse = require(script.Mouse),
	Gamepad = require(script.Gamepad),
}
