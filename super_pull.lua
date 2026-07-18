-- snqw .0gh — Super Pull + Speed + 40Hz
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local plr = game:GetService("Players").LocalPlayer

local pullMult = 100
local speedMult = 3
local hzOn = true
local pullOn = true
local speedOn = true

-- 40Hz
pcall(function()
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
    pcall(setfpscap, 40)
end)

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

-- Pull hook (wrapped in pcall in case runner doesn't support getrawmetatable)
local hookSuccess = pcall(function()
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
end)

-- GUI (build regardless of hook success)
local gui = Instance.new("ScreenGui")
gui.Name = "SnqwHub"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local bg = Instance.new("ImageLabel")
bg.Size = UDim2.new(0, 340, 0, 350)
bg.Position = UDim2.new(0.5, -170, 0.5, -175)
bg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
bg.BackgroundTransparency = 0.1
bg.BorderSizePixel = 2
bg.BorderColor3 = Color3.fromRGB(180, 0, 0)
bg.Active = true
bg.Draggable = true
bg.Parent = gui
local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(0, 8); bgc.Parent = bg

-- Header
local hdr = Instance.new("TextLabel")
hdr.Size = UDim2.new(1, 0, 0, 42)
hdr.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
hdr.BorderSizePixel = 0
hdr.Text = "SNQW .0GH"
hdr.TextColor3 = Color3.fromRGB(255, 40, 40)
hdr.TextScaled = true
hdr.Font = Enum.Font.FredokaOne
hdr.Parent = bg
local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0, 8); hc.Parent = hdr

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 14)
sub.Position = UDim2.new(0, 0, 1, 0)
sub.BackgroundTransparency = 1
sub.Text = "king and top 1"
sub.TextColor3 = Color3.fromRGB(160, 160, 160)
sub.TextScaled = true
sub.Font = Enum.Font.Gotham
sub.Parent = hdr

-- Hook status
local st = Instance.new("TextLabel")
st.Size = UDim2.new(1, -20, 0, 16)
st.Position = UDim2.new(0, 10, 0, 46)
st.BackgroundTransparency = 1
st.Text = "Pull Hook: " .. (hookSuccess and "OK" or "FAIL (pull won't work)") .. " | Speed: ON"
st.TextColor3 = Color3.fromRGB(180, 180, 180)
st.TextScaled = true
st.Font = Enum.Font.Gotham
st.TextXAlignment = Enum.TextXAlignment.Left
st.Parent = bg

function stxt(t)
    st.Text = t
end

-- Buttons
local y = 70
function mk(txt, col, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.85, 0, 0, 32)
    b.Position = UDim2.new(0.075, 0, 0, y)
    b.BackgroundColor3 = col or Color3.fromRGB(25, 25, 25)
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = bg
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = b
    b.MouseButton1Click:Connect(cb)
    y = y + 38
end

mk("Toggle Pull [" .. (pullOn and "ON" or "OFF") .. "]", Color3.fromRGB(30, 30, 140), function()
    pullOn = not pullOn; stxt("Pull: " .. (pullOn and pullMult .. "x" or "OFF") .. " | Speed: ON")
end)
mk("Pull: " .. pullMult .. "x (+50)", Color3.fromRGB(20, 20, 100), function()
    pullMult = pullMult + 50; stxt("Pull: " .. pullMult .. "x | Speed: ON")
end)
mk("Toggle Speed [" .. (speedOn and "ON" or "OFF") .. "]", Color3.fromRGB(30, 120, 30), function()
    speedOn = not speedOn; stxt("Pull: " .. pullMult .. "x | Speed: " .. (speedOn and "ON" or "OFF"))
end)
mk("Speed: " .. speedMult .. "x (+1)", Color3.fromRGB(20, 80, 20), function()
    speedMult = speedMult + 1; stxt("Pull: " .. pullMult .. "x | Speed: " .. speedMult .. "x")
end)
mk("MAX MODE (500x pull / 20x speed)", Color3.fromRGB(180, 0, 0), function()
    pullMult = 500; speedMult = 20; pullOn = true; speedOn = true; stxt("MAX: Pull 500x / Speed 20x")
end)
mk("Quit", Color3.fromRGB(100, 0, 0), function()
    pullOn = false; speedOn = false; gui:Destroy()
end)

-- Footer
local ft = Instance.new("TextLabel")
ft.Size = UDim2.new(1, 0, 0, 18)
ft.Position = UDim2.new(0, 0, 1, -18)
ft.BackgroundTransparency = 1
ft.Text = "snqw .0gh on discord"
ft.TextColor3 = Color3.fromRGB(80, 80, 80)
ft.TextScaled = true
ft.Font = Enum.Font.Gotham
ft.Parent = bg

print("snqw .0gh loaded | Hook: " .. (hookSuccess and "OK" or "FAIL"))
