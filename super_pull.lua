-- snqw .0gh — Super Pull + Speed Boost + 40Hz
-- All glory to snqw

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()

local pullMult = 100
local speedMult = 3
local hzOn = true
local pullOn = true
local speedOn = true

-- 40Hz
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
pcall(setfpscap, 40)

-- Speed boost every frame (constant velocity push in look direction)
RS.RenderStepped:Connect(function()
    if speedOn and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        local dir = hrp.CFrame.LookVector * Vector3.new(1, 0, 1)
        if dir.Magnitude > 0 then
            hrp.Velocity = hrp.Velocity + dir * speedMult * 50 * RS:GetSteppedDelta()
        end
    end
end)

-- Pull hook (GetMouseDelta amplification)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = function(...)
    local args = {...}
    local self = args[1]
    local method = getnamecallmethod()
    if pullOn and method == "GetMouseDelta" and self == UIS then
        return old(...) * pullMult
    end
    return old(...)
end
setreadonly(mt, true)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SnqwHub"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local bg = Instance.new("ImageLabel")
bg.Size = UDim2.new(0, 340, 0, 380)
bg.Position = UDim2.new(0.5, -170, 0.5, -190)
bg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
bg.BackgroundTransparency = 0.08
bg.BorderSizePixel = 2
bg.BorderColor3 = Color3.fromRGB(180, 0, 0)
bg.Active = true
bg.Draggable = true
bg.Parent = gui

-- Header
local header = Instance.new("ImageLabel")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
header.BorderSizePixel = 0
header.Parent = bg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "SNQW .0GH"
title.TextColor3 = Color3.fromRGB(255, 50, 50)
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 16)
subtitle.Position = UDim2.new(0, 0, 1, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "king and top 1"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = header

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 18)
status.Position = UDim2.new(0, 10, 0, 56)
status.BackgroundTransparency = 1
status.Text = "Pull: 100x | Speed: 3x | 40Hz: ON"
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.TextScaled = true
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = bg

function updateStatus()
    status.Text = "Pull: " .. (pullOn and pullMult .. "x" or "OFF") .. " | Speed: " .. (speedOn and speedMult .. "x" or "OFF") .. " | 40Hz: " .. (hzOn and "ON" or "OFF")
end

function makeBtn(txt, y, w, color, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w or 140, 0, 34)
    b.Position = UDim2.new(0, 10 + ((w or 140) + 10) * ((y % 100) > 50 and 1 or 0), 0, 80 + math.floor(y / 50) * 42)
    b.BackgroundColor3 = color or Color3.fromRGB(25, 25, 25)
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = bg
    local hover = Instance.new("UICorner")
    hover.CornerRadius = UDim.new(0, 4)
    hover.Parent = b
    b.MouseEnter:Connect(function() b.BackgroundColor3 = color and color:Lerp(Color3.fromRGB(255,255,255), 0.2) or Color3.fromRGB(50, 50, 50) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = color or Color3.fromRGB(25, 25, 25) end)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- Row 1
makeBtn("Pull: ON", 0, 150, Color3.fromRGB(30, 30, 140), function()
    pullOn = not pullOn; updateStatus()
end)
makeBtn("Pull +100", 0, 150, Color3.fromRGB(20, 20, 100), function()
    pullMult = pullMult + 50; updateStatus()
end)

-- Row 2
makeBtn("Speed: ON", 50, 150, Color3.fromRGB(30, 120, 30), function()
    speedOn = not speedOn; updateStatus()
end)
makeBtn("Speed +1", 50, 150, Color3.fromRGB(20, 80, 20), function()
    speedMult = speedMult + 1; updateStatus()
end)

-- Row 3
makeBtn("40Hz: ON", 100, 150, Color3.fromRGB(120, 30, 30), function()
    hzOn = not hzOn; updateStatus()
end)
makeBtn("Reset All", 100, 150, Color3.fromRGB(80, 20, 20), function()
    pullMult = 100; speedMult = 3; pullOn = true; speedOn = true; hzOn = true; updateStatus()
end)

-- Row 4
makeBtn("MAX SPEED", 150, 310, Color3.fromRGB(180, 0, 0), function()
    speedMult = 20; pullMult = 500; pullOn = true; speedOn = true; updateStatus()
end)

-- Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 20)
footer.Position = UDim2.new(0, 0, 1, -20)
footer.BackgroundTransparency = 1
footer.Text = "snqw .0gh on discord"
footer.TextColor3 = Color3.fromRGB(100, 100, 100)
footer.TextScaled = true
footer.Font = Enum.Font.Gotham
footer.Parent = bg

-- Copy loadstring
makeBtn("Copy Loader", 200, 310, Color3.fromRGB(40, 40, 40), function()
    if setclipboard then
        setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/snqw293-eng/superpull/main/super_pull.lua"))()')
    end
end)

print("snqw .0gh — loaded")
