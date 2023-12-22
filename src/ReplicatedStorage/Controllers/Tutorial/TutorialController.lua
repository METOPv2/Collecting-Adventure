-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

-- Player
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Tutorial controller
local TutorialController = Knit.CreateController({
	Name = "TutorialController",
	OnGoing = false,
})

function TutorialController:KnitInit()
	self.GuiController = Knit.GetController("GuiController")
	self.PromptController = Knit.GetController("PromptController")
	self.MarkerController = Knit.GetController("MarkerController")
	self.FruitsController = Knit.GetController("FruitsController")
	self.PlayerEquipmentController = Knit.GetController("PlayerEquipmentController")
	self.NotificationsController = Knit.GetController("NotificationsController")
	self.PlayerDataController = Knit.GetController("PlayerDataController")
	self.CameraController = Knit.GetController("CameraController")
	self.SFXController = Knit.GetController("SFXController")
end

function TutorialController:KnitStart()
	if not self.PlayerDataController:GetAsync("TutorialCompleted") then
		self:StartTutorial()
		self.PlayerDataController:SetAsync("TutorialCompleted", true)
	end
end

function TutorialController:StartTutorial()
	if self.OnGoing then
		return
	end

	self.OnGoing = true

	self.PromptController
		:Prompt({
			text = "Would you like to learn the basics of the game?",
			title = "Tutorial",
			button1 = "Yes",
			button2 = "No",
			key = "Tutorial",
		})
		:andThen(function(result)
			if result ~= "Yes" then
				self.OnGoing = false
				return
			end

			local enableAllGui = self.GuiController:HideAllGui({ "Prompt" })

			local function onCancel(printCancelMessage: boolean)
				self.OnGoing = false
				enableAllGui()
				Roact.unmount(self.TutorialTree)
				self.TutorialTree = nil

				self.MarkerController:CancelAll({
					"TutorialStage1",
					"TutorialStage2",
					"TutorialStage3",
				})

				if printCancelMessage then
					self.NotificationsController:new({
						text = "You canceled the tutorial.",
						title = "Tutorial canceled",
						duration = 15,
					})
				end
			end

			self.MarkerController:CancelAll()

			local text, setText = Roact.createBinding("")

			if not playerGui:FindFirstChild("Tutorial") then
				self.TutorialTree = self.GuiController:OpenGui(
					"Tutorial",
					{ text = text, onCancel = onCancel },
					{ OpenIfHidden = true, DontStoreInHistory = true }
				)
			end

			if self.PlayerEquipmentController:GetEquippedBag() == "" then
				setText(
					"Before we start, check if you've equipped your bag. To equip the bag, simply click on it, and it will be highlighted."
				)
				self.GuiController:OpenGui(
					"Inventory",
					{ starterPage = "Bags" },
					{ OpenIfHidden = true, DontCloseIfAlreadyOpen = true, CloseItSelf = true }
				)
				self.PlayerEquipmentController.BagEquipped:Wait()
				self.SFXController:PlaySFX("Switch")
			end

			setText("Let's go to the first fruit. Look around and approach the marker.")

			self.MarkerController
				:New(workspace:WaitForChild("Trees").Apple, { Key = "TutorialStage1", Distance = 15 }, { "Model" })
				:catch(warn)
				:await()

			self.SFXController:PlaySFX("Switch")
			setText("Now trigger the prompt on fruit. If you don't see any prompts, then come closer to fruit.")
			for i = 1, 3 do
				self.FruitsController.FruitHarvested:Wait()
				setText(`Harvest fruits: {i}/{3}.`)
				self.MarkerController:Cancel("TutorialStage1")
				if i ~= 3 then
					self.MarkerController
						:New(
							workspace:WaitForChild("Trees").Apple,
							{ Key = "TutorialStage1", Distance = 0 },
							{ "Model" }
						)
						:catch(warn)
				end
			end
			self.SFXController:PlaySFX("Switch")
			setText("Good job! Now let's sell your fruits.")

			self.MarkerController
				:New(workspace:WaitForChild("SellParts"), { Key = "TutorialStage2", Distance = 10 })
				:await()

			self.SFXController:PlaySFX("Switch")
			setText("Nice! There is a shop where you can buy bags and more. Close the shop when you are ready.")

			self.GuiController:OpenGui("Shop", {
				starterPage = "Bags",
				onClose = function()
					self.SFXController:PlaySFX("Switch")
					setText(
						"And let's answer the last question. Are there only apples? The answer is no. So, let's see more!"
					)

					self.MarkerController
						:New(workspace:WaitForChild("Trees").Pear, { Key = "TutorialStage3", Distane = 50 })
						:await()

					self.SFXController:PlaySFX("Switch")
					setText("There are even more fruits, vegetables, and berries.")
					local cameraScenes = {
						[0] = {
							offset = Vector3.new(40, 10, 0),
							target = Vector3.new(-218.598, 23.446, -160.52),
							duration = 5,
							speed = 5,
							name = "Pear",
						},
						[1] = {
							offset = Vector3.new(50, 15, 0),
							target = Vector3.new(-271.681, 24.444, 191.334),
							duration = 4,
							speed = 5,
							name = "Corn",
						},
						[2] = {
							offset = Vector3.new(20, 5, 0),
							target = Vector3.new(-59.717, 19.449, 233.593),
							duration = 3,
							speed = 5,
							name = "Strawberry",
						},
						[3] = {
							offset = Vector3.new(40, 15, 0),
							target = Vector3.new(213.537, 23.417, -259.63),
							duration = 2,
							speed = 5,
							name = "Apricot",
						},
					}

					self.CameraController:RotateCameraAround(cameraScenes[0]):await()

					for i = 1, 3 do
						self.SFXController:PlaySFX("Switch")
						setText(cameraScenes[i].name)
						self.CameraController:RotateCameraAround(cameraScenes[i]):await()
					end

					self.NotificationsController:new({
						text = "You've completed the tutorial.",
						title = "Tutorial completed!",
						duration = 30,
						type = "info",
					})

					onCancel(false)
				end,
			}, { OpenIfHidden = true, DontCloseIfAlreadyOpen = true, CloseItSelf = true })
		end)
		:catch(warn)
end

return TutorialController
