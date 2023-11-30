-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- SFX service
local SFXService = Knit.CreateService({
	Name = "SFXService",
	Client = {
		PlaySFX = Knit.CreateSignal(),
	},
})

function SFXService:PlayLocalSFX(player: Player, sfx: string)
	assert(player ~= nil, "Player is missing or nil.")
	assert(sfx ~= nil, "Sfx is missing or inl.")

	self.Client.PlaySFX:Fire(player, sfx)
end

return SFXService
