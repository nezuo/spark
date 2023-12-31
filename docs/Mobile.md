# Mobile
Spark allows you to activate an action manually. This is especially useful to implement mobile touch controls.

For buttons, you can activate an action with `Actions:hold`. Here's how you might implement a mobile button:
```lua
local imageButton = Instance.new("ImageButton")

local hold = nil

imageButton.InputBegan:Connect(function(inputObject)
	if inputObject.UserInputState ~= Enum.UserInputState.Begin then
		-- UserInputState will be Change if the touch was dragged onto the button.
		return
	end

	-- You can either check if inputObject.UserInputType == Enum.UserInputType.Touch or hide
    -- the button when touch isn't being used.

	if hold == nil then
		hold = {
            -- The hold method acts like a button press. It returns a function to stop the press.
			stopHold = actions:hold("attack"),
			inputObject = inputObject,
		}
	end
end)

imageButton.InputEnded:Connect(function(inputObject)
	-- Only stop the hold if it's the same touch that started it.
	if hold ~= nil and hold.inputObject == inputObject then
		hold.stopHold()
		hold = nil
	end
end)
```

For 2D axis values like movement or camera movement, use `Actions:move`.
```lua
local thumbstickDirection = Vector2.one -- Get this value from your thumbstick.

-- This will increase the 2D axis value of the move action by thumbstickDirection.
-- It's reset every time `Actions:update` is called, so you need to call it every frame.
actions:move("move", thumbstickDirection)
```