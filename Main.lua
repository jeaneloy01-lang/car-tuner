-- 🚗 CAR TUNER – SOMENTE ACELERAÇÃO
-- Mecânica Brasileira 🇧🇷
-- Script leve, estável e sem lag

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

------------------------------------------------
-- GUI
------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "CarTunerGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Car Tuner 🚗"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)

local accelBox = Instance.new("TextBox", frame)
accelBox.Size = UDim2.new(0.8, 0, 0, 30)
accelBox.Position = UDim2.new(0.1, 0, 0, 50)
accelBox.PlaceholderText = "Aceleração (ex: 8000)"
accelBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
accelBox.TextColor3 = Color3.new(1,1,1)
accelBox.Text = ""

local applyBtn = Instance.new("TextButton", frame)
applyBtn.Size = UDim2.new(0.6, 0, 0, 30)
applyBtn.Position = UDim2.new(0.2, 0, 0, 95)
applyBtn.Text = "Aplicar"
applyBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
applyBtn.TextColor3 = Color3.new(1,1,1)

------------------------------------------------
-- CONFIG
------------------------------------------------
local targetAccel = 8000

applyBtn.MouseButton1Click:Connect(function()
	targetAccel = tonumber(accelBox.Text) or targetAccel
end)

------------------------------------------------
-- PEGA O CARRO
------------------------------------------------
local function getCar()
	local char = player.Character
	if not char then return nil end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or not hum.SeatPart then return nil end

	return hum.SeatPart.Parent
end

------------------------------------------------
-- PEGA CONFIG DO CARRO
------------------------------------------------
local function getConfig(car)
	for _, v in pairs(car:GetDescendants()) do
		if v:IsA("ModuleScript") then
			local ok, cfg = pcall(require, v)
			if ok and type(cfg) == "table" and cfg.Horsepower then
				return cfg
			end
		end
	end
end

------------------------------------------------
-- LOOP LEVE (SEM LAG)
------------------------------------------------
RunService.Heartbeat:Connect(function()
	local car = getCar()
	if not car then return end

	local config = getConfig(car)
	if not config then return end

	-- 🚀 ACELERAÇÃO
	config.Horsepower = math.clamp(targetAccel / 20, 100, 3000)

	if config.ThrotAccel then
		config.ThrotAccel = math.clamp(targetAccel / 10000, 0.05, 1)
	end

	if config.CurveMult then
		config.CurveMult = math.clamp(targetAccel / 16000, 0.5, 4)
	end

	if config.FinalDrive then
		config.FinalDrive = 4 + (targetAccel / 9000)
	end
end)
