local plr = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TestGUI"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 300, 0, 200)
f.Position = UDim2.new(0.5, -150, 0.5, -100)
f.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
f.BorderSizePixel = 2
f.BorderColor3 = Color3.fromRGB(255, 0, 0)
f.Active = true
f.Draggable = true
f.Parent = gui

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 40)
t.BackgroundTransparency = 1
t.Text = "SNQW .0GH"
t.TextColor3 = Color3.fromRGB(255, 50, 50)
t.TextScaled = true
t.Font = Enum.Font.FredokaOne
t.Parent = f

local b = Instance.new("TextButton")
b.Size = UDim2.new(0.8, 0, 0, 36)
b.Position = UDim2.new(0.1, 0, 0, 50)
b.BackgroundColor3 = Color3.fromRGB(30, 30, 140)
b.BorderSizePixel = 0
b.Text = "Toggle Pull (100x)"
b.TextColor3 = Color3.fromRGB(255, 255, 255)
b.TextScaled = true
b.Font = Enum.Font.GothamBold
b.Parent = f

local b2 = Instance.new("TextButton")
b2.Size = UDim2.new(0.8, 0, 0, 36)
b2.Position = UDim2.new(0.1, 0, 0, 94)
b2.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
b2.BorderSizePixel = 0
b2.Text = "Toggle Speed"
b2.TextColor3 = Color3.fromRGB(255, 255, 255)
b2.TextScaled = true
b2.Font = Enum.Font.GothamBold
b2.Parent = f

local b3 = Instance.new("TextButton")
b3.Size = UDim2.new(0.8, 0, 0, 36)
b3.Position = UDim2.new(0.1, 0, 0, 138)
b3.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
b3.BorderSizePixel = 0
b3.Text = "Quit"
b3.TextColor3 = Color3.fromRGB(255, 255, 255)
b3.TextScaled = true
b3.Font = Enum.Font.GothamBold
b3.Parent = f

local pullOn = true
local speedOn = true
local pullMult = 100
local speedMult = 3

b.MouseButton1Click:Connect(function()
    pullOn = not pullOn
    b.Text = pullOn and "Pull ON (" .. pullMult .. "x)" or "Pull OFF"
end)

b2.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    b2.Text = speedOn and "Speed ON (" .. speedMult .. "x)" or "Speed OFF"
end)

b3.MouseButton1Click:Connect(function()
    gui:Destroy()
    pullOn = false
    speedOn = false
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if speedOn and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        local dir = hrp.CFrame.LookVector * Vector3.new(1, 0, 1)
        if dir.Magnitude > 0 then
            hrp.Velocity = hrp.Velocity + dir * speedMult * 50 * game:GetService("RunService"):GetSteppedDelta()
        end
    end
end)

-- Try hook if supported
pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(...)
        local a = {...}
        if pullOn and getnamecallmethod() == "GetMouseDelta" and a[1] == game:GetService("UserInputService") then
            return old(...) * pullMult
        end
        return old(...)
    end
    setreadonly(mt, true)
end)

local ft = Instance.new("TextLabel")
ft.Size = UDim2.new(1, 0, 0, 18)
ft.Position = UDim2.new(0, 0, 1, -18)
ft.BackgroundTransparency = 1
ft.Text = "snqw .0gh on discord"
ft.TextColor3 = Color3.fromRGB(100, 100, 100)
ft.TextScaled = true
ft.Font = Enum.Font.Gotham
ft.Parent = f
