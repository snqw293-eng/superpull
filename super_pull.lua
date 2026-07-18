-- snqw .0gh — Speed Demon + Pull Assist
-- No hooks needed, works in any runner

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()

local speed = 10
local boost = 1000
local on = true

-- 40Hz
pcall(function()
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end)

-- Pull assist: track mouse position changes while dragging
local lastMouse = Vector2.new()
local dragPower = 0

mouse.Move:Connect(function()
    if on and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local cur = Vector2.new(mouse.X, mouse.Y)
        if lastMouse.Magnitude > 0 then
            local d = (cur - lastMouse).Magnitude
            dragPower = math.min(dragPower + d * 0.5, 200)
        end
        lastMouse = cur
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        lastMouse = Vector2.new()
        dragPower = 0
    end
end)

RS.RenderStepped:Connect(function()
    if not on or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = plr.Character.HumanoidRootPart
    local dt = RS:GetSteppedDelta()
    
    -- Speed boost in look direction
    local dir = hrp.CFrame.LookVector * Vector3.new(1, 0, 1)
    if dir.Magnitude > 0 then
        hrp.Velocity = hrp.Velocity + dir * speed * 60 * dt
    end
    
    -- Pull assist burst
    if dragPower > 1 then
        hrp.Velocity = hrp.Velocity + hrp.CFrame.LookVector * dragPower * boost * dt
        dragPower = dragPower * 0.9
    end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "Snqw"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 280, 0, 200)
f.Position = UDim2.new(0.5, -140, 0.5, -100)
f.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
f.BackgroundTransparency = 0.1
f.BorderSizePixel = 2
f.BorderColor3 = Color3.fromRGB(200, 0, 0)
f.Active = true
f.Draggable = true
f.Parent = gui
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

local h = Instance.new("TextLabel", f)
h.Size = UDim2.new(1, 0, 0, 38)
h.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
h.Text = "SNQW .0GH"
h.TextColor3 = Color3.fromRGB(255, 40, 40)
h.TextScaled = true
h.Font = Enum.Font.FredokaOne
Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

local s = Instance.new("TextLabel", f)
s.Size = UDim2.new(1, -20, 0, 16)
s.Position = UDim2.new(0, 10, 0, 40)
s.BackgroundTransparency = 1
s.Text = "Speed: " .. speed .. "x | Boost: " .. boost
s.TextColor3 = Color3.fromRGB(180, 180, 180)
s.TextScaled = true
s.Font = Enum.Font.Gotham
s.TextXAlignment = Enum.TextXAlignment.Left

function btn(y, txt, col, cb)
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0.85, 0, 0, 30)
    b.Position = UDim2.new(0.075, 0, 0, y)
    b.BackgroundColor3 = col
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(cb)
end

btn(62, "Toggle: " .. (on and "ON" or "OFF"), Color3.fromRGB(30, 30, 140), function()
    on = not on; s.Text = "Speed: " .. speed .. "x | Boost: " .. boost
end)
btn(98, "Speed +", Color3.fromRGB(30, 120, 30), function()
    speed = speed + 5; s.Text = "Speed: " .. speed .. "x | Boost: " .. boost
end)
btn(98, "Boost +", Color3.fromRGB(120, 30, 30), function()
    boost = boost + 500; s.Text = "Speed: " .. speed .. "x | Boost: " .. boost
end)
btn(134, "MAX ALL", Color3.fromRGB(180, 0, 0), function()
    speed = 50; boost = 10000; on = true; s.Text = "Speed: " .. speed .. "x | Boost: " .. boost
end)
btn(134, "Quit", Color3.fromRGB(60, 60, 60), function()
    on = false; gui:Destroy()
end)

local ft = Instance.new("TextLabel", f)
ft.Size = UDim2.new(1, 0, 0, 16)
ft.Position = UDim2.new(0, 0, 1, -16)
ft.BackgroundTransparency = 1
ft.Text = "snqw .0gh on discord"
ft.TextColor3 = Color3.fromRGB(80, 80, 80)
ft.TextScaled = true
ft.Font = Enum.Font.Gotham
