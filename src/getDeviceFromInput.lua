local function getDeviceFromInput(input)
	if typeof(input) ~= "EnumItem" then
		return nil
	end

	if input:IsA("UserInputType") then
		if string.match(input.Name, "^Gamepad") ~= nil then
			return "Gamepad"
		elseif string.match(input.Name, "^Mouse") ~= nil then
			return "Mouse"
		elseif input == Enum.UserInputType.Keyboard then
			return "Keyboard"
		else
			return nil
		end
	elseif input:IsA("KeyCode") then
		if input == Enum.KeyCode.Unknown then
			return nil
		elseif input.Value >= 1000 then -- This works now but could break if they add new KeyCodes.
			return "Gamepad"
		else
			return "Keyboard"
		end
	end

	return nil
end

return getDeviceFromInput
