-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

-- Roact
local apps = ReplicatedStorage:WaitForChild("Source").Apps

-- Player
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Types
type Options = {
	DontStoreInHistory: boolean,
	DontCloseIfAlreadyOpen: boolean,
	CloseItSelf: boolean,
}

-- Gui controller
local GuiController = Knit.CreateController({
	Name = "GuiController",
	PlayOpenSoundForTheseGuis = {
		"Inventory",
		"Shop",
		"Settings",
		"Tutorial",
		"Feedback",
	},
})

function GuiController:KnitInit()
	self.PlayerDataController = Knit.GetController("PlayerDataController")
	self.SFXController = Knit.GetController("SFXController")
	self.GuiService = Knit.GetService("GuiService")

	self.GuiService.OpenGui:Connect(function(gui: string, props: {}?, options: Options?)
		self:OpenGui(gui, props, options)
	end)

	self.GuiService.CloseGui:Connect(function(gui: string)
		self:Close(gui)
	end)
end

function GuiController:KnitStart()
	self:OpenGui("Main", nil, { DontStoreInHistory = true, DontCloseIfAlreadyOpen = true })
	self:OpenGui("UpdateLog", { data = require(script.Parent.UpdateLogData) }, { CloseItSelf = true })
end

function GuiController:OpenGui(name: string, props: {}?, options: Options?): Roact.Tree
	assert(name, "Name is missing or nil.")
	assert(typeof(name) == "string", `Name must be string. Got {typeof(name)}.`)

	if self.CurrentGui then
		if self.CurrentGui.name == name then
			if not options or not options.DontCloseIfAlreadyOpen then
				Roact.unmount(self.CurrentGui.tree)
				self.CurrentGui = nil
				return
			end
		else
			Roact.unmount(self.CurrentGui.tree)
			self.CurrentGui = nil
		end
	end

	if table.find(self.PlayOpenSoundForTheseGuis, name) then
		self.SFXController:PlaySFX("UIOpen")
	end

	local tree

	if options and options.CloseItSelf then
		props = props or {}
		props.onClose = function()
			self:CloseGui(tree)
		end
	end

	tree = Roact.mount(Roact.createElement(require(apps[name]), props), playerGui, name)

	if not options or not options.DontStoreInHistory then
		self.CurrentGui = {
			tree = tree,
			name = name,
		}
	end

	return tree
end

function GuiController:GetCurrentGui(): { name: string, tree: Roact.Tree }?
	return self.CurrentGui
end

function GuiController:CloseCurrentGui()
	if self.CurrentGui then
		self:CloseGui(self.CurrentGui)
	end
end

function GuiController:CloseGui(tree: Roact.Tree)
	assert(tree, "Tree is missing or nil.")

	if self.CurrentGui and self.CurrentGui.tree == tree then
		self.CurrentGui = nil
	end

	Roact.unmount(tree)
end

return GuiController
