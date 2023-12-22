-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Roact
local apps = ReplicatedStorage:WaitForChild("Source").Apps

-- Player
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Components
local SellHint = require(ReplicatedStorage:WaitForChild("Source").Components.SellHint)

-- Types
type Options = {
	DontStoreInHistory: boolean,
	DontCloseIfAlreadyOpen: boolean,
	CloseItSelf: boolean,
	OpenIfHidden: boolean,
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
		"Prompt",
	},
	GuiHidden = false,
	GuiOpen = Signal.new(),
	GuiClose = Signal.new(),
})

function GuiController:KnitInit()
	self.PlayerDataController = Knit.GetController("PlayerDataController")
	self.SettingsController = Knit.GetController("SettingsController")
	self.SFXController = Knit.GetController("SFXController")
	self.GuiService = Knit.GetService("GuiService")

	self.BillboardGuisEnabled, self.setBillboardGuisEnabled = Roact.createBinding(true)

	self.GuiService.OpenGui:Connect(function(gui: string, props: {}?, options: Options?)
		self:OpenGui(gui, props, options)
	end)

	self.GuiService.CloseGui:Connect(function(gui: string)
		self:Close(gui)
	end)
end

function GuiController:KnitStart()
	self:OpenGui("Main", nil, { DontStoreInHistory = true, DontCloseIfAlreadyOpen = true })
	if self.SettingsController:GetSetting("OpenUpdateLogOnStart") then
		self:OpenGui("UpdateLog", { data = require(script.Parent.UpdateLogData) }, { CloseItSelf = true })
	end

	local billboards = Instance.new("Folder")
	billboards.Name = "BillboardGuis"
	billboards.Parent = playerGui

	for _, v in ipairs(workspace.SellParts:GetChildren()) do
		Roact.mount(
			Roact.createElement(SellHint, { adornee = v, enabled = self.BillboardGuisEnabled }),
			billboards,
			"SellHint"
		)
	end

	workspace.SellParts.ChildAdded:Connect(function(v)
		Roact.mount(
			Roact.createElement(SellHint, { adornee = v, enabled = self.BillboardGuisEnabled }),
			billboards,
			"SellHint"
		)
	end)
end

function GuiController:SetBillboardGuisEnabled(enabled: boolean)
	assert(enabled ~= nil, "Enabled is missing or nil.")
	if self.BillboardGuisEnabled:getValue() ~= enabled then
		self.setBillboardGuisEnabled(enabled)
	end
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
		props.closeGui = function()
			if props.onClose then
				coroutine.wrap(props.onClose)()
			end
			self:CloseGui(tree)
		end
	end

	tree = Roact.mount(Roact.createElement(require(apps[name]), props), playerGui, name)
	self.GuiOpen:Fire(name, props, options)

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

	self.GuiClose:Fire(tree)
	Roact.unmount(tree)
end

function GuiController:HideAllGui(blackList: {}?): ()
	blackList = blackList or {}
	self.GuiHidden = true

	local changedGui = {}

	local connection: RBXScriptConnection = self.GuiOpen:Connect(function(name: string, _, options: Options?)
		if not options or not options.OpenIfHidden then
			playerGui:FindFirstChild(name).Enabled = false
			table.insert(changedGui, playerGui:FindFirstChild(name))
		end
	end)

	for _, v in ipairs(playerGui:GetChildren()) do
		if v.ClassName == "ScreenGui" and not table.find(blackList, v.Name) then
			v.Enabled = false
			table.insert(changedGui, v)
		end
	end

	return function()
		connection:Disconnect()
		self.GuiHidden = false
		for _, v in ipairs(changedGui) do
			v.Enabled = true
		end
	end
end

return GuiController
