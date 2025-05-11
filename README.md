# Spark
Spark is an input-action manager for Roblox.

## Features
- Supports button, 1D, and 2D inputs.
- Create virtual 1D/2D inputs using `VirtualAxis1d`/`VirtualAxis2d`.
- Rebind inputs using `Bindings`.

## Example
```lua
local actions = Actions.new({ "attack", "move" }):setRebuildBindings(function(bindings)
    bindings:bind("attack", Enum.UserInputType.MouseButton1)
    bindings:bind("move", VirtualAxis2d.wasd())
end)

actions:justPressedSignal("attack"):connect(function()
    print("Attacked!")
end)

RunService.Heartbeat:Connect(function()
    print("Moved", actions:clampedAxis2d("move"))
end)
```

To get started, visit the [docs](https://nezuo.github.io/spark).