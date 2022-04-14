local enumerate = require(script.Parent.Parent.enumerate)

--[=[
	An enumeration that represents the type of value an input returns.

	@interface ValueKind
	@within Spark
	.Boolean "Boolean"
	.Number "Number"
	.Vector2 "Vector2"
]=]
return enumerate("ValueKind", {
	"Boolean",
	"Number",
	"Vector2",
})
