-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)
local Promise = require(ReplicatedStorage:WaitForChild("Packages").promise)

-- Player
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Components
local WindowComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

-- Prompt controller
local PromptController = Knit.CreateController({
	Name = "PromptController",
})

function PromptController:KnitInit()
	self.GuiController = Knit.GetController("GuiController")
	self.SFXController = Knit.GetController("SFXController")
end

function PromptController:Prompt(data: { title: string, text: string, button1: string, button2: string? })
	assert(data ~= nil, "Data is missing or nil.")
	assert(data.text ~= nil, "Text is missing or nil.")
	assert(data.title ~= nil, "Title is missing or nil.")
	assert(data.button1 ~= nil, "Button1 is missing or nil.")

	return Promise.new(function(resolve)
		if not playerGui:FindFirstChild("Prompt") then
			self.GuiController:OpenGui("Prompt", nil, { OpenIfHidden = true, DontStoreInHistory = true })
		end

		local tree

		local function prompt(pressed)
			Roact.unmount(tree)
			tree = nil
			resolve(pressed)
		end

		local element = Roact.createElement(WindowComponent, {
			size = UDim2.fromOffset(400, 300),
			title = data.title,
			closeGui = prompt,
		}, {
			TextLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, -50),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Text = data.text,
				TextSize = 12,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Ubuntu,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
				}),
			}),
			Panel = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 50),
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.Name,
					Padding = UDim.new(0, 10),
				}),
				Button1 = Roact.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 1, -5),
					BorderSizePixel = 0,
					BackgroundColor3 = (
						data.button2 ~= nil and Color3.fromRGB(20, 219, 73) or Color3.fromRGB(255, 255, 255)
					),
					Size = UDim2.fromOffset(150, 40),
					Text = data.button1,
					TextSize = 14,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Font = Enum.Font.Ubuntu,
					[Roact.Event.Activated] = function()
						prompt(data.button1)
					end,
					[Roact.Event.MouseEnter] = function()
						self.SFXController:PlaySFX("MouseEnter")
					end,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
				Button2 = data.button2 and Roact.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 1, -5),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(219, 20, 20),
					Size = UDim2.fromOffset(150, 40),
					Text = data.button2,
					TextSize = 14,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Font = Enum.Font.Ubuntu,
					Active = data.button2 ~= nil,
					[Roact.Event.Activated] = function()
						prompt(data.button2)
					end,
					[Roact.Event.MouseEnter] = function()
						self.SFXController:PlaySFX("MouseEnter")
					end,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
			}),
		})

		tree = Roact.mount(element, playerGui.Prompt, data.title)
	end)
end

return PromptController
