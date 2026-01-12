local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local gui = Instance.new("ScreenGui", player.PlayerGui)

-- Frame principal
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 180)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Car Tuner 🚛"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)

-- Caixa para Velocidade
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0.8,0,0,30)
speedBox.Position = UDim2.new(0.1,0,0,40)
speedBox.PlaceholderText = "Velocidade (Ex: 200)"
speedBox.Text = ""
speedBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
speedBox.TextColor3 = Color3.new(1,1,1)

-- Caixa para Aceleração
local accelBox = Instance.new("TextBox", frame)
accelBox.Size = UDim2.new(0.8,0,0,30)
accelBox.Position = UDim2.new(0.1,0,0,80)
accelBox.PlaceholderText = "Aceleração (Ex: 5000)"
accelBox.Text = ""
accelBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
accelBox.TextColor3 = Color3.new(1,1,1)

-- Botão aplicar
local applyBtn = Instance.new("TextButton", frame)
applyBtn.Size = UDim2.new(0.6,0,0,30)
applyBtn.Position = UDim2.new(0.2,0,0,120)
applyBtn.Text = "Aplicar 🚀"
applyBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
applyBtn.TextColor3 = Color3.new(1,1,1)

local targetSpeed = 999999999
local targetAccel = 9999999999

applyBtn.MouseButton1Click:Connect(function()
    targetSpeed = tonumber(speedBox.Text) or targetSpeed
    targetAccel = tonumber(accelBox.Text) or targetAccel
end)

-- Função para obter motores do carro
local function getCarMotors()
    local char = player.Character or player.CharacterAdded:Wait()
    local seat = char:FindFirstChildWhichIsA("Humanoid") and char:FindFirstChildWhichIsA("Humanoid").SeatPart
    if not seat or not seat.Parent then return {}, nil end
    local car = seat.Parent
    local motors = {}
    for _, v in pairs(car:GetDescendants()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("power") or v.Name:lower():find("torque")) then
            table.insert(motors,v)
        end
    end
    return motors, seat, car
end

-- Loop principal
RunService.RenderStepped:Connect(function()
    local motors, seat, car = getCarMotors()
    if #motors == 0 or not seat then return end

    -- Potência máxima
    for _, motor in pairs(motors) do
        motor.Value = targetAccel
    end
    if seat:FindFirstChild("MaxSpeed") then
        seat.MaxSpeed.Value = targetSpeed
    end

    -- Cola no chão 🚛
    if seat:FindFirstChild("TurnSpeed") then
        seat.TurnSpeed.Value = 1 -- curva lenta, estável
    end
    if seat:FindFirstChild("SteerSpeed") then
        seat.SteerSpeed.Value = 0.5 -- direção super controlada
    end

    -- Rodas com atrito infinito
    for _, wheel in pairs(car:GetDescendants()) do
        if wheel:IsA("BasePart") and wheel.Name:lower():find("wheel") then
            wheel.CustomPhysicalProperties = PhysicalProperties.new(100, 10, 0) 
            -- densidade = 100 (muito pesado), fricção = 10 (cola), elasticidade = 0 (sem pulo)
        end
    end
end)

-- Drag móvel
local dragging = false
local dragStart, startPos
local uis = game:GetService("UserInputService")

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
