local InputKinds = require(script.Parent.InputKinds)

local Serializer = {}
Serializer.__index = Serializer

function Serializer.new(buffer)
	return setmetatable({
		buffer = buffer,
		cursor = 0,
	}, Serializer)
end

function Serializer:writeU8(number)
	buffer.writeu8(self.buffer, self.cursor, number)
	self.cursor += 1
end

function Serializer:writeU16(number)
	buffer.writeu16(self.buffer, self.cursor, number)
	self.cursor += 2
end

function Serializer:writeF64(number)
	buffer.writef64(self.buffer, self.cursor, number)
	self.cursor += 8
end

function Serializer:writeString(value)
	buffer.writestring(self.buffer, self.cursor, value)
	self.cursor += #value
end

function Serializer:writeActionHeader(action, inputCount)
	if #action > 255 then
		error("Action names must 255 characters or less")
	end

	self:writeU8(#action)
	self:writeString(action)

	if inputCount > 255 then
		error("Actions must have less than 255 inputs")
	end

	self:writeU8(inputCount)
end

function Serializer:writeInputKind(kind)
	self:writeU8(InputKinds[kind])
end

function Serializer:writeEnumInput(input)
	if input == nil then
		self:writeInputKind("None")
		return
	end

	if input:IsA("KeyCode") then
		self:writeInputKind("KeyCode")
	else
		self:writeInputKind("UserInputType")
	end

	self:writeU16(input.Value)
end

function Serializer:writeMultiply2d(multiply2d)
	self:writeInputKind("Multiply2d")
	self:writeEnumInput(multiply2d.input)
	self:writeF64(multiply2d.multiplier.X)
	self:writeF64(multiply2d.multiplier.Y)
end

function Serializer:writeVirtualAxis(virtualAxis)
	self:writeInputKind("VirtualAxis")
	self:writeEnumInput(virtualAxis.positive)
	self:writeEnumInput(virtualAxis.negative)
end

function Serializer:writeVirtualAxis2d(virtualAxis2d)
	self:writeInputKind("VirtualAxis2d")
	self:writeEnumInput(virtualAxis2d.up)
	self:writeEnumInput(virtualAxis2d.down)
	self:writeEnumInput(virtualAxis2d.left)
	self:writeEnumInput(virtualAxis2d.right)
end

return Serializer
