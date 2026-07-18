local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()
local WS = workspace

local pullMult = 1000
local speedMult = 10
local hertz = 120
local pullOn = true
local speedOn = true
local hzOn = true
local predOn = false
local predInt = 10
local useCFrame = true
local clickTP = false
local slideMult = 50
local hookOK = false
local hookMethod = "none"
local sliding = false
local slideTarget = Vector3.new()
local clickPos = Vector2.new()
local lastClickTime = 0
local dragDir = Vector3.new()
local dragStr = 0
local held = false
local lastPos = Vector2.new()
local foundMove = false
local moveInfo = {}
local bodyForce = nil

function studyChar(c)
    moveInfo = {}
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    if h then
        for _, v in ipairs(h:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyPosition") or v:IsA("BodyGyro") or v:IsA("VectorForce") then
                table.insert(moveInfo, v.ClassName); foundMove = v
            end
        end
    end
    if c:FindFirstChildWhichIsA("Humanoid") then table.insert(moveInfo, "Humanoid") end
    if #moveInfo == 0 then table.insert(moveInfo, "CustomPhysics") end
end
plr.CharacterAdded:Connect(studyChar)
if plr.Character then studyChar(plr.Character) end

UIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        held = true; clickPos = Vector2.new(mouse.X, mouse.Y); lastPos = clickPos; dragStr = 0; sliding = false
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    held = false; dragStr = 0
    if clickTP and (Vector2.new(mouse.X, mouse.Y) - clickPos).Magnitude < 10 then
        local n = time()
        local p = mouse.Hit
        if p then
            if n - lastClickTime < 0.4 then
                local h = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if h then h.CFrame = CFrame.new(p.p + Vector3.new(0, 3, 0)) end
            else sliding = true; slideTarget = p.p end
            lastClickTime = n
        end
    end
end)
mouse.Move:Connect(function()
    if not held then return end
    local cur = Vector2.new(mouse.X, mouse.Y)
    if lastPos.Magnitude > 0 then
        local d = cur - lastPos
        dragStr = math.min(dragStr + d.Magnitude * 0.1, 500)
        dragDir = Vector3.new(-d.X, 0, -d.Y).Unit
    end
    lastPos = cur
end)

function doHook()
    hookOK = false; hookMethod = "none"
    pcall(function()
        local mt = getrawmetatable(game)
        local o = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = function(...)
            local a = {...}
            if pullOn and getnamecallmethod() == "GetMouseDelta" and a[1] == UIS then
                hookOK = true; hookMethod = "namecall"
                return o(...) * pullMult
            end
            return o(...)
        end
        setreadonly(mt, true)
    end)
    if hookOK then return end
    pcall(function()
        local o = UIS.GetMouseDelta
        if hookfunction then
            hookfunction(o, function(s)
                if pullOn then hookOK = true; hookMethod = "hookfunction"; return o(s) * pullMult end
                return o(s)
            end)
        end
    end)
    if hookOK then return end
    pcall(function()
        local mt = getrawmetatable(game)
        local o = mt.__index
        setreadonly(mt, false)
        mt.__index = function(t, k)
            if t == UIS and k == "GetMouseDelta" then hookOK = true; hookMethod = "__index" end
            return o(t, k)
        end
        setreadonly(mt, true)
    end)
end
doHook()
task.spawn(function() while task.wait(5) do if not hookOK then doHook() end end end)

local vimOK = pcall(function() VIM:SendMouseMoveEvent(0, 0, false); return true end)

function attachForce()
    if not plr.Character then return end
    local h = plr.Character:FindFirstChild("HumanoidRootPart")
    if not h then return end
    if bodyForce and bodyForce.Parent then bodyForce:Destroy() end
    bodyForce = Instance.new("VectorForce")
    bodyForce.Name = "SnqwForce"
    bodyForce.Force = Vector3.new(0, 0, 0)
    bodyForce.Attachment0 = h:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", h)
    bodyForce.Parent = h
end
plr.CharacterAdded:Connect(attachForce)
if plr.Character then attachForce() end

