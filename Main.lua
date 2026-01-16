-- 🚗 CAR TUNER V2 – FREIO CORRIGIDO (MECÂNICA BRASILEIRA)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- =========================
-- 🔍 PEGA O VEHICLE SEAT
-- =========================
local function getSeat()
    if not player.Character then return nil end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat")
        and v.Occupant
        and v.Occupant.Parent == player.Character then
            return v
        end
    end
    return nil
end

-- =========================
-- 🚀 ACELERAÇÃO (CAR TUNER)
-- =========================
local targetAccel = 8000

RunService.Heartbeat:Connect(function()
    local seat = getSeat()
    if not seat then return end

    -- garante que aceleração não é bloqueada
    if seat.BrakeTorque < 10 then
        seat.Throttle = math.clamp(seat.Throttle, -1, 1)
    end
end)

-- =========================
-- 🛑 FREIO POR BOTÃO (TXT Brake)
-- =========================
task.wait(1)

local brakeButton
for _, v in pairs(player.PlayerGui:GetDescendants()) do
    if v:IsA("TextButton") and v.Name == "Brake" then
        brakeButton = v
        break
    end
end

if brakeButton then
    local braking = false
    local BRAKE_FORCE = 1e6

    local function applyBrake(state)
        local seat = getSeat()
        if not seat then return end

        if state then
            seat.Throttle = 0
            seat.BrakeTorque = BRAKE_FORCE
        else
            seat.BrakeTorque = 0
        end
    end

    -- dedo pressionou
    brakeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            braking = true
            applyBrake(true)
        end
    end)

    -- dedo soltou
    brakeButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            braking = false
            applyBrake(false)
        end
    end)

    -- segurança anti-bug (freio nunca fica preso)
    RunService.RenderStepped:Connect(function()
        if not braking then
            local seat = getSeat()
            if seat then
                seat.BrakeTorque = 0
            end
        end
    end)
end
