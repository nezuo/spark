# Spark
Spark is an input-action manager for Roblox.

## Features
- Supports button, 1D, and 2D inputs.
- Create virtual 1D/2D inputs using `VirtualAxis1d`/`VirtualAxis2d`.
- Store all your input mappings in a single `InputMap` object.
- Rebind inputs using APIs like `InputMap:insert` and `InputMap:remove`.

## Example
```lua
local actions = Actions.new({"attack", "move" })

actions:justPressedSignal("attack"):connect(function()
    print("Attacked!")
end)

RunService.Heartbeat:Connect(function()
    print("Moved", actions:clampedAxis2d("move"))
end)
```

To get started, visit the [docs](https://nezuo.github.io/spark).