# Mobile
Spark allows you to activate an action manually. This is especially useful to implement mobile touch controls.

For buttons, you can activate an action with `Actions:press`. Here's how you might implement a mobile button:
```lua
local imageButton = Instance.new("ImageButton")

local hold = nil

imageButton.InputBegan:Connect(function(inputObject)
	if inputObject.UserInputState ~= Enum.UserInputState.Begin then
		-- UserInputState will be Change if the touch was dragged onto the button.
		return
	end

	if hold == nil then
		-- Press the button every frame before input is updated. If held inputs don't matter, you could call press without a loop.
		local connection = RunService.PreRender:Connect(function()
			actions:press("attack")
		end)

		hold = {
			connection = connection,
			inputObject = inputObject,
		}
	end
end)

imageButton.InputEnded:Connect(function(inputObject)
	-- Only stop the hold if it's the same touch that started it.
	if hold ~= nil and hold.inputObject == inputObject then
		hold.connection:Disconnect()
		hold = nil
	end
end)
```

For 1D/2D axis values like movement, camera movement, or camera zoom, use `Actions:moveAxis` and `Actions:moveAxis2d`.
```lua
local thumbstickDirection = Vector2.one -- Get this value from your thumbstick.

-- This will increase the 2D axis value of the move action by thumbstickDirection.
-- It's reset every time `Actions:update` is called, so you need to call it every frame.
actions:moveAxis2d("move", thumbstickDirection)

local cameraZoomDelta = 0 -- Could be a value from a pinch motion

actions:moveAxis("cameraZoom", cameraZoomDelta)
```