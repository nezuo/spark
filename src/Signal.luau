--[=[
	@class Signal
]=]
local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		connections = {},
	}, Signal)
end

function Signal:fire(...)
	for _, connection in self.connections do
		task.spawn(connection, ...)
	end
end

--[=[
	@param connection function | thread
	@return () -> () -- A function that when called, disconnects the connection.
]=]
function Signal:connect(connection)
	local function unsubscribe()
		self.connections[unsubscribe] = nil
	end

	self.connections[unsubscribe] = connection

	return unsubscribe
end

return Signal