local pointer = Instance.new("Part")
pointer.Size = Vector3.new(1.2, 1.2, 1.2)
pointer.Shape = Enum.PartType.Ball
pointer.Color = Color3.fromRGB(200, 200, 200)
pointer.Material = Enum.Material.Neon
pointer.Transparency = 0.35
pointer.Anchored = true
pointer.CanCollide = false
pointer.Visible = false
pointer.Parent = WS

RS.RenderStepped:Connect(function()
    if not plr.Character then return end
    local h = plr.Character:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local dt = RS:GetSteppedDelta()
    local d = h.CFrame.LookVector * Vector3.new(1, 0, 1)
    if speedOn and d.Magnitude > 0 then h.Velocity = h.Velocity + d * speedMult * 200 * dt end
    if predOn and d.Magnitude > 0 then h.Velocity = h.Velocity + d * predInt * 100 * dt end
    if pullOn and held and dragStr > 1 then
        local a = dragStr * pullMult * dt
        if useCFrame then h.CFrame = h.CFrame + dragDir * a * 5 end
        h.Velocity = h.Velocity + dragDir * a * 40
        if vimOK then VIM:SendMouseMoveEvent(dragStr * pullMult * 0.1, 0, false) end
        if bodyForce and bodyForce.Parent then bodyForce.Force = dragDir * dragStr * pullMult * 50 end
    end
    if sliding and clickTP then
        local t = slideTarget - h.Position; t = Vector3.new(t.X, 0, t.Z)
        if t.Magnitude > 2 then
            local m = t.Unit * math.min(t.Magnitude, slideMult * 100 * dt)
            h.CFrame = h.CFrame + m; h.Velocity = t.Unit * slideMult * 200
        else sliding = false end
    end
    if pointer and clickTP and mouse.Hit then pointer.CFrame = CFrame.new(mouse.Hit.p); pointer.Visible = true
    elseif pointer then pointer.Visible = false end
end)

pcall(function() settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled end)
local hzBind
function upHz()
    if hzBind then hzBind:Disconnect() end
    if hzOn then pcall(setfpscap, hertz); hzBind = RS:BindToRenderStep("Hz", Enum.RenderPriority.Input.Value, function() end) end
end
upHz()

-- UI
local gui = Instance.new("ScreenGui"); gui.Name = "Snqw"; gui.ResetOnSpawn = false; gui.Parent = plr:WaitForChild("PlayerGui")
local bg = Instance.new("Frame"); bg.Size = UDim2.new(0, 560, 0, 420); bg.Position = UDim2.new(0.5, -280, 0.5, -210); bg.BackgroundColor3 = Color3.fromRGB(10,10,10); bg.BorderSizePixel = 0; bg.Active = true; bg.Draggable = true; bg.Parent = gui
local c = Instance.new("UICorner", bg); c.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", bg); title.Size = UDim2.new(1, 0, 0, 40); title.BackgroundColor3 = Color3.fromRGB(15,15,15); title.BorderSizePixel = 0; title.Text = "SNQW .0GH"; title.TextColor3 = Color3.fromRGB(200,200,200); title.TextSize = 18; title.Font = Enum.Font.GothamBold
local tc = Instance.new("UICorner", title); tc.CornerRadius = UDim.new(0, 8)

local st = Instance.new("TextLabel", bg); st.Size = UDim2.new(1, -16, 0, 22); st.Position = UDim2.new(0, 8, 0, 40); st.BackgroundTransparency = 1; st.Text = ""; st.TextColor3 = Color3.fromRGB(0,200,0); st.TextSize = 10; st.Font = Enum.Font.GothamBold; st.TextXAlignment = Enum.TextXAlignment.Left

function upSt()
    local m = #moveInfo > 0 and table.concat(moveInfo, ",") or "?"
    st.Text = "H:" .. hookMethod .. " P:" .. pullMult .. "x S:" .. speedMult .. "x " .. hertz .. "Hz TP:" .. (clickTP and "ON" or "OFF") .. "  " .. m
end

