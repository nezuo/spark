local enumerate = require(script.Parent.Parent.enumerate)

--[=[
	An enumeration that represents what type of value an Action returns.

	@interface ActionKind
	@within Spark
	.Axis1d "Axis1d" -- Action returns a number.
	.Axis2d "Axis2d" -- Action returns a Vector2.
	.Button "Button" -- Action returns a boolean.
]=]
return enumerate("ActionKind", {
	"Axis1d",
	"Axis2d",
	"Button",
})
