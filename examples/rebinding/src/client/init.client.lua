local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Spark = require(ReplicatedStorage.Packages.Spark)
local UserInterface = require(script.UserInterface)
local Input = require(ReplicatedStorage.Shared.Input)

local InputMap = Spark.InputMap
local Rebind = Spark.Rebind

local serialized = ReplicatedStorage.Remotes.ReplicateInputMap.OnClientEvent:Wait()
local inputMap = InputMap.deserialize(serialized)

local allButtons = {}

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

local function createBinding(bindingIndex, binding, container)
	local bindButton, resetButton = UserInterface.createBind(binding.name, container)

	table.insert(allButtons, bindButton)
	table.insert(allButtons, resetButton)

	local function updateBindText()
		local input = Input.getKeyboardMouseInput(inputMap, binding.action)

		if input == nil or (binding.direction ~= nil and input[binding.direction] == nil) then
			bindButton.Text = ""
		elseif binding.direction == nil then
			bindButton.Text = getInputDisplayName(input)
		elseif input[binding.direction] ~= nil then
			-- If our binding has a direciton, we are expecting a VirtualAxis2d. We need to select the specific input
			-- based on the direction.
			bindButton.Text = getInputDisplayName(input[binding.direction])
		end
	end

	local function isDefault()
		local input = Input.getKeyboardMouseInput(inputMap, binding.action)
		local defaultInput = Input.getKeyboardMouseInput(Input.DEFAULT_INPUT_MAP, binding.action)

		-- The inputs will be a VirtualAxis2d when our binding has a direction. If so, we need to convert to the input
		-- based on the direction.
		if binding.direction then
			input = input[binding.direction]
			defaultInput = defaultInput[binding.direction]
		end

		return input == defaultInput
	end

	updateBindText()
	resetButton.Visible = not isDefault()

	bindButton.Activated:Connect(function()
		toggleAllButtons(false)

		bindButton.Text = "Press any key (DELETE to clear) (BACKSPACE to cancel)"

		-- Rebind when calling the start method returns a Promise that resolves with a button the user presses that
		-- meets the requirements. In this case we only want a Keyboard or Mouse button. We also exclude Escape so
		-- it doesn't conflict with the Roblox Escape menu.
		local newInput =
			Rebind.new():withDevices({ "Keyboard", "Mouse" }):withoutInputs({ Enum.KeyCode.Escape }):start():expect()

		-- If they choose Backspace, we skip the rebinding.
		if newInput ~= Enum.KeyCode.Backspace then
			Input.rebind(inputMap, binding, newInput)
			ReplicatedStorage.Remotes.Rebind:FireServer(bindingIndex, newInput)
		end

		updateBindText()
		resetButton.Visible = not isDefault()

		toggleAllButtons(true)
	end)

	resetButton.Activated:Connect(function()
		local defaultInput = Input.getKeyboardMouseInput(Input.DEFAULT_INPUT_MAP, binding.action)

		if binding.direction then
			defaultInput = defaultInput[binding.direction]
		end

		Input.rebind(inputMap, binding, defaultInput)
		ReplicatedStorage.Remotes.Rebind:FireServer(bindingIndex, defaultInput)

		updateBindText()
		resetButton.Visible = not isDefault()
	end)
end

local container = UserInterface.createRebindingMenu()

for bindingIndex, binding in Input.BINDINGS do
	createBinding(bindingIndex, binding, container)
end
