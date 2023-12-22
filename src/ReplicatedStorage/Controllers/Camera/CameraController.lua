-- Services
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)
local Promise = require(ReplicatedStorage:WaitForChild("Packages").promise)

-- Camera controller
local CameraController = Knit.CreateController({
	Name = "CameraController",
	CameraStateChanged = Signal.new(),
})

function CameraController:KnitInit()
	self.GuiController = Knit.GetController("GuiController")
end

function CameraController:RotateCameraAround(
	data: { target: Vector3, duration: number, offset: number, speed: number? }
)
	assert(data ~= nil, "Data is missing or nil.")
	assert(data.offset ~= nil, "Offset is missing or nil.")
	assert(data.duration ~= nil, "Duration is missing or nil.")
	assert(data.target ~= nil, "Target is missing or nil.")

	self.GuiController:SetBillboardGuisEnabled(false)
	ProximityPromptService.Enabled = false

	return Promise.new(function(resolve)
		data.speed = data.speed or 15
		local disabled = false
		local rotation = 0
		local timer = workspace:GetServerTimeNow()
		local camera = workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable

		self.CameraStateChanged:Fire("Around")

		local connection = self.CameraStateChanged:Connect(function()
			disabled = true
		end)

		local cFrame
		while (workspace:GetServerTimeNow() - timer) < data.duration and not disabled do
			cFrame = CFrame.new(data.target) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(data.offset)
			cFrame = CFrame.new(cFrame.Position, data.target)
			camera.CFrame = cFrame
			rotation += data.speed * task.wait()
		end

		connection:Disconnect()
		if not disabled then
			self:DefaultCamera()
		end
		resolve()
	end)
end

function CameraController:DefaultCamera()
	self.GuiController:SetBillboardGuisEnabled(true)
	ProximityPromptService.Enabled = true
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	self.CameraStateChanged:Fire("Default")
end

return CameraController
