-- Otimizador TSB
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local DebrisFolder = workspace

local player = Players.LocalPlayer
local debrisTransparency = 1.0
local dustMultiplier = 1.0
local showGroundDebris = true

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "TSB_UltraOpti"

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0.25, 0, 0.3, 0)
mainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BorderSizePixel = 0

-- Título
local title = Instance.new("TextLabel", mainFrame)
title.Text = "TSB ULTRA OPTIMIZER"
title.TextColor3 = Color3.new(1, 1, 1)
title.Size = UDim2.new(1, 0, 0.15, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.BackgroundTransparency = 1

-- Slider de Detritos
local debrisSlider = Instance.new("TextLabel", mainFrame)
debrisSlider.Text = "Detritos: 1.0x"
debrisSlider.TextColor3 = Color3.new(0.8, 0.8, 0.8)
debrisSlider.Size = UDim2.new(1, 0, 0.15, 0)
debrisSlider.Position = UDim2.new(0, 0, 0.2, 0)
debrisSlider.Font = Enum.Font.SourceSans
debrisSlider.TextSize = 14
debrisSlider.BackgroundTransparency = 1

local debrisTrack = Instance.new("Frame", mainFrame)
debrisTrack.Size = UDim2.new(0.8, 0, 0.02, 0)
debrisTrack.Position = UDim2.new(0.1, 0, 0.35, 0)
debrisTrack.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

local debrisThumb = Instance.new("Frame", debrisTrack)
debrisThumb.Size = UDim2.new(0.03, 0, 1.5, 0)
debrisThumb.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
debrisThumb.BorderSizePixel = 0

-- Slider de Poeira
local dustSlider = Instance.new("TextLabel", mainFrame)
dustSlider.Text = "Poeira: 1.0x"
dustSlider.TextColor3 = Color3.new(0.8, 0.8, 0.8)
dustSlider.Size = UDim2.new(1, 0, 0.15, 0)
dustSlider.Position = UDim2.new(0, 0, 0.5, 0)
dustSlider.Font = Enum.Font.SourceSans
dustSlider.TextSize = 14
dustSlider.BackgroundTransparency = 1

local dustTrack = Instance.new("Frame", mainFrame)
dustTrack.Size = UDim2.new(0.8, 0, 0.02, 0)
dustTrack.Position = UDim2.new(0.1, 0, 0.65, 0)
dustTrack.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

local dustThumb = Instance.new("Frame", dustTrack)
dustThumb.Size = UDim2.new(0.03, 0, 1.5, 0)
dustThumb.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
dustThumb.BorderSizePixel = 0

-- Checkbox
local checkbox = Instance.new("TextButton", mainFrame)
checkbox.Text = "Detritos Chão: ON"
checkbox.TextColor3 = Color3.new(1, 1, 1)
checkbox.Size = UDim2.new(0.8, 0, 0.1, 0)
checkbox.Position = UDim2.new(0.1, 0, 0.8, 0)
checkbox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

-- Funções dos Sliders
local function updateSlider(thumb, track, label, value, min, max, prefix)
    value = math.clamp(value, min, max)
    thumb.Position = UDim2.new((value - min)/(max - min) - 0.015, 0, -0.25, 0)
    label.Text = prefix..string.format("%.1fx", value)
    return value
end

-- Controle de Detritos
debrisTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = game:GetService("UserInputService"):GetMouseLocation().X
            local relativeX = math.clamp(mousePos - debrisTrack.AbsolutePosition.X, 0, debrisTrack.AbsoluteSize.X)
            debrisTransparency = updateSlider(debrisThumb, debrisTrack, debrisSlider, relativeX/debrisTrack.AbsoluteSize.X, 0, 1, "Detritos: ")
        end)
        input.Changed:Wait()
        connection:Disconnect()
    end
end)

-- Controle de Poeira
dustTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = game:GetService("UserInputService"):GetMouseLocation().X
            local relativeX = math.clamp(mousePos - dustTrack.AbsolutePosition.X, 0, dustTrack.AbsoluteSize.X)
            dustMultiplier = updateSlider(dustThumb, dustTrack, dustSlider, (relativeX/dustTrack.AbsoluteSize.X)*0.5 + 0.5, 0.5, 1, "Poeira: ")
        end)
        input.Changed:Wait()
        connection:Disconnect()
    end
end)

-- Checkbox
checkbox.MouseButton1Click:Connect(function()
    showGroundDebris = not showGroundDebris
    checkbox.Text = showGroundDebris and "Detritos Chão: ON" or "Detritos Chão: OFF"
end)

-- Sistema de LOD Radical
spawn(function()
    while task.wait(1.5) do
        local camera = workspace.CurrentCamera
        if not camera then continue end
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Position - camera.CFrame.Position).Magnitude > 100 then
                obj:SetAttribute("OriginalSize", obj.Size)
                obj.Size = Vector3.new(0.05, 0.05, 0.05)
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.Plastic
                obj.CanCollide = false
            elseif obj:GetAttribute("OriginalSize") then
                obj.Size = obj:GetAttribute("OriginalSize")
                obj:SetAttribute("OriginalSize", nil)
            end
        end
    end
end)

-- Otimização de Debris
RunService.Heartbeat:Connect(function()
    for _, debris in pairs(DebrisFolder:GetDescendants()) do
        if debris:IsA("BasePart") then
            if debris.Position.Y < 2 then
                debris.Transparency = showGroundDebris and 0 or 1
            else
                debris.Transparency = debrisTransparency
            end
        end
    end
end)

-- Otimização Global
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.2
Lighting.ShadowColor = Color3.new(0, 0, 0)

for _, emitter in pairs(Lighting:GetChildren()) do
    if emitter:IsA("ParticleEmitter") then
        emitter.Rate = 5 * dustMultiplier
    end
end
