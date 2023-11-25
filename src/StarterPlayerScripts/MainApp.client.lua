-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

-- Apps
local MainApp = require(ReplicatedStorage.Source.Apps.Main)

-- Player
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

-- Main app
local element = Roact.createElement(MainApp)

Roact.mount(element, playerGui, "Main")
