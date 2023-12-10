-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Player
local localPlayer = Players.LocalPlayer

-- Components
local WindowComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

local function Tabs(props)
	local SFXController = Knit.GetController("SFXController")

	local activeTab, setActiveTab = props.activeTab, props.setActiveTab
	local tabs = props.tabs
	local _elements = {}

	for _, tab in ipairs(tabs) do
		local new = Roact.createElement("TextButton", {
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			Text = tab,
			TextColor3 = activeTab:map(function(value)
				return value == tab and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(125, 125, 125)
			end),
			TextSize = 12,
			Font = Enum.Font.Ubuntu,
			TextXAlignment = Enum.TextXAlignment.Left,
			[Roact.Event.Activated] = function()
				setActiveTab(tab)
			end,
			[Roact.Event.MouseEnter] = function()
				SFXController:PlaySFX("MouseEnter")
			end,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 5),
			}),
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = activeTab:map(function(value)
					return value == tab and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(125, 125, 125)
				end),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
		})
		table.insert(_elements, new)
	end

	return Roact.createFragment(_elements)
end

local function PlayerProfile(props)
	local AdminController = Knit.GetController("AdminController")

	local player: Player = props.player
	local activePlayer, setActivePlayer = props.activePlayer, props.setActivePlayer

	local kickReason, setKickReason = Roact.createBinding()
	local blockReason, setBlockReason = Roact.createBinding()
	local blockDuration, setBlockDuration = Roact.createBinding()

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	}, {
		Label = Roact.createElement("TextLabel", {
			Position = UDim2.fromOffset(48, 0),
			Size = UDim2.fromOffset(254, 48),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = `{player.DisplayName} (@{player.Name})`,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.fromName(
				"Ubuntu",
				player.UserId == localPlayer.UserId and Enum.FontWeight.Bold or Enum.FontWeight.Regular
			),
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 5),
			}),
		}),
		Icon = Roact.createElement("ImageLabel", {
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Image = Players:GetUserThumbnailAsync(
				player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size48x48
			),
			Size = UDim2.fromOffset(48, 48),
		}),
		State = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -11, 0, 11),
			Size = UDim2.fromOffset(28, 28),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Image = activePlayer:map(function(value)
				return value == player.UserId and "rbxassetid://15591506916" or "rbxassetid://15591506783"
			end),
		}),
		Button = Roact.createElement("TextButton", {
			Size = UDim2.new(1, 0, 0, 48),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = "",
			[Roact.Event.Activated] = function()
				setActivePlayer(activePlayer:getValue() == player.UserId and "" or player.UserId)
			end,
			ZIndex = 2,
		}),
		Content = Roact.createElement("Frame", {
			Position = UDim2.fromOffset(0, 48),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = activePlayer:map(function(value)
				return value == player.UserId
			end),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.Name,
			}),
			[0] = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				Label = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 30),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Text = "Kick",
					TextSize = 14,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
					}),
				}),
				Content = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0),
					Position = UDim2.fromOffset(0, 30),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.Y,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						Padding = UDim.new(0, 5),
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.Name,
					}),
					[0] = Roact.createElement("TextBox", {
						Text = "",
						PlaceholderText = "Enter reason...",
						TextSize = 12,
						PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
						BackgroundColor3 = Color3.fromRGB(35, 35, 35),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Font = Enum.Font.Ubuntu,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextWrapped = true,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						[Roact.Change.Text] = function(object: TextBox)
							setKickReason(object.Text)
						end,
						ClearTextOnFocus = false,
					}, {
						UIPadding = Roact.createElement("UIPadding", {
							PaddingLeft = UDim.new(0, 5),
							PaddingTop = UDim.new(0, 5),
							PaddingBottom = UDim.new(0, 5),
							PaddingRight = UDim.new(0, 5),
						}),
					}),
					[1] = Roact.createElement("TextButton", {
						Size = UDim2.fromOffset(125, 35),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						TextColor3 = Color3.fromRGB(0, 0, 0),
						Text = "Kick",
						TextSize = 14,
						Font = Enum.Font.Ubuntu,
						[Roact.Event.Activated] = function()
							AdminController:Kick({ reason = kickReason:getValue(), playerId = player.UserId })
						end,
					}, {
						UICorner = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 5),
						}),
					}),
				}),
			}),
			[1] = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				Label = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 30),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Text = "Block",
					TextSize = 14,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
					}),
				}),
				Content = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0),
					Position = UDim2.fromOffset(0, 30),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.Y,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						Padding = UDim.new(0, 5),
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.Name,
					}),
					[0] = Roact.createElement("TextBox", {
						Text = "",
						PlaceholderText = "Enter reason...",
						TextSize = 12,
						PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
						BackgroundColor3 = Color3.fromRGB(35, 35, 35),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Font = Enum.Font.Ubuntu,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextWrapped = true,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						[Roact.Change.Text] = function(object: TextBox)
							setBlockReason(object.Text)
						end,
						ClearTextOnFocus = false,
					}, {
						UIPadding = Roact.createElement("UIPadding", {
							PaddingLeft = UDim.new(0, 5),
							PaddingTop = UDim.new(0, 5),
							PaddingBottom = UDim.new(0, 5),
							PaddingRight = UDim.new(0, 5),
						}),
					}),
					[1] = Roact.createElement("TextBox", {
						Text = "",
						PlaceholderText = "Enter duration...",
						TextSize = 12,
						PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
						BackgroundColor3 = Color3.fromRGB(35, 35, 35),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Font = Enum.Font.Ubuntu,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextWrapped = true,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						[Roact.Change.Text] = function(object: TextBox)
							setBlockDuration(object.Text)
						end,
						ClearTextOnFocus = false,
					}, {
						UIPadding = Roact.createElement("UIPadding", {
							PaddingLeft = UDim.new(0, 5),
							PaddingTop = UDim.new(0, 5),
							PaddingBottom = UDim.new(0, 5),
							PaddingRight = UDim.new(0, 5),
						}),
					}),
					[2] = Roact.createElement("TextButton", {
						Size = UDim2.fromOffset(125, 35),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						TextColor3 = Color3.fromRGB(0, 0, 0),
						Text = "Block",
						TextSize = 14,
						Font = Enum.Font.Ubuntu,
						[Roact.Event.Activated] = function()
							AdminController:Block({
								reason = blockReason:getValue(),
								playerId = player.UserId,
								duration = blockDuration:getValue(),
							})
						end,
					}, {
						UICorner = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 5),
						}),
					}),
				}),
			}),
		}),
	})
