-- DECOY GUI SCRIPT
-- Run this first, it shows fake "unlock in 5 mins" screen

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MM2HubLoader"
gui.Parent = playerGui
gui.ResetOnSpawn = false

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 250)
frame.Position = UDim2.new(0.5, -175, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

-- Title text
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔪 MM2 HUB 🔪"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 2.5)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 5)
btnCorner.Parent = minBtn

-- Status text
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 30)
status.Position = UDim2.new(0, 20, 0, 50)
status.BackgroundTransparency = 1
status.Text = "🔒 SCRIPT LOCKED"
status.TextColor3 = Color3.fromRGB(255, 100, 100)
status.TextSize = 18
status.Font = Enum.Font.GothamBold
status.Parent = frame

-- Timer text
local timerText = Instance.new("TextLabel")
timerText.Size = UDim2.new(1, -40, 0, 40)
timerText.Position = UDim2.new(0, 20, 0, 90)
timerText.BackgroundTransparency = 1
timerText.Text = "05:00"
timerText.TextColor3 = Color3.fromRGB(255, 200, 100)
timerText.TextSize = 32
timerText.Font = Enum.Font.GothamBold
timerText.Parent = frame

-- Loading bar background
local loadBg = Instance.new("Frame")
loadBg.Size = UDim2.new(0.8, 0, 0, 8)
loadBg.Position = UDim2.new(0.1, 0, 0, 145)
loadBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
loadBg.BorderSizePixel = 0
loadBg.Parent = frame

local loadCorner = Instance.new("UICorner")
loadCorner.CornerRadius = UDim.new(1, 0)
loadCorner.Parent = loadBg

-- Loading bar fill
local loadFill = Instance.new("Frame")
loadFill.Size = UDim2.new(0, 0, 1, 0)
loadFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
loadFill.BorderSizePixel = 0
loadFill.Parent = loadBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = loadFill

-- Info text
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -40, 0, 40)
info.Position = UDim2.new(0, 20, 0, 165)
info.BackgroundTransparency = 1
info.Text = "Please wait while we load MM2 Hub..."
info.TextColor3 = Color3.fromRGB(150, 150, 170)
info.TextSize = 11
info.Font = Enum.Font.Gotham
info.Parent = frame

-- Minimize functionality
local minimized = false

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        frame.Size = UDim2.new(0, 350, 0, 35)
        status.Visible = false
        timerText.Visible = false
        loadBg.Visible = false
        info.Visible = false
        minBtn.Text = "□"
    else
        frame.Size = UDim2.new(0, 350, 0, 250)
        status.Visible = true
        timerText.Visible = true
        loadBg.Visible = true
        info.Visible = true
        minBtn.Text = "−"
    end
end)

-- Drag functionality
local dragging = false
local dragStart
local frameStart

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = frame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

-- TIMER SYSTEM
local startTime = tick()
local totalSeconds = 300 -- 5 minutes

local function updateTimer()
    local elapsed = tick() - startTime
    local remaining = math.max(0, totalSeconds - elapsed)
    
    local minutes = math.floor(remaining / 60)
    local seconds = math.floor(remaining % 60)
    timerText.Text = string.format("%02d:%02d", minutes, seconds)
    
    local progress = elapsed / totalSeconds
    loadFill.Size = UDim2.new(progress, 0, 1, 0)
    
    if progress < 0.3 then
        status.Text = "🔒 SCRIPT LOCKED"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
    elseif progress < 0.7 then
        status.Text = "⏳ VERIFYING LICENSE..."
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
    else
        status.Text = "🔓 UNLOCKING SOON..."
        status.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
    
    return remaining <= 0
end

-- Update every second
local done = false
while not done and task.wait(1) do
    done = updateTimer()
end

-- 5 MINUTES DONE - LOAD THE REAL SCRIPT
status.Text = "✅ LOADING MM2 HUB!"
status.TextColor3 = Color3.fromRGB(100, 255, 100)
timerText.Text = "LOADING..."
info.Text = "Injecting MM2 Hub..."
loadFill.Size = UDim2.new(1, 0, 1, 0)

task.wait(1)

-- Execute your MM2 Hub loadstring
local success, err = pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/m00ndiety/Moondiety/refs/heads/main/Loader'))()
end)

if not success then
    info.Text = "Failed to load MM2 Hub: " .. tostring(err)
    task.wait(3)
else
    info.Text = "MM2 Hub loaded! Closing in 3s..."
    task.wait(3)
end

-- Close the GUI
gui:Destroy()
