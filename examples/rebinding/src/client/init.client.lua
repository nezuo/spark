local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Spark = require(ReplicatedStorage.Packages.Spark)
local UserInterface = require(script.UserInterface)

local InputMap = Spark.InputMap
local Rebind = Spark.Rebind
local VirtualAxis2d = Spark.VirtualAxis2d

local BINDINGS = {
	{ name = "Jump", action = "jump" },
	{ name = "Move Up", action = "move", direction = "up" },
	{ name = "Move Down", action = "move", direction = "down" },
	{ name = "Move Left", action = "move", direction = "left" },
	{ name = "Move Right", action = "move", direction = "right" },
}

-- We keep around an InputMap with the default bindings so we can support a reset to default button.
local DEFAULT_INPUT_MAP =
	InputMap.new():insert("move", VirtualAxis2d.wasd()):insert("jump", Enum.KeyCode.ButtonA, Enum.KeyCode.Space)

-- We clone the default InputMap for the one that will be changed.
local inputMap = DEFAULT_INPUT_MAP:clone()

local buttons = {}

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
local function toggleButtons(on)
	for _, button in buttons do
		button.Active = on
		button.AutoButtonColor = on
	end
end

local function createBinding(binding, container)
	local bindButton, resetButton = UserInterface.createBind(binding.name, container)
	local action = binding.action

	table.insert(buttons, bindButton)
	table.insert(buttons, resetButton)

	local function getKeyboardMouseInput()
		-- We use getByDevices to return the first input that belongs to either the Keyboard or Mouse.
		return inputMap:getByDevices(action, { "Keyboard", "Mouse" })[1]
	end

	local function updateBindText()
		local input = getKeyboardMouseInput()

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
		local input = getKeyboardMouseInput()
		local defaultInput = DEFAULT_INPUT_MAP:getByDevices(action, { "Keyboard", "Mouse" })[1]

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

	local function rebind(newInput)
		local oldInput = getKeyboardMouseInput()
		if oldInput ~= nil then
			if binding.direction == nil then
				inputMap:remove(action, oldInput)
			else
				-- Binding has a direction so we remove the specific direction from the VirtualAxis2d.
				oldInput[binding.direction] = nil
			end
		end

		-- If they chose Delete, we don't want to insert a new input.
		if newInput ~= Enum.KeyCode.Delete then
			if binding.direction == nil then
				inputMap:insert(action, newInput)
			else
				-- Binding has a direction so we set the specific direction of the VirtualAxis2d to the new input .
				oldInput[binding.direction] = newInput
			end
		end
	end

	bindButton.Activated:Connect(function()
		toggleButtons(false)

		bindButton.Text = "Press any key (DELETE to clear) (BACKSPACE to cancel)"

		-- Rebind when calling the start method returns a Promise that resolves with a button the user presses that
		-- meets the requirements. In this case we only want a Keyboard or Mouse button. We also exclude Escape so
		-- it doesn't conflict with the Roblox Escape menu.
		local newInput =
			Rebind.new():withDevices({ "Keyboard", "Mouse" }):withoutInputs({ Enum.KeyCode.Escape }):start():expect()

		-- If they choose Backspace, we skip the rebinding.
		if newInput ~= Enum.KeyCode.Backspace then
			rebind(newInput)
		end

		updateBindText()
		resetButton.Visible = not isDefault()

		toggleButtons(true)
	end)

	resetButton.Activated:Connect(function()
		local defaultInput = DEFAULT_INPUT_MAP:getByDevices(action, { "Keyboard", "Mouse" })[1]

		if binding.direction then
			defaultInput = defaultInput[binding.direction]
		end

		rebind(defaultInput)
		updateBindText()
		resetButton.Visible = not isDefault()
	end)
end

local container = UserInterface.createRebindingMenu()

for _, binding in BINDINGS do
	createBinding(binding, container)
end
