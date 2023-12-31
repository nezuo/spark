local function updateInput(_, state)
	state.actions:update(state.inputState, state.inputMap)
	state.inputState:clear()
end

return {
	system = updateInput,
	event = "RenderStepped",
	priority = -math.huge, -- You want to update input before all other systems run.
}
