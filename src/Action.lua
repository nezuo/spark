local defaultActionValues = require(script.Parent.defaultActionValues)
local Subject = require(script.Parent.Parent.Subject)

--[=[
	Actions have a semantic meaning like "Jump" and are designed to be seperate from the controls that update their value.

	@class Action
]=]
local Action = {}
Action.__index = Action

function Action.new(name, actionKind)
	return setmetatable({
		_name = name,
		_actionKind = actionKind,
		_value = defaultActionValues[actionKind],
		_subject = Subject.new(),
	}, Action)
end

--[=[
	Returns the value of the action.

	@return boolean | number | Vector2
]=]
function Action:get()
	return self._value
end

--[=[
	The `subscriber` is notified when the action's value changes.

	```lua
	local unsubscribe = action:subscribe(function(value)
		print("Updated value:", value)
	end)
	```

	@param subscriber (...: any) -> ...any | thread
	@return () -> () -- Unsubscribes the subscriber
]=]
function Action:subscribe(subscriber)
	return self._subject:subscribe(subscriber)
end

return Action