end

local function PlayersProfiles(props)
	local players = props.players
	local activePlayer, setActivePlayer = Roact.createBinding()
	local _elements = {}

	for _, player in ipairs(players) do
		local new = Roact.createElement(
			PlayerProfile,
			{ player = player, activePlayer = activePlayer, setActivePlayer = setActivePlayer }
		)
		table.insert(_elements, new)
	end

	return Roact.createFragment(_elements)
end

local PlayersPage = Roact.Component:extend("PlayersPage")

function PlayersPage:init()
	self.connections = {}
	self:setState({
		players = Players:GetPlayers(),
	})
	self.connections = {}
	table.insert(
		self.connections,
		Players.PlayerAdded:Connect(function(player)
			local new = self.state
			table.insert(new, player)
			self:setState({
				players = new,
			})
		end)
	)
	table.insert(
		self.connections,
		Players.PlayerRemoving:Connect(function(player)
			local new = self.state
			local index = table.find(new, player)
			if index then
				table.remove(new, index)
				self:setState({
					players = new,
				})
			end
		end)
	)
end

function PlayersPage:render()
	return Roact.createElement("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 5,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Active = false,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 10),
			FillDirection = Enum.FillDirection.Vertical,
		}),
		Profiles = Roact.createElement(PlayersProfiles, { players = self.state.players }),
	})
end

function PlayersPage:willUnmount()
	for i, v: RBXScriptConnection in ipairs(self.connections) do
		v:Disconnect()
		self.connections[i] = nil
	end
	self.connections = nil
end

local function GamePage()
	-- code
end

