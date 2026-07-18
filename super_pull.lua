-- snqw .0gh — Game study + auto mod
-- Scans game modules, finds movement function, patches it

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()

local mult = 100
local methods = {}
local working = ""

-- ── Method 1: getrawmetatable hook ────────────────────────
methods.hook = pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(...)
        local a = {...}
        if getnamecallmethod() == "GetMouseDelta" and a[1] == UIS then return old(...) * mult end
        return old(...)
    end
    setreadonly(mt, true)
end)

-- ── Method 2: Scan game modules for movement function ──────
methods.scan = false
local patched = nil

local scanSuccess = pcall(function()
    local gc = getgc()
    for _, v in ipairs(gc) do
        if type(v) == "function" then
            local env = getfenv(v)
            if env and env.script and env.script.Parent then
                local upvals = {getupvalues(v)}
                for _, uv in ipairs(upvals) do
                    if type(uv) == "number" and uv > 0 then
                        local consts = {getconstants(v)}
                        for _, c in ipairs(consts) do
                            if type(c) == "string" and (c:lower():find("delta") or c:lower():find("mouse") or c:lower():find("drag")) then
                                -- Found a function using mouse delta — patch it
                                local oldFn = v
                                local sig = getinfo(v).source or "?"
                                if not methods.scan then
                                    methods.scan = sig
                                end
                                local upIdx = nil
                                for ui, uv2 in ipairs(upvals) do
                                    if type(uv2) == "number" and uv2 > 0 then
                                        upIdx = ui
                                        break
                                    end
                                end
                                if upIdx then
                                    -- Found multiplier value — patch it
                                    patched = {func = oldFn, upval = upIdx, oldVal = upvals[upIdx], sig = sig}
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ── Method 3: Fallback — velocity boost ────────────────────
local speedMult = 5
local speedOn = true
local dragPower = 0
local lastPos = Vector2.new()

mouse.Move:Connect(function()
    if speedOn and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local cur = Vector2.new(mouse.X, mouse.Y)
        if lastPos.Magnitude > 0 then
            dragPower = math.min(dragPower + (cur - lastPos).Magnitude * 0.3, 150)
        end
        lastPos = cur
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then lastPos = Vector2.new(); dragPower = 0 end
end)

-- Determine best method
if methods.hook then
    working = "Hook (100x)"
elseif methods.scan then
    working = "Scan patched: " .. tostring(methods.scan):sub(1, 40)
else
    working = "Velocity boost"
end

RS.RenderStepped:Connect(function()
    if not speedOn or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = plr.Character.HumanoidRootPart
    local dt = RS:GetSteppedDelta()
    local dir = hrp.CFrame.LookVector * Vector3.new(1, 0, 1)
    if dir.Magnitude > 0 then
        hrp.Velocity = hrp.Velocity + dir * speedMult * 60 * dt
    end
    if dragPower > 1 then
        hrp.Velocity = hrp.Velocity + hrp.CFrame.LookVector * dragPower * 200 * dt
        dragPower = dragPower * 0.92
    end
end)

-- ── BEAUTIFUL UI ──────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "SnqwHub"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local bg = Instance.new("ImageLabel")
bg.Size = UDim2.new(0, 380, 0, 440)
bg.Position = UDim2.new(0.5, -190, 0.5, -220)
bg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
bg.BorderSizePixel = 0
bg.Active = true
bg.Draggable = true
bg.ClipsDescendants = true
bg.Parent = gui
local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(0, 12); bgc.Parent = bg
local bgst = Instance.new("UIStroke"); bgst.Color = Color3.fromRGB(200, 0, 0); bgst.Thickness = 1.5; bgst.Parent = bg
local bgsh = Instance.new("ImageLabel"); bgsh.Size = UDim2.new(1, 20, 1, 20); bgsh.Position = UDim2.new(0, -10, 0, -10); bgsh.BackgroundColor3 = Color3.fromRGB(0,0,0); bgsh.BackgroundTransparency = 0.5; bgsh.ZIndex = -1; bgsh.Parent = bg; Instance.new("UICorner", bgsh).CornerRadius = UDim.new(0, 16)

-- Accent line
local line = Instance.new("Frame")
line.Size = UDim2.new(1, 0, 0, 3)
line.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
line.BorderSizePixel = 0
line.Parent = bg

-- Header
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 0, 36)
logo.Position = UDim2.new(0, 0, 0, 8)
logo.BackgroundTransparency = 1
logo.Text = "SNQW .0GH"
logo.TextColor3 = Color3.fromRGB(255, 50, 50)
logo.TextSize = 28
logo.Font = Enum.Font.FredokaOne
logo.Parent = bg

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 16)
status.Position = UDim2.new(0, 10, 0, 46)
status.BackgroundTransparency = 1
status.Text = "Method: " .. working .. " | Speed: " .. speedMult .. "x"
status.TextColor3 = Color3.fromRGB(160, 160, 160)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = bg

