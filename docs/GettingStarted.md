# Getting Started

```lua
-- First we create the InputState object. This should only be created once.
local inputState = InputState.new()

-- Next, we create our Actions object.
-- The casting is optional but will provide autocomplete/typechecking for the action names.
local actions = (Actions.new({ "jump", "attack", "move" }) :: any) :: Spark.Actions<"jump" | "attack" | "move">

-- Next, we set the callback to setup up the bindings for each action.
-- This will be called once here and anytime actions:rebuildBindings() is called.
actions:setRebuildBindings(function(bindings)
    bindings:bind("jump", Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
    bindings:bind("attack", Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR1)
    bindings:bind("move", VirtualAxis2d.wasd(), Enum.KeyCode.Thumbstick1)
end)

-- You need to update your Actions objects each frame before any code that reads from it.
RunService:BindToRenderStep("Spark", Enum.RenderPriority.Input.Value, function()
    -- First we update our Actions object with the InputState.
    actions:update(inputState)

    -- InputState:clear needs to be called after updating all Actions objects.
    -- It resets the values of the mouse wheel and mouse movement so they don't persist across frames.
    inputState:clear()
end)
```
