-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Types
type Options = {
	DontStoreInHistory: boolean,
	DontCloseIfAlreadyOpen: boolean,
	CloseItSelf: boolean,
}

-- Gui service
local GuiService = Knit.CreateService({
	Name = "GuiService",
	Client = {
		OpenGui = Knit.CreateSignal(),
		CloseGui = Knit.CreateSignal(),
	},
})

function GuiService:OpenGui(player: Player, gui: string, props: {}?, options: Options?)
	assert(player ~= nil, "Player is missing or nil.")
	assert(gui ~= nil, "Gui name is missing or nil.")
	self.Client.OpenGui:Fire(player, gui, props, options)
end

function GuiService:CloseGui(player, gui: string)
	assert(player ~= nil, "Player is missing or nil.")
	assert(gui ~= nil, "Gui name is missing or nil.")
	self.Client.CloseGui:Fire(player, gui)
end

return GuiService
