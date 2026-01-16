local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Car Tuner 🚗"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local accelBox = Instance.new("TextBox", frame)
accelBox.Size = UDim2.new(0.8, 0, 0, 30)
accelBox.Position = UDim2.new(0.1, 0, 0, 45)
accelBox.PlaceholderText = "Aceleração (ex: 8000)"
accelBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
accelBox.TextColor3 = Color3.new(1,1,1)

local brakeBox = Instance.new("TextBox", frame)
brakeBox.Size = UDim2.new(0.8, 0, 0, 30)
brakeBox.Position = UDim2.new(0.1, 0, 0, 85)
brakeBox.PlaceholderText = "Força do Freio (ex: 30000)"
brakeBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
brakeBox.TextColor3 = Color3.new(1,1,1)

local applyBtn = Instance.new("TextButton", frame)
applyBtn.Size = UDim2.new(0.6, 0, 0, 30)
applyBtn.Position = UDim2.new(0.2, 0, 0, 130)
applyBtn.Text = "Aplicar"
applyBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
applyBtn.TextColor3 = Color3.new(1,1,1)

-- valores
local targetAccel = 8000
local targetBrake = 30000

applyBtn.MouseButton1Click:Connect(function()
	targetAccel = tonumber(accelBox.Text) or targetAccel
	targetBrake = tonumber(brakeBox.Text) or targetBrake
end)

-- pega carro + banco
local function getCar()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or not hum.SeatPart then return end
	return hum.SeatPart.Parent, hum.SeatPart
end

-- acha config do chassi
local function getConfig(car)
	for _,v in pairs(car:GetDescendants()) do
		if v:IsA("ModuleScript") then
			local ok, cfg = pcall(require, v)
			if ok and type(cfg) == "table" and cfg.BrakeForce then
				return cfg
			end
		end
	end
end

-- LOOP PRINCIPAL
RunService.RenderStepped:Connect(function()
	local car, seat = getCar()
	if not car or not seat then return end

	local config = getConfig(car)
	if not config then return end

	------------------
	-- 🚀 ACELERAÇÃO (JEITO ANTIGO – FUNCIONA)
	------------------
	for _,v in pairs(car:GetDescendants()) do
		if v:IsA("NumberValue") and
		   (v.Name:lower():find("power") or v.Name:lower():find("torque")) then
			v.Value = targetAccel
		end
	end

	------------------
	-- 🛑 FREIO INTELIGENTE (SEM BUG DE RÉ)
	------------------
	local throttle = seat.Throttle

	if throttle > 0 then
		-- acelerando → solta freio
		config.BrakeForce = 0
		config.PBrakeForce = 0
		config.EBrakeForce = 0
	elseif throttle < 0 then
		-- ré → freio médio
		config.BrakeForce = targetBrake * 0.6
		config.PBrakeForce = targetBrake
		config.EBrakeForce = targetBrake * 0.5
	else
		-- sem input → freio normal
		config.BrakeForce = targetBrake
		config.PBrakeForce = targetBrake * 2
		config.EBrakeForce = targetBrake * 0.8
	end

	if config.BrakeBias then
		config.BrakeBias = 0.65
	end

	if config.ABSEnabled ~= nil then
		config.ABSEnabled = false
	end

	------------------
	-- 🛞 ADERÊNCIA
	------------------
	for _,wheel in pairs(car:GetDescendants()) do
		if wheel:IsA("BasePart") and wheel.Name:lower():find("wheel") then
			wheel.CustomPhysicalProperties =
				PhysicalProperties.new(80, 8, 0)
		end
	end
end)
