local Players = game:GetService("Players")

local UserInterface = {}

function UserInterface.createRebindingMenu()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = Players.LocalPlayer.PlayerGui

	local background = Instance.new("Frame")
	background.AnchorPoint = Vector2.new(0.5, 0.5)
	background.Position = UDim2.fromScale(0.5, 0.5)
	background.Size = UDim2.fromOffset(600, 300)
	background.BorderSizePixel = 0
	background.BackgroundColor3 = Color3.fromRGB(61, 61, 61)
	background.Parent = screenGui

	local container = Instance.new("Frame")
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.5)
	container.Size = UDim2.new(1, -15, 1, -15)
	container.BackgroundTransparency = 1
	container.Parent = background

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = container

	return container
end

function UserInterface.createBind(name, container)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 20)
	frame.BackgroundTransparency = 1
	frame.Parent = container

	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.new(0, 5, 0.5, 0)
	label.Size = UDim2.fromScale(0.5, 0.8)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = name
	label.Parent = frame

	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -80, 0.5, 0)
	button.Size = UDim2.new(0.7, -80, 0.8, 0)
	button.Parent = frame

	local resetButton = Instance.new("TextButton")
	resetButton.AnchorPoint = Vector2.new(1, 0.5)
	resetButton.Position = UDim2.fromScale(1, 0.5)
	resetButton.Size = UDim2.fromScale(0.125, 0.8)
	resetButton.Text = "Reset"
	resetButton.Visible = false
	resetButton.Parent = frame

	return button, resetButton
end

return UserInterface
