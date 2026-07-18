-- snqw .0gh — multi-tab hub with animations
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TPS = game:GetService("TweenService")
local plr = game:GetService("Players").LocalPlayer

local pullMult = 100
local speedMult = 3
local hzOn = true
local pullOn = true
local speedOn = true
local curTab = 1

-- 40Hz
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
pcall(setfpscap, 40)

-- Speed boost
RS.RenderStepped:Connect(function()
    if speedOn and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        local dir = hrp.CFrame.LookVector * Vector3.new(1, 0, 1)
        if dir.Magnitude > 0 then
            hrp.Velocity = hrp.Velocity + dir * speedMult * 50 * RS:GetSteppedDelta()
        end
    end
end)

-- Pull hook
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

-- Animate in
local bg = Instance.new("ImageLabel")
bg.Size = UDim2.new(0, 360, 0, 420)
bg.Position = UDim2.new(0.5, -180, 0.6, -210)
bg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
bg.BackgroundTransparency = 0.12
bg.BorderSizePixel = 2
bg.BorderColor3 = Color3.fromRGB(180, 0, 0)
bg.Active = true
bg.Draggable = true
bg.ClipsDescendants = true
bg.Parent = gui

-- Corner
local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0, 8); cr.Parent = bg

-- Header
local hdr = Instance.new("ImageLabel")
hdr.Size = UDim2.new(1, 0, 0, 52)
hdr.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
hdr.BorderSizePixel = 0
hdr.Parent = bg
local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0, 8); hc.Parent = hdr

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "SNQW .0GH"
title.TextColor3 = Color3.fromRGB(255, 40, 40)
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.Parent = hdr

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 14)
sub.Position = UDim2.new(0, 0, 1, 0)
sub.BackgroundTransparency = 1
sub.Text = "king and top 1"
sub.TextColor3 = Color3.fromRGB(160, 160, 160)
sub.TextScaled = true
sub.Font = Enum.Font.Gotham
sub.Parent = hdr

-- Tabs
local tabBg = Instance.new("ImageLabel")
tabBg.Size = UDim2.new(1, -20, 0, 32)
tabBg.Position = UDim2.new(0, 10, 0, 56)
tabBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
tabBg.BorderSizePixel = 0
tabBg.Parent = bg
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 6); tc.Parent = tabBg

local tabs = {}
local tabNames = {"Pull", "Speed", "Settings"}

function switchTab(idx)
    curTab = idx
    for i, t in ipairs(tabs) do
        t.BackgroundColor3 = i == idx and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
    end
    for i, c in ipairs(contents) do
        c.Visible = i == idx
        if i == idx then
            TPS:Create(c, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.12}):Play()
        end
    end
end

for i, name in ipairs(tabNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.33, 0, 1, 0)
    b.Position = UDim2.new((i-1) * 0.33, 0, 0, 0)
    b.BackgroundColor3 = i == 1 and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
    b.BorderSizePixel = 0
    b.Text = name
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = tabBg
    b.MouseButton1Click:Connect(function() switchTab(i) end)
    tabs[i] = b
end

-- Content containers
local contents = {}
local statusTexts = {}

function makeContent(idx)
    local c = Instance.new("ImageLabel")
    c.Size = UDim2.new(1, -20, 1, -126)
    c.Position = UDim2.new(0, 10, 0, 94)
    c.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    c.BackgroundTransparency = 0.12
    c.BorderSizePixel = 0
    c.Visible = idx == 1
    c.Parent = bg
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 6); cc.Parent = c
    contents[idx] = c
    return c
end

function btn(txt, y, w, color, cb, parent)
    parent = parent or contents[curTab]
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w or 150, 0, 34)
    b.Position = UDim2.new(0, 10 + ((w or 150) + 10) * ((y % 100) > 50 and 1 or 0), 0, y)
    b.BackgroundColor3 = color or Color3.fromRGB(25, 25, 25)
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = parent
    local cr2 = Instance.new("UICorner"); cr2.CornerRadius = UDim.new(0, 4); cr2.Parent = b
    b.MouseEnter:Connect(function()
        TPS:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color and color:Lerp(Color3.fromRGB(255,255,255), 0.25) or Color3.fromRGB(55,55,55)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TPS:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color or Color3.fromRGB(25,25,25)}):Play()
    end)
    b.MouseButton1Click:Connect(cb)
    return b
