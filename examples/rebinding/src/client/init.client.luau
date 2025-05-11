local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Spark = require(ReplicatedStorage.Packages.Spark)
local UserInterface = require(script.UserInterface)
local KeyboardBindings = require(ReplicatedStorage.Shared.KeyboardBindings)

local Actions = Spark.Actions
local Rebind = Spark.Rebind

local serializedCustomizedBindings = ReplicatedStorage.Remotes.ReplicateBindings.OnClientEvent:Wait()

local function enumItemFromValue(enum, value)
	for _, enumItem in enum:GetEnumItems() do
		if enumItem.Value == value then
			return enumItem
		end
	end

	error("Invalid enum value")
end

local customizedBindings = {}
for slot, binding in serializedCustomizedBindings do
	-- The server sends a serialized version of the customized bindings. We need to convert them back to EnumItems.
	if binding.kind == "KeyCode" then
		customizedBindings[slot] = enumItemFromValue(Enum.KeyCode, binding.value)
	elseif binding.kind == "UserInputType" then
		customizedBindings[slot] = enumItemFromValue(Enum.UserInputType, binding.value)
	end
end

local actions = Actions.new({ "jump", "move" }):setRebuildBindings(function(bindings)
	bindings:bind("jump", customizedBindings.jump or Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
	bindings:bind(
		"move",
		Spark.VirtualAxis2d.new({
			up = customizedBindings.moveUp or Enum.KeyCode.W,
			down = customizedBindings.moveDown or Enum.KeyCode.S,
			left = customizedBindings.moveLeft or Enum.KeyCode.A,
			right = customizedBindings.moveRight or Enum.KeyCode.D,
		}),
		Enum.KeyCode.Thumbstick1
	)
end)

local allButtons = {}

local function getKeyboardMouseInput(action)
	-- We use getInputsByDevices to return the first input that belongs to either the Keyboard or Mouse.
	return actions:getInputsByDevices(action, { "Keyboard", "Mouse" })[1]
end

-- This returns a name that represents a KeyCode or UserInputType. This can be implemented how you want. You could even use images instead of text.
local function getInputDisplayName(input)
	if input:IsA("UserInputType") then
		return input.Name
	elseif input:IsA("KeyCode") then
		local name = UserInputService:GetStringForKeyCode(input)

		-- Some KeyCodes return an empty string and Enum.KeyCode.Space returns a space character.
		if #name == 0 or name == " " then
			return input.Name
		else
			return name
		end
	else
		error("Invalid input")
	end
end

-- This toggle all buttons so we can disable buttons while the user is rebinding an action.
local function toggleAllButtons(on)
	for _, button in allButtons do
		button.Active = on
		button.AutoButtonColor = on
	end
end

local function createBinding(slot, binding, container)
	local bindButton, resetButton = UserInterface.createBind(binding.name, container)

	table.insert(allButtons, bindButton)
	table.insert(allButtons, resetButton)

	local function updateBindText()
		local input = getKeyboardMouseInput(binding.action)

		if binding.direction == nil then
			bindButton.Text = getInputDisplayName(input)
		else
			-- If our binding has a direciton, we are expecting a VirtualAxis2d. We need to select the specific input
			-- based on the direction.
			bindButton.Text = getInputDisplayName(input[binding.direction])
		end
	end

	local function isDefault()
		local input = getKeyboardMouseInput(binding.action)
		local defaultInput = binding.default

		-- The inputs will be a VirtualAxis2d when our binding has a direction. If so, we need to convert to the input
		-- based on the direction.
		if binding.direction then
			input = input[binding.direction]
		end

		return input == defaultInput
	end

	updateBindText()
	resetButton.Visible = not isDefault()

	bindButton.Activated:Connect(function()
		toggleAllButtons(false)

		bindButton.Text = "Press any key (BACKSPACE to cancel)"

		-- Rebind when calling the start method returns a Promise that resolves with a button the user presses that
		-- meets the requirements. In this case we only want a Keyboard or Mouse button. We also exclude Escape so
		-- it doesn't conflict with the Roblox Escape menu.
		local newInput =
			Rebind.new():withDevices({ "Keyboard", "Mouse" }):withoutInputs({ Enum.KeyCode.Escape }):start():expect()

		-- If they choose Backspace, we skip the rebinding.
		if newInput ~= Enum.KeyCode.Backspace then
			customizedBindings[slot] = newInput
			actions:rebuildBindings() -- Call rebuildBindings to apply the changes to Actions.

			ReplicatedStorage.Remotes.Rebind:FireServer(slot, newInput)
		end

		updateBindText()
		resetButton.Visible = not isDefault()

		toggleAllButtons(true)
	end)

	resetButton.Activated:Connect(function()
		local defaultInput = binding.default

		customizedBindings[slot] = defaultInput
		actions:rebuildBindings() -- Call rebuildBindings to apply the changes to Actions.

		ReplicatedStorage.Remotes.Rebind:FireServer(slot, defaultInput)

		updateBindText()
		resetButton.Visible = not isDefault()
	end)
end

local container = UserInterface.createRebindingMenu()

for slot, binding in KeyboardBindings do
	createBinding(slot, binding, container)
end
