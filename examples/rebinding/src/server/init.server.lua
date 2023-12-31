local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Input = require(ReplicatedStorage.Shared.Input)

local inputMaps = {}

local function onPlayerAdded(player)
	-- Here you would load the player's InputMap using DataStores. For the sake of the example, it just uses the default InputMap.
	local inputMap = Input.DEFAULT_INPUT_MAP:clone()

	inputMaps[player] = inputMap

	-- To send the InputMap to the player, we need to serialize it as a buffer so it can be sent over a RemoteEvent.
	local serialized = inputMap:serialize()

	ReplicatedStorage.Remotes.ReplicateInputMap:FireClient(player, serialized)
end

local function onPlayerRemoving(player)
	inputMaps[player] = nil
end

local function onRebind(player, bindingIndex, input)
	local binding = Input.BINDINGS[bindingIndex]

	if
		binding == nil
		or typeof(input) ~= "EnumItem"
		or (not input:IsA("KeyCode") and not input:IsA("UserInputType"))
	then
		-- Don't continue because the player sent invalid arguments.
		return
	end

	local inputMap = inputMaps[player]

	Input.rebind(inputMap, binding, input)

	-- Here you could serialize the InputMap and save it.
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
ReplicatedStorage.Remotes.Rebind.OnServerEvent:Connect(onRebind)

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end