end

function label(txt, y, parent)
    parent = parent or contents[curTab]
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 16)
    l.Position = UDim2.new(0, 10, 0, y)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(180, 180, 180)
    l.TextScaled = true
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

-- ── PULL TAB ──
local c1 = makeContent(1)
label("Pull: " .. pullMult .. "x", 6, c1)
btn("Toggle Pull", 24, 150, Color3.fromRGB(30, 30, 140), function()
    pullOn = not pullOn
    c1:FindFirstChild("TextLabel", true).Text = pullOn and "Pull: " .. pullMult .. "x" or "Pull: OFF"
end, c1)
btn("+50x", 24, 150, Color3.fromRGB(20, 20, 100), function()
    pullMult = pullMult + 50; c1:FindFirstChild("TextLabel", true).Text = "Pull: " .. pullMult .. "x"
end, c1)
btn("x2", 64, 150, Color3.fromRGB(40, 20, 80), function()
    pullMult = pullMult * 2; c1:FindFirstChild("TextLabel", true).Text = "Pull: " .. pullMult .. "x"
end, c1)
btn("Set 500x", 64, 150, Color3.fromRGB(60, 10, 10), function()
    pullMult = 500; c1:FindFirstChild("TextLabel", true).Text = "Pull: 500x"
end, c1)

-- ── SPEED TAB ──
local c2 = makeContent(2)
label("Speed: " .. speedMult .. "x", 6, c2)
btn("Toggle Speed", 24, 150, Color3.fromRGB(30, 120, 30), function()
    speedOn = not speedOn
    c2:FindFirstChild("TextLabel", true).Text = speedOn and "Speed: " .. speedMult .. "x" or "Speed: OFF"
end, c2)
btn("+1x", 24, 150, Color3.fromRGB(20, 80, 20), function()
    speedMult = speedMult + 1; c2:FindFirstChild("TextLabel", true).Text = "Speed: " .. speedMult .. "x"
end, c2)
btn("Double", 64, 150, Color3.fromRGB(40, 60, 20), function()
    speedMult = speedMult * 2; c2:FindFirstChild("TextLabel", true).Text = "Speed: " .. speedMult .. "x"
end, c2)
btn("MAX 20x", 64, 150, Color3.fromRGB(180, 0, 0), function()
    speedMult = 20; pullMult = 500; pullOn = true; speedOn = true
    c2:FindFirstChild("TextLabel", true).Text = "Speed: 20x"
end, c2)

-- ── SETTINGS TAB ──
local c3 = makeContent(3)
label("Settings", 6, c3)
btn("40Hz: ON", 24, 150, Color3.fromRGB(120, 30, 30), function()
    hzOn = not hzOn
end, c3)
btn("Reset All", 24, 150, Color3.fromRGB(80, 20, 20), function()
    pullMult = 100; speedMult = 3; pullOn = true; speedOn = true; hzOn = true
end, c3)
btn("Copy Loader", 64, 310, Color3.fromRGB(40, 40, 40), function()
    if setclipboard then
        setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/snqw293-eng/superpull/main/super_pull.lua"))()')
    end
end, c3)
btn("Quit", 104, 310, Color3.fromRGB(120, 0, 0), function()
    pullOn = false; speedOn = false; hzOn = false; gui:Destroy()
end, c3)

-- Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 18)
footer.Position = UDim2.new(0, 0, 1, -18)
footer.BackgroundTransparency = 1
footer.Text = "snqw .0gh on discord"
footer.TextColor3 = Color3.fromRGB(80, 80, 80)
footer.TextScaled = true
footer.Font = Enum.Font.Gotham
footer.Parent = bg

-- Animate entry
bg.Position = UDim2.new(0.5, -180, 0.4, -210)
TPS:Create(bg, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -180, 0.5, -210)}):Play()
bg.BackgroundTransparency = 1
TPS:Create(bg, TweenInfo.new(0.3), {BackgroundTransparency = 0.12}):Play()

print("snqw .0gh — loaded")
