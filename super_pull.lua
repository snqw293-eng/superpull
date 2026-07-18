local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()

local pullMult = 100
local speedMult = 5
local pullOn = true
local speedOn = true
local curTab = 1

-- 40Hz
pcall(function() settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled end)

-- Hook
local hookOK = pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(...)
        local a = {...}
        if pullOn and getnamecallmethod() == "GetMouseDelta" and a[1] == UIS then return old(...) * pullMult end
        return old(...)
    end
    setreadonly(mt, true)
end)

-- Speed
RS.RenderStepped:Connect(function()
    if speedOn and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        local dir = hrp.CFrame.LookVector * Vector3.new(1, 0, 1)
        if dir.Magnitude > 0 then hrp.Velocity = hrp.Velocity + dir * speedMult * 60 * RS:GetSteppedDelta() end
    end
end)

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "Snqw"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local bg = Instance.new("Frame")
bg.Size = UDim2.new(0, 340, 0, 360)
bg.Position = UDim2.new(0.5, -170, 0.5, -180)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BorderSizePixel = 2
bg.BorderColor3 = Color3.fromRGB(255, 0, 0)
bg.Active = true
bg.Draggable = true
bg.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
title.BorderSizePixel = 0
title.Text = "SNQW .0GH"
title.TextColor3 = Color3.fromRGB(255, 30, 30)
title.TextSize = 26
title.Font = Enum.Font.FredokaOne
title.Parent = bg

local hookStat = Instance.new("TextLabel")
hookStat.Size = UDim2.new(1, -10, 0, 14)
hookStat.Position = UDim2.new(0, 5, 0, 36)
hookStat.BackgroundTransparency = 1
hookStat.Text = "[" .. (hookOK and "PULL:OK" or "PULL:FAIL") .. "] [SPEED:ON] [40Hz:ON]"
hookStat.TextColor3 = hookOK and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 0)
hookStat.TextSize = 11
hookStat.Font = Enum.Font.GothamBold
hookStat.TextXAlignment = Enum.TextXAlignment.Left
hookStat.Parent = bg

-- Tabs
local tabY = 54
local tabH = 28
local tabNames = {"PULL", "SPEED", "MISC"}
local tabBtns = {}

for i, name in ipairs(tabNames) do
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(0.33, -2, 0, tabH)
    tb.Position = UDim2.new((i-1) * 0.33, 1, 0, tabY)
    tb.BackgroundColor3 = i == 1 and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(15, 15, 15)
    tb.BorderSizePixel = 0
    tb.Text = name
    tb.TextColor3 = Color3.fromRGB(255, 255, 255)
    tb.TextSize = 13
    tb.Font = Enum.Font.GothamBold
    tb.Parent = bg
    tb.MouseButton1Click:Connect(function()
        curTab = i
        for j, b in ipairs(tabBtns) do
            TS:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = j == i and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(15, 15, 15)}):Play()
        end
        for j, c in ipairs(contents) do c.Visible = j == i end
    end)
    tabBtns[i] = tb
end

-- Content panels
local contents = {}
local conY = tabY + tabH + 4

for i = 1, 3 do
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, -4, 1, -(conY + 24))
    c.Position = UDim2.new(0, 2, 0, conY)
    c.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    c.BorderSizePixel = 0
    c.Visible = i == 1
    c.Parent = bg
    contents[i] = c
end

function cbtn(con, txt, y, col, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = col or Color3.fromRGB(20, 20, 20)
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.fromRGB(60, 60, 60)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.Parent = con
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = b
    b.MouseEnter:Connect(function() TS:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = col and col:Lerp(Color3.fromRGB(255,255,255), 0.2) or Color3.fromRGB(40,40,40)}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = col or Color3.fromRGB(20,20,20)}):Play() end)
    b.MouseButton1Click:Connect(cb)
end

-- Tab 1: Pull
cbtn(contents[1], "Pull: " .. (pullOn and "ON" or "OFF"), 6, Color3.fromRGB(25, 25, 120), function()
    pullOn = not pullOn
end)
cbtn(contents[1], "Pull Multiplier: " .. pullMult .. "x", 40, Color3.fromRGB(20, 20, 80), function()
    pullMult = pullMult + 50
end)
cbtn(contents[1], "Set 500x", 74, Color3.fromRGB(60, 10, 10), function()
    pullMult = 500; pullOn = true
end)
cbtn(contents[1], "Hook Status: " .. (hookOK and "WORKING" or "FAILED"), 108, hookOK and Color3.fromRGB(10, 60, 10) or Color3.fromRGB(60, 10, 10), function() end)

-- Tab 2: Speed
cbtn(contents[2], "Speed: " .. (speedOn and "ON" or "OFF"), 6, Color3.fromRGB(25, 100, 25), function()
    speedOn = not speedOn
end)
cbtn(contents[2], "Speed: " .. speedMult .. "x", 40, Color3.fromRGB(20, 70, 20), function()
    speedMult = speedMult + 5
end)
cbtn(contents[2], "MAX (20x)", 74, Color3.fromRGB(150, 0, 0), function()
    speedMult = 20; speedOn = true; pullMult = 500; pullOn = true
end)
cbtn(contents[2], "Double Speed", 108, Color3.fromRGB(40, 60, 15), function()
    speedMult = speedMult * 2
end)

-- Tab 3: Misc
cbtn(contents[3], "Copy Loader", 6, Color3.fromRGB(30, 30, 30), function()
    if setclipboard then setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/snqw293-eng/superpull/main/super_pull.lua"))()') end
end)
cbtn(contents[3], "Rescan Game", 40, Color3.fromRGB(40, 30, 15), function()
    local found = false
    pcall(function()
        for _, v in ipairs(getgc()) do
            if type(v) == "function" then
                local c = {getconstants(v)}
                for _, cc in ipairs(c) do
                    if type(cc) == "string" and (cc:lower():find("delta") or cc:lower():find("drag") or cc:lower():find("mouse")) then
                        found = getinfo(v).source or "?"
                        break
                    end
                end
            end
            if found then break end
        end
    end)
end)
cbtn(contents[3], "Quit", 74, Color3.fromRGB(100, 0, 0), function()
    speedOn = false; pullOn = false; gui:Destroy()
end)

-- Footer
local ft = Instance.new("TextLabel")
ft.Size = UDim2.new(1, 0, 0, 16)
ft.Position = UDim2.new(0, 0, 1, -16)
ft.BackgroundTransparency = 1
ft.Text = "snqw .0gh on discord"
ft.TextColor3 = Color3.fromRGB(80, 80, 80)
ft.TextSize = 11
ft.Font = Enum.Font.Gotham
ft.Parent = bg

-- Animate
bg.Position = UDim2.new(0.5, -170, 0.55, -180)
TS:Create(bg, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -170, 0.5, -180)}):Play()

print("snqw loaded")
