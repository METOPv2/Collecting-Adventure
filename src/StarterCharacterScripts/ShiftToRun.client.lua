-- Services
local ContextActionService = game:GetService("ContextActionService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Character
local character: Model = script.Parent.Parent
local humanoid: Humanoid = character:WaitForChild("Humanoid")

-- Shift to run function
local function ShiftToRun(name, state)
	-- Checks
	if name ~= "ShiftToRun" then
		return
	end

	-- Change character's walk speed
	if state == Enum.UserInputState.Begin then
		humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed * 2
	else
		humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
	end
end

-- Bind action
ContextActionService:BindAction("ShiftToRun", ShiftToRun, true, Enum.KeyCode.LeftShift)
ContextActionService:SetTitle("ShiftToRun", "Run")
ContextActionService:SetPosition("ShiftToRun", UDim2.new(1, -50, 1, -150))
