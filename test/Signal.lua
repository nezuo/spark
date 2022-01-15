local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_listeners = {},
	}, Signal)
end

function Signal:Connect(listener)
	table.insert(self._listeners, listener)
end

function Signal:Fire(...)
	for _, listener in ipairs(self._listeners) do
		task.spawn(listener, ...)
	end
end

return Signal
