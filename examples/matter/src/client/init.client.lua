local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Spark = require(ReplicatedStorage.Packages.Spark)
local exampleSystem = require(script.exampleSystem)
local updateInput = require(script.updateInput)

local InputState = Spark.InputState
local Actions = Spark.Actions
local InputMap = Spark.InputMap
local VirtualAxis2d = Spark.VirtualAxis2d

local state = {
	inputState = InputState.new(),
	actions = Actions.new({ "jump", "attack", "move" }),
	inputMap = InputMap.new()
		:insert("jump", Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
		:insert("attack", Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR1)
		:insert("move", VirtualAxis2d.wasd(), Enum.KeyCode.Thumbstick1),
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
