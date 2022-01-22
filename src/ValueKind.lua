local enumerate = require(script.Parent.Parent.enumerate)

--[=[
	An enumeration that represents the type of value a Control returns.

	@interface ValueKind
	@within Spark
	.Boolean "Boolean" -- Control returns a boolean.
	.Number "Number" -- Control returns a number.
	.Vector2 "Vector2" -- Control returns a Vector2.
]=]
return enumerate("ValueKind", {
	"Boolean",
	"Number",
	"Vector2",
})
