# Spark Changelog

## Unreleased Changes

## 0.3.0 - May 10, 2025
This release contains breaking changes and an overhauled API.
Spark no longer handles the serialization of customized inputs, this has to be done user side.
In return, features like modifiers were made possible.

See the docs and examples for the updated API.

Changes:
* `Actions`
    * Added `Actions:setAssociatedGamepad`
    * Added `Actions:removeAssociatedGamepad`
    * Added `Actions:setRebuildBindings`
    * Added `Actions:rebuildBindings`
    * Added `Actions:getInputsByDevices`
    * Added `Actions:moveAxis`
    * Renamed `Actions:value` to `Actions:axis`
    * Renamed `Actions:move` to `Actions:moveAxis2d`
    * `Actions:update` now only takes `InputState`
* Added `Rebind:setRetainInput`
* Added modifiers via `Bind:addModifiers` and `ActionConfig:addModifiers`
    * `deadZone` and `scale` modifiers
* Added `getDeviceFromInput`
* Removed `InputMap`
  * `associatedGamepad` is replaced by `Actions:setAssociatedGamepad` and `Actions:removeAssociatedGamepad`
  * `getByDevices` is replaced by `Actions:getInputsByDevices`
  * Binding is now done via `Actions:setRebuildBindings`
* Removed `Multiply2d`
  * Replaced by the new `scale` modifier

## 0.2.2 - December 2, 2024
* `gameProcessedEvent` is no longer respected in `InputEnded` and `InputChanged`.

## 0.2.1 - December 31, 2023
* Fix action values (pressed, value, axis2d, etc) not updating before justPressedSignal and justReleasedSignal are fired. ([#15])

[#15]: https://github.com/nezuo/spark/pull/15
