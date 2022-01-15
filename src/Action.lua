local defaultActionValues = require(script.Parent.defaultActionValues)
local Subject = require(script.Parent.Parent.Subject)

local Action = {}
Action.__index = Action

function Action.new(actionKind)
	return setmetatable({
		_actionKind = actionKind,
		_value = defaultActionValues[actionKind],
		_subject = Subject.new(),
	}, Action)
end

function Action:get()
	return self._value
end

function Action:subscribe(subscriber)
	self._subject:subscribe(subscriber)
end

return Action
