local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KeyboardBindings = require(ReplicatedStorage.Shared.KeyboardBindings)

local allCustomizedBindings = {}

local function onPlayerAdded(player)
	-- Here you would load the player's custom bindings using DataStores. For the sake of the example, it uses the default bindings.
	local customizedBindings = {}

	allCustomizedBindings[player] = customizedBindings

	ReplicatedStorage.Remotes.ReplicateBindings:FireClient(player, customizedBindings)
end

local function onPlayerRemoving(player)
	allCustomizedBindings[player] = nil
end

local function onRebind(player, slot, input)
	local binding = KeyboardBindings[slot]

	if
		binding == nil
		or typeof(input) ~= "EnumItem"
		or (not input:IsA("KeyCode") and not input:IsA("UserInputType"))
	then
		-- Don't continue because the player sent invalid arguments.
		return
	end

	local customizedBindings = allCustomizedBindings[player]

	-- EnumItems can't be saved in DataStores, so we convert them to their value.
	if input:IsA("KeyCode") then
		customizedBindings[slot] = { kind = "KeyCode", value = input.Value }
	elseif input:IsA("UserInputType") then
		customizedBindings[slot] = { kind = "UserInputType", value = input.Value }
	end

	-- Here you can save the bindings to a DataStore.
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
ReplicatedStorage.Remotes.Rebind.OnServerEvent:Connect(onRebind)

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end