local side = Instance.new("Frame", bg); side.Size = UDim2.new(0, 150, 1, -66); side.Position = UDim2.new(0, 6, 0, 64); side.BackgroundColor3 = Color3.fromRGB(14,14,14); side.BorderSizePixel = 0
Instance.new("UICorner", side).CornerRadius = UDim.new(0, 6)

local contBg = Instance.new("Frame", bg); contBg.Size = UDim2.new(1, -170, 1, -78); contBg.Position = UDim2.new(0, 164, 0, 72); contBg.BackgroundColor3 = Color3.fromRGB(12,12,12); contBg.BorderSizePixel = 0
Instance.new("UICorner", contBg).CornerRadius = UDim.new(0, 6)

Instance.new("UIListLayout", side).Padding = UDim.new(0, 3); side.LayoutOrder = 1

local tabBtns = {}; local contents = {}
local tabs = {"PULL","SPEED","HZ","SCAN"}
for i, n in ipairs(tabs) do
    local b = Instance.new("TextButton", side); b.Size = UDim2.new(1, -6, 0, 32); b.BackgroundColor3 = i == 1 and Color3.fromRGB(25,25,25) or Color3.fromRGB(15,15,15); b.BorderSizePixel = 0; b.Text = n; b.TextColor3 = i == 1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,130,130); b.TextSize = 13; b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(function()
        for j, v in ipairs(tabBtns) do
            v.BackgroundColor3 = j == i and Color3.fromRGB(25,25,25) or Color3.fromRGB(15,15,15)
            v.TextColor3 = j == i and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,130,130)
        end
        for j, v in ipairs(contents) do v.Visible = j == i end
    end)
    tabBtns[i] = b
    local f = Instance.new("ScrollingFrame", contBg); f.Size = UDim2.new(1, -10, 1, -8); f.Position = UDim2.new(0, 5, 0, 4); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ScrollBarThickness = 2; f.CanvasSize = UDim2.new(0, 0, 0, 0); f.Visible = i == 1
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 3)
    contents[i] = f
end

function btn(con, txt, cb)
    local b = Instance.new("TextButton", con); b.Size = UDim2.new(1, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(20,20,20); b.BorderSizePixel = 0; b.Text = txt; b.TextColor3 = Color3.fromRGB(200,200,200); b.TextSize = 13; b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(cb)
    return b
end

function tog(con, txt, get, set)
    local b = Instance.new("TextButton", con); b.Size = UDim2.new(1, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(20,20,20); b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    local l = Instance.new("TextLabel", b); l.Size = UDim2.new(1, -50, 1, 0); l.Position = UDim2.new(0, 10, 0, 0); l.BackgroundTransparency = 1; l.Text = txt; l.TextColor3 = Color3.fromRGB(200,200,200); l.TextSize = 13; l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
    local tb = Instance.new("Frame", b); tb.Size = UDim2.new(0, 32, 0, 18); tb.Position = UDim2.new(1, -40, 0.5, -9); tb.BackgroundColor3 = get() and Color3.fromRGB(70,120,70) or Color3.fromRGB(35,35,35); tb.BorderSizePixel = 0
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 9)
    local td = Instance.new("Frame", tb); td.Size = UDim2.new(0, 14, 0, 14); td.Position = get() and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); td.BackgroundColor3 = Color3.fromRGB(255,255,255); td.BorderSizePixel = 0
    Instance.new("UICorner", td).CornerRadius = UDim.new(0, 7)
    b.MouseButton1Click:Connect(function()
        set(not get())
        tb.BackgroundColor3 = get() and Color3.fromRGB(70,120,70) or Color3.fromRGB(35,35,35)
        td:TweenPosition(get() and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.12, true)
    end)
    return b
end