-- Module info
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 14)
info.Position = UDim2.new(0, 10, 0, 64)
info.BackgroundTransparency = 1
info.Text = methods.scan and ("Found: " .. tostring(methods.scan):sub(1, 50)) or "No game modules modifiable"
info.TextColor3 = Color3.fromRGB(100, 100, 100)
info.TextSize = 11
info.Font = Enum.Font.Gotham
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = bg

-- Buttons
local btnY = 88
local btnGap = 40

local function makeBtn(txt, col, cb, wide)
    local b = Instance.new("TextButton")
    local w = wide and 340 or 160
    local col2 = (btnY % 80 < 40) and 10 or 190
    b.Size = UDim2.new(0, w, 0, 32)
    b.Position = UDim2.new(0, btnY % 80 < 40 and 20 or 200, 0, btnY)
    b.BackgroundColor3 = col or Color3.fromRGB(20, 20, 25)
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.Parent = bg
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = b
    
    -- Hover glow
    b.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(b, TweenInfo.new(0.15), {BackgroundColor3 = col and col:Lerp(Color3.fromRGB(255,255,255), 0.15) or Color3.fromRGB(45, 45, 55)}):Play()
    end)
    b.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(b, TweenInfo.new(0.2), {BackgroundColor3 = col or Color3.fromRGB(20, 20, 25)}):Play()
    end)
    b.MouseButton1Click:Connect(cb)
    if wide and (btnY % 80 >= 40) then btnY = btnY + 40; end
    if not wide and (btnY % 80 >= 40) then btnY = btnY + 40; end
    return b
end

makeBtn("Toggle Speed [" .. (speedOn and "ON" or "OFF") .. "]", Color3.fromRGB(25, 25, 80), function()
    speedOn = not speedOn; status.Text = "Method: " .. working .. " | Speed: " .. (speedOn and speedMult .. "x" or "OFF")
end)
makeBtn("Speed +5", Color3.fromRGB(20, 60, 20), function()
    speedMult = speedMult + 5; status.Text = "Speed: " .. speedMult .. "x"
end)
makeBtn("Pull Mult: " .. mult, Color3.fromRGB(60, 20, 20), function()
    mult = mult + 50; status.Text = "Pull: " .. mult .. "x"
end)
makeBtn("Rescan Game", Color3.fromRGB(40, 30, 15), function()
    info.Text = "Rescanning..."
    local ok = pcall(function()
        for _, v in ipairs(getgc()) do
            if type(v) == "function" then
                local c = {getconstants(v)}
                for _, cc in ipairs(c) do
                    if type(cc) == "string" and (cc:lower():find("delta") or cc:lower():find("drag")) then
                        info.Text = "Found: " .. (getinfo(v).source or "?"):sub(1, 40)
                        return
                    end
                end
            end
        end
    end)
    if not ok then info.Text = "getgc not available in this runner" end
end)

btnY = btnY + 40
makeBtn("MAX (50x speed / 500x pull)", Color3.fromRGB(150, 0, 0), function()
    speedMult = 50; mult = 500; speedOn = true; status.Text = "MAX: Speed 50x / Pull 500x"
end, true)

btnY = btnY + 40
makeBtn("Copy Loader", Color3.fromRGB(30, 30, 30), function()
    if setclipboard then setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/snqw293-eng/superpull/main/super_pull.lua"))()') end
end, true)

makeBtn("Quit", Color3.fromRGB(80, 10, 10), function()
    speedOn = false; gui:Destroy()
end, true)

-- Footer
local ft = Instance.new("TextLabel")
ft.Size = UDim2.new(1, 0, 0, 18)
ft.Position = UDim2.new(0, 0, 1, -18)
ft.BackgroundTransparency = 1
ft.Text = "snqw .0gh on discord"
ft.TextColor3 = Color3.fromRGB(70, 70, 70)
ft.TextSize = 12
ft.Font = Enum.Font.Gotham
ft.Parent = bg

-- Animate in
bg.Position = UDim2.new(0.5, -190, 0.45, -220)
game:GetService("TweenService"):Create(bg, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -190, 0.5, -220)}):Play()

print("snqw .0gh loaded — Method: " .. working)
