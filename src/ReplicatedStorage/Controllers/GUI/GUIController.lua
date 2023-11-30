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
}

-- GUI controller
local GUIController = Knit.CreateController({
	Name = "GUIController",
	CurrentGUI = nil,
})

function GUIController:KnitInit()
	self.SFXController = Knit.GetController("SFXController")
end

function GUIController:OpenGUI(name: string, props: {}?, options: Options?): Roact.Tree
	assert(name, "Name is missing or nil.")
	assert(typeof(name) == "string", `Name must be string. Got {typeof(name)}.`)

	if self.CurrentGUI then
		if self.CurrentGUI.name == name then
			if not options or not options.DontCloseIfAlreadyOpen then
				Roact.unmount(self.CurrentGUI.tree)
				self.CurrentGUI = nil
				return
			end
		else
			Roact.unmount(self.CurrentGUI.tree)
			self.CurrentGUI = nil
		end
	end

	if name == "Inventory" or name == "Shop" then
		self.SFXController:PlaySFX("UIOpen")
	end

	local tree = Roact.mount(Roact.createElement(require(apps[name]), props), playerGui, name)

	if not options or not options.DontStoreInHistory then
		self.CurrentGUI = {
			tree = tree,
			name = name,
		}
	end

	return tree
end

function GUIController:GetCurrentGUI(): { name: string, tree: Roact.Tree }?
	return self.CurrentGUI
end

function GUIController:CloseCurrentGUI()
	if self.CurrentGUI then
		self:CloseGUI(self.CurrentGUI)
	end
end

function GUIController:CloseGUI(tree: Roact.Tree)
	assert(tree, "Tree is missing or nil.")

	if self.CurrentGUI.tree == tree then
		self.CurrentGUI = nil
	end

	Roact.unmount(tree)
end

return GUIController