tog(contents[1], "Pull", function() return pullOn end, function(v) pullOn = v; upSt() end).Parent = contents[1]
btn(contents[1], "Pull x" .. pullMult .. " (x10)", function() pullMult = pullMult * 10; upSt() end).Parent = contents[1]
btn(contents[1], "Pull /10", function() pullMult = math.max(1, pullMult / 10); upSt() end).Parent = contents[1]
tog(contents[1], "CF Mode", function() return useCFrame end, function(v) useCFrame = v; upSt() end).Parent = contents[1]
btn(contents[1], "Inject Hook", function() doHook(); upSt() end).Parent = contents[1]
btn(contents[1], "Reattach Force", attachForce).Parent = contents[1]
tog(contents[1], "Click TP", function() return clickTP end, function(v) clickTP = v; if not v then sliding = false; pointer.Visible = false end; upSt() end).Parent = contents[1]
btn(contents[1], "Slide x" .. slideMult .. " (x2)", function() slideMult = slideMult * 2; upSt() end).Parent = contents[1]

tog(contents[2], "Speed", function() return speedOn end, function(v) speedOn = v; upSt() end).Parent = contents[2]
btn(contents[2], "Speed x2", function() speedMult = speedMult * 2; upSt() end).Parent = contents[2]
btn(contents[2], "Speed /2", function() speedMult = math.max(1, speedMult / 2); upSt() end).Parent = contents[2]
tog(contents[2], "Prediction", function() return predOn end, function(v) predOn = v; upSt() end).Parent = contents[2]
btn(contents[2], "Pred x" .. predInt .. " (x2)", function() predInt = predInt * 2; upSt() end).Parent = contents[2]

local hb = Instance.new("TextBox"); hb.Size = UDim2.new(1, 0, 0, 34); hb.BackgroundColor3 = Color3.fromRGB(20,20,20); hb.BorderSizePixel = 0; hb.PlaceholderText = "Hz..."; hb.Text = tostring(hertz); hb.TextColor3 = Color3.fromRGB(200,200,200); hb.TextSize = 16; hb.Font = Enum.Font.GothamBold; hb.ClearTextOnFocus = false; hb.Parent = contents[3]
Instance.new("UICorner", hb).CornerRadius = UDim.new(0, 5)
btn(contents[3], "Set Hz", function()
    local n = tonumber(hb.Text)
    if n and n > 0 then hertz = n; hzOn = true; upHz(); upSt() end
end).Parent = contents[3]
tog(contents[3], "Hz On", function() return hzOn end, function(v) hzOn = v; upHz() end).Parent = contents[3]
btn(contents[3], "Copy Loader", function() if setclipboard then setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/snqw293-eng/superpull/main/super_pull.lua"))()') end end).Parent = contents[3]
btn(contents[3], "Quit", function() speedOn = false; pullOn = false; hzOn = false; gui:Destroy() end).Parent = contents[3]

btn(contents[4], "Rescan", function() if plr.Character then studyChar(plr.Character); upSt() end end).Parent = contents[4]
btn(contents[4], "Scan GC", function()
    pcall(function()
        for _, v in ipairs(getgc()) do
            if type(v) == "function" then
                for _, c in ipairs({ getconstants(v) }) do
                    if type(c) == "string" and (c:lower():find("delta") or c:find("Mouse")) then
                        st.Text = "Found: " .. tostring(getinfo(v).source):sub(1, 40); return
                    end
                end
            end
        end
    end)
end).Parent = contents[4]
btn(contents[4], "Test VIM", function() st.Text = "VIM: " .. (vimOK and "OK" or "NO") end).Parent = contents[4]
btn(contents[4], "Body: " .. (#moveInfo > 0 and table.concat(moveInfo, ",") or "?"), function() upSt() end).Parent = contents[4]

local ft = Instance.new("TextLabel", bg); ft.Size = UDim2.new(1, 0, 0, 18); ft.Position = UDim2.new(0, 6, 1, -20); ft.BackgroundTransparency = 1; ft.Text = "snqw .0gh on discord"; ft.TextColor3 = Color3.fromRGB(70,70,70); ft.TextSize = 10; ft.Font = Enum.Font.Gotham

upSt()
bg.Position = UDim2.new(0.5, -280, 0.55, -210)
TS:Create(bg, TweenInfo.new(0.35), {Position = UDim2.new(0.5, -280, 0.5, -210)}):Play()

print("snqw loaded")
