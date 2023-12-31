local InputKinds = require(script.Parent.InputKinds)
local Multiply2d = require(script.Parent.Parent.Multiply2d)
local VirtualAxis = require(script.Parent.Parent.VirtualAxis)
local VirtualAxis2d = require(script.Parent.Parent.VirtualAxis2d)

local function enumItemFromValue(enum, value)
	for _, enumItem in enum:GetEnumItems() do
		if enumItem.Value == value then
			return enumItem
		end
	end

	error("Invalid enum value")
end

local Deserializer = {}
Deserializer.__index = Deserializer

function Deserializer.new(serialized)
	return setmetatable({
		buffer = serialized,
		length = buffer.len(serialized),
		cursor = 0,
	}, Deserializer)
end

function Deserializer:empty()
	return self.cursor >= self.length
end

function Deserializer:readU8()
	local number = buffer.readu8(self.buffer, self.cursor)
	self.cursor += 1

	return number
end

function Deserializer:readU16()
	local number = buffer.readu16(self.buffer, self.cursor)
	self.cursor += 2

	return number
end

function Deserializer:readF64()
	local number = buffer.readf64(self.buffer, self.cursor)
	self.cursor += 8

	return number
end

function Deserializer:readString(length)
	local value = buffer.readstring(self.buffer, self.cursor, length)
	self.cursor += length

	return value
end

function Deserializer:readActionHeader()
	local length = self:readU8()
	local name = self:readString(length)
	local inputCount = self:readU8()

	return name, inputCount
end

function Deserializer:readEnumInputFromKind(kind)
	local value = self:readU16()

	if kind == InputKinds.KeyCode then
		return enumItemFromValue(Enum.KeyCode, value)
	else
		return enumItemFromValue(Enum.UserInputType, value)
	end
end

function Deserializer:readEnumInput()
	local kind = self:readU8()

	if kind == InputKinds.None then
		return nil
	end

	return self:readEnumInputFromKind(kind)
end

function Deserializer:readMultiply2d()
	local input = self:readEnumInput()
	local sensitivityX = self:readF64()
	local sensitivityY = self:readF64()

	return Multiply2d.new(input, Vector2.new(sensitivityX, sensitivityY))
end

function Deserializer:readVirtualAxis()
	local positive = self:readEnumInput()
	local negative = self:readEnumInput()

	return VirtualAxis.new({ positive = positive, negative = negative })
end

function Deserializer:readVirtualAxis2d()
	local up = self:readEnumInput()
	local down = self:readEnumInput()
	local left = self:readEnumInput()
	local right = self:readEnumInput()

	return VirtualAxis2d.new({ up = up, down = down, left = left, right = right })
end

function Deserializer:readInput()
	local kind = self:readU8()

	if kind == InputKinds.KeyCode or kind == InputKinds.UserInputType then
		return self:readEnumInputFromKind(kind)
	elseif kind == InputKinds.Multiply2d then
		return self:readMultiply2d()
	elseif kind == InputKinds.VirtualAxis then
		return self:readVirtualAxis()
	elseif kind == InputKinds.VirtualAxis2d then
		return self:readVirtualAxis2d()
	end

	error(`Invalid input kind {kind}`)
end

return Deserializer
