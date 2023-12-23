-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local ContextActionService = game:GetService("ContextActionService")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Player
local localPlayer = Players.LocalPlayer

-- Character controller
local CharacterController = Knit.CreateController({
	Name = "CharacterController",
	Frozen = false,
	WalkSpeed = StarterPlayer.CharacterWalkSpeed,
	JumpPower = StarterPlayer.CharacterJumpPower,
})

function CharacterController:KnitInit()
	self.MonetizationController = Knit.GetController("MonetizationController")
	self.PlayerDataController = Knit.GetController("PlayerDataController")
	self.PlayerEquipmentController = Knit.GetController("PlayerEquipmentController")
	self.SettingsController = Knit.GetController("SettingsController")

	self.WalkSpeedPassEnabled = self.SettingsController:GetSetting("WalkSpeedPassEnabled")

	self.SettingsController.SettingChanged:Connect(function(setting, value)
		if setting == "WalkSpeedPassEnabled" then
			self.WalkSpeedPassEnabled = value
		end
	end)

	self.MonetizationController
		:DoOwnGamepass(175593072)
		:andThen(function(value)
			self.OwnsGamepass = value
		end)
		:catch(warn)

	localPlayer.CharacterAdded:Connect(function()
		self.MonetizationController:DoOwnGamepass(175593072):andThen(function(value)
			if value then
				task.defer(function()
					local torso: BasePart = self:GetTorso()

					local attachment0 = Instance.new("Attachment")
					attachment0.CFrame = CFrame.new(0, -torso.Size.Y / 2, 0)
					attachment0.Parent = torso

					local attachment1 = Instance.new("Attachment")
					attachment1.CFrame = CFrame.new(0, torso.Size.Y / 2, 0)
					attachment1.Parent = torso

					local trail = Instance.new("Trail")
					trail.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.5),
						NumberSequenceKeypoint.new(1, 1),
					})
					trail.WidthScale = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 0),
					})
					trail.FaceCamera = true
					trail.Lifetime = 1
					trail.LightEmission = 0.5
					trail.LightInfluence = true
					trail.Attachment0 = attachment0
					trail.Attachment1 = attachment1
					trail.Enabled = false
					trail.Parent = torso
				end)
			end
		end)
	end)
end

function CharacterController:KnitStart()
	local function ShiftToRun(name, state)
		if name ~= "ShiftToRun" then
			return
		end

		local humanoid = self:GetHumanoid()
		local trail = self:GetTrail()

		if self.Frozen then
			if trail then
				trail.Enabled = false
			end
			return
		end

		local bootsData = self.PlayerEquipmentController:GetBootsData(self.PlayerEquipmentController:GetEquippedBoots())

		if state == Enum.UserInputState.Begin then
			humanoid.WalkSpeed = self.WalkSpeed
				* 2
				* ((self.OwnsGamepass and self.WalkSpeedPassEnabled) and 1.5 or 1)
				* (bootsData and bootsData.WalkSpeed or 1)
			if trail and self.WalkSpeedPassEnabled then
				trail.Enabled = true
			end
		else
			humanoid.WalkSpeed = self.WalkSpeed * (bootsData and bootsData.WalkSpeed or 1)
			if trail then
				trail.Enabled = false
			end
		end
	end

	ContextActionService:BindAction("ShiftToRun", ShiftToRun, true, Enum.KeyCode.LeftShift)
	ContextActionService:SetTitle("ShiftToRun", "Run")
	ContextActionService:SetPosition("ShiftToRun", UDim2.new(1, -50, 1, -150))
end

function CharacterController:GetTrail(): Trail?
	return self:GetTorso():FindFirstChild("Trail")
end

function CharacterController:GetTorso(): BasePart
	local character = self:GetCharacter()
	if not character:FindFirstChild("Torso") and not character:FindFirstChild("UpperTorso") then
		task.wait(1)
		return self:GetTorso()
	end
	return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

function CharacterController:GetCharacter(): Model
	if not localPlayer.Character then
		localPlayer.CharacterAdded:Wait()
	end

	return localPlayer.Character
end

function CharacterController:GetHumanoid(): Humanoid
	local character = self:GetCharacter()
	return character:WaitForChild("Humanoid")
end

function CharacterController:Freeze()
	if self.Frozen then
		return
	end

	self.Frozen = true

	local character = localPlayer.Character

	if not character then
		localPlayer.CharacterAdded:Wait()
		task.defer(function()
			character = localPlayer.Character
		end)
	end

	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
end

function CharacterController:Unfreeze()
	if not self.Frozen then
		return
	end

	local character = localPlayer.Character

	if not character then
		localPlayer.CharacterAdded:Wait()
		task.defer(function()
			character = localPlayer.Character
		end)
	end

	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = self.WalkSpeed
	humanoid.JumpPower = self.JumpPower

	self.Frozen = false
end

function CharacterController:SetWalkSpeed(walkSpeed: number)
	self.WalkSpeed = walkSpeed
end

function CharacterController:SetJumpPower(jumpPower: number)
	self.JumpPower = jumpPower
end

return CharacterController
