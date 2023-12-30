# Getting Started

```lua
-- First we create the InputState object. This should only be created once.
local inputState = InputState.new()

-- Next, we create our Actions object.
local actions = Actions.new({ "jump", "attack", "move" })

-- Next, we create our InputMap. This stores our mappings from inputs to actions.
-- This object can be used for rebinding.
local inputMap = InputMap.new()
    :insert("jump", Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
    :insert("attack", Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR1)
    :insert("move", VirtualAxis2d.wasd(), Enum.KeyCode.Thumbstick1)

-- You need to update your Actions objects each frame before any code that reads action values.
RunService:BindToRenderStep("Spark", Enum.RenderPriority.Input.Value, function()
    -- First we update our Actions object given the InputState and the associated InputMap.
    actions:update(inputState, inputMap)

    -- InputState:clear needs to be called after updating all Actions objects.
    -- It resets the values of the mouse wheel and mouse movement so they don't persist across frames.
    inputState:clear()
end)
```