local function MultiServerPage()
	local AdminController = Knit.GetController("AdminController")

	local kickReason, setKickReason = Roact.createBinding()
	local kickUser, setKickUser = Roact.createBinding()
	local blockDuration, setBlockDuration = Roact.createBinding()
	local blockReason, setBlockReason = Roact.createBinding()
	local blockUser, setBlockUser = Roact.createBinding()

	return Roact.createElement("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 5,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Active = false,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 10),
			FillDirection = Enum.FillDirection.Vertical,
		}),
		[0] = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Label = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 30),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Text = "Kick",
				TextSize = 14,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Ubuntu,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 5),
				}),
			}),
			Content = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0),
				Position = UDim2.fromOffset(0, 30),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 5),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.Name,
				}),
				[0] = Roact.createElement("TextBox", {
					Text = "",
					PlaceholderText = "Enter user id...",
					TextSize = 12,
					PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					[Roact.Change.Text] = function(object: TextBox)
						setKickUser(object.Text)
					end,
					ClearTextOnFocus = false,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
					}),
				}),
				[1] = Roact.createElement("TextBox", {
					Text = "",
					PlaceholderText = "Enter reason...",
					TextSize = 12,
					PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					[Roact.Change.Text] = function(object: TextBox)
						setKickReason(object.Text)
					end,
					ClearTextOnFocus = false,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
					}),
				}),
				[2] = Roact.createElement("TextButton", {
					Size = UDim2.fromOffset(125, 35),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = "Kick",
					TextSize = 14,
					Font = Enum.Font.Ubuntu,
					[Roact.Event.Activated] = function()
						AdminController:Kick({ reason = kickReason:getValue(), playerId = kickUser:getValue() })
					end,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
			}),
		}),
		[1] = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Label = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 30),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Text = "Block",
				TextSize = 14,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Ubuntu,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 5),
				}),
			}),
			Content = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0),
				Position = UDim2.fromOffset(0, 30),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 5),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.Name,
				}),
				[1] = Roact.createElement("TextBox", {
					Text = "",
					PlaceholderText = "Enter reason...",
					TextSize = 12,
					PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					[Roact.Change.Text] = function(object: TextBox)
						setBlockReason(object.Text)
					end,
					ClearTextOnFocus = false,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
					}),
				}),
				[2] = Roact.createElement("TextBox", {
					Text = "",
					PlaceholderText = "Enter duration...",
					TextSize = 12,
					PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					[Roact.Change.Text] = function(object: TextBox)
						setBlockDuration(object.Text)
					end,
					ClearTextOnFocus = false,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
					}),
				}),
				[0] = Roact.createElement("TextBox", {
					Text = "",
					PlaceholderText = "Enter user id...",
					TextSize = 12,
					PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					[Roact.Change.Text] = function(object: TextBox)
						setBlockUser(object.Text)
					end,
					ClearTextOnFocus = false,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
					}),
				}),
				[3] = Roact.createElement("TextButton", {
					Size = UDim2.fromOffset(125, 35),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = "Block",
					TextSize = 14,
					Font = Enum.Font.Ubuntu,
					[Roact.Event.Activated] = function()
						AdminController:Block({
							reason = blockReason:getValue(),
							playerId = tonumber(blockUser:getValue()),
							duration = tonumber(blockDuration:getValue()),
						})
					end,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
			}),
		}),
	})
end

local function Pages(props)
	local pageComponentsByNames = {
		["Players"] = PlayersPage,
		["Game"] = GamePage,
		["Multi server"] = MultiServerPage,
	}
	local pages = props.pages
	local activeTab = props.activeTab
	local _elements = {}

	for _, page in ipairs(pages) do
		local new = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Visible = activeTab:map(function(value)
				return value == page
			end),
		}, {
			Roact.createElement(pageComponentsByNames[page]),
		})
		table.insert(_elements, new)
	end

	return Roact.createFragment(_elements)
end

-- Admin panel app
local function AdminPanel(props)
	local activeTab, setActiveTab = Roact.createBinding("Players")
	local closeGui = props.closeGui

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Contariner = Roact.createElement(WindowComponent, {
			size = UDim2.fromOffset(400, 300),
			title = "Admin panel",
			closeGui = closeGui,
		}, {
			Tabs = Roact.createElement("Frame", {
				Size = UDim2.new(0, 150, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			}, {
				Holder = Roact.createElement("ScrollingFrame", {
					Active = false,
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					CanvasSize = UDim2.fromOffset(0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					ScrollBarThickness = 5,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
					}),
					UIListLayout = Roact.createElement("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 5),
					}),
					Tabs = Roact.createElement(Tabs, {
						tabs = { "Players", "Game", "Multi server" },
						activeTab = activeTab,
						setActiveTab = setActiveTab,
					}),
				}),
			}),
			Pages = Roact.createElement("Frame", {
				Position = UDim2.fromOffset(150, 0),
				Size = UDim2.new(0, 250, 1, 0),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
			}, {
				Pages = Roact.createElement(Pages, {
					pages = { "Players", "Game", "Multi server" },
					activeTab = activeTab,
				}),
			}),
		}),
	})
end

return AdminPanel
