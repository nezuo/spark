local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Spark = require(ReplicatedStorage.Packages.Spark)

local Actions = Spark.Actions
local InputMap = Spark.InputMap
local InputState = Spark.InputState
local VirtualAxis2d = Spark.VirtualAxis2d

local inputState = InputState.new()
local actions = Actions.new({ "jump", "attack", "move" })

local inputMap = InputMap.new()
	:insert("jump", Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
	:insert("attack", Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR1)
	:insert("move", VirtualAxis2d.wasd(), Enum.KeyCode.Thumbstick1)

RunService:BindToRenderStep("Spark", Enum.RenderPriority.Input.Value, function()
	actions:update(inputState, inputMap)
	inputState:clear()
end)

actions:justPressedSignal("jump"):connect(function()
	print("Jumped!")
end)

actions:justPressedSignal("attack"):connect(function()
	print("Attacked!")
end)

RunService.Heartbeat:Connect(function()
	local move = actions:clampedAxis2d("move")

	if move.Magnitude > 0 then
		print("Moving", move)
	end
end)
