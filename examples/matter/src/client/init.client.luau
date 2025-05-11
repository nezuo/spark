local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Spark = require(ReplicatedStorage.Packages.Spark)
local exampleSystem = require(script.exampleSystem)
local updateInput = require(script.updateInput)

local InputState = Spark.InputState
local Actions = Spark.Actions
local VirtualAxis2d = Spark.VirtualAxis2d

local actions = Actions.new({ "jump", "attack", "move" })
actions:setRebuildBindings(function(bindings)
	bindings:bind("jump", Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
	bindings:bind("attack", Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR1)
	bindings:bind("move", VirtualAxis2d.wasd(), Enum.KeyCode.Thumbstick1)
end)

local state = {
	inputState = InputState.new(),
	actions = actions,
}

local world = Matter.World.new()
local loop = Matter.Loop.new(world, state)

-- Here we add two helper methods to the Actions object.
function Actions:justPressed(action: string): boolean
	local signal = self:justPressedSignal(action)
	local iterator = Matter.useEvent(action, signal)

	return iterator() ~= nil
end

function Actions:justReleased(action: string): boolean
	local signal = self:justReleasedSignal(action)
	local iterator = Matter.useEvent(action, signal)

	return iterator() ~= nil
end

loop:scheduleSystems({ exampleSystem, updateInput })
loop:begin({
	default = RunService.Heartbeat,
	RenderStepped = RunService.RenderStepped,
})
