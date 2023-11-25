-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)
local Knit = require(ReplicatedStorage.Packages.knit)

-- Player
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

-- Wait knit to load
Knit.OnStart():await()

-- Main app
local MainApp = require(ReplicatedStorage.Source.Apps.Main)
local element = Roact.createElement(MainApp)

Roact.mount(element, playerGui, "Main")
