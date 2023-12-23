-- TODO

if true then
	return
end
local SoundService = game:GetService("SoundService")
local FootSteps = SoundService.SFX.FootSteps
local Humanoid: Humanoid = script.Parent.Parent:WaitForChild("Humanoid")
local CurrentFootStepSound: Sound
Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
	if Humanoid.MoveDirection == Vector3.zero then
		if CurrentFootStepSound then
			CurrentFootStepSound:Stop()
			CurrentFootStepSound = nil
		end
		return
	end
	local FootStepSound = FootSteps:FindFirstChild(Humanoid.FloorMaterial.Name)
	if
		FootStepSound
		and (FootStepSound and FootStepSound.Name) ~= (CurrentFootStepSound and CurrentFootStepSound.Name)
	then
		if CurrentFootStepSound then
			CurrentFootStepSound:Stop()
		end
		FootStepSound.Looped = true
		FootStepSound:Play()

		local pitch = FootStepSound:FindFirstChild("PitchShiftSoundEffect")
		if not pitch then
			pitch = Instance.new("PitchShiftSoundEffect")
			pitch.Parent = FootStepSound
		end
		pitch.Octave = Humanoid.WalkSpeed / 12

		CurrentFootStepSound = FootStepSound
	end
end)
