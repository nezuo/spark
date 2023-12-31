local function exampleSystem(_, state)
	local actions = state.actions

	-- Here we use the helper methods we added: justPressed and justReleased.
	if actions:justPressed("jump") then
		print("Jumped!")
	end

	if actions:justReleased("attack") then
		print("Attack released!")
	end

	local move = actions:clampedAxis2d("move")

	if move.Magnitude > 0 then
		print("Moving", move)
	end
end

return exampleSystem
