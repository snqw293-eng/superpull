-- snqw is king and top 1 — Super Pull GUI
-- Load in modded lobby's script runner

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TPS = game:GetService("TeleportService")
local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()

-- ── toggle state ──────────────────────────────────────────
local pullOn = true
local hzOn = true
local mult = 100
local dragging = false
local ACC = Vector2.new()

-- ── build GUI ─────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "SnqwGui"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local bg = Instance.new("ImageLabel")
bg.Size = UDim2.new(0, 320, 0, 280)
bg.Position = UDim2.new(0.5, -160, 0.5, -140)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
bg.BackgroundTransparency = 0.15
bg.BorderSizePixel = 2
bg.BorderColor3 = Color3.fromRGB(255, 50, 50)
bg.Active = true
bg.Draggable = true
bg.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 8)
title.BackgroundTransparency = 1
title.Text = "snqw is king and top 1"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.Parent = bg

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 48)
status.BackgroundTransparency = 1
status.Text = "Pull: " .. mult .. "x | 40Hz: ON"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextScaled = true
status.Font = Enum.Font.Gotham
status.Parent = bg

function btn(txt, y, color, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.85, 0, 0, 32)
    b.Position = UDim2.new(0.075, 0, 0, y)
    b.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = bg
    b.MouseButton1Click:Connect(cb)
    return b
end

local y = 75
btn("Test Pull", y, Color3.fromRGB(30, 120, 30), function()
    mult = mult * 2
    status.Text = "Pull: " .. mult .. "x | 40Hz: " .. (hzOn and "ON" or "OFF")
end)
y = y + 38

btn("Work (toggle pull)", y, Color3.fromRGB(30, 30, 120), function()
    pullOn = not pullOn
    status.Text = "Pull: " .. (pullOn and mult .. "x" or "OFF") .. " | 40Hz: " .. (hzOn and "ON" or "OFF")
end)
y = y + 38

btn("Adjust (cycle mult)", y, Color3.fromRGB(120, 30, 30), function()
    local mults = {50, 100, 200, 500, 1000}
    for i, v in ipairs(mults) do
        if mult == v then
            mult = mults[i % #mults + 1]
            break
        end
    end
    status.Text = "Pull: " .. mult .. "x | 40Hz: " .. (hzOn and "ON" or "OFF")
end)
y = y + 38

btn("40Hz toggle", y, Color3.fromRGB(120, 120, 30), function()
    hzOn = not hzOn
    status.Text = "Pull: " .. (pullOn and mult .. "x" or "OFF") .. " | 40Hz: " .. (hzOn and "ON" or "OFF")
end)
y = y + 38

btn("Copy loadstring", y, Color3.fromRGB(60, 60, 60), function()
    if setclipboard then
        setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/snqw293-eng/superpull/main/super_pull.lua"))()')
    end
end)

-- ── 40Hz loop ─────────────────────────────────────────────
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
pcall(setfpscap, 40)

local hzBinding
hzBinding = RS:BindToRenderStep("Hz40", Enum.RenderPriority.Input.Value, function()
    if not hzOn and hzBinding then
        hzBinding:Disconnect()
    end
end)

-- ── pull hook ─────────────────────────────────────────────
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = function(...)
    local args = {...}
    local self = args[1]
    local method = getnamecallmethod()
    if pullOn and method == "GetMouseDelta" and self == UIS then
        local v = old(...)
        return v * mult
    end
    return old(...)
end
setreadonly(mt, true)

print("snqw is king and top 1 — loaded")
