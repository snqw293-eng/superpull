local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()
local WS = game:GetService("Workspace")

local pullMult = 1000
local speedMult = 10
local hertz = 120
local pullOn = true
local speedOn = true
local hzOn = true
local predOn = false
local predInt = 10
local curTab = 1
local foundMove = false
local useCFrame = true
local clickTP = false
local slideMult = 50
local moveInfo = {}
local clickPos = Vector2.new()
local lastClickTime = 0
local sliding = false
local slideTarget = Vector3.new()
local dblClickDelay = 0.4

-- Study character
function studyChar(char)
    moveInfo = {}
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, c in ipairs(hrp:GetChildren()) do
            if c:IsA("BodyVelocity") or c:IsA("BodyForce") or c:IsA("BodyPosition") or c:IsA("BodyGyro") or c:IsA("VectorForce") then
                table.insert(moveInfo, c.ClassName)
                foundMove = c
            end
        end
    end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then table.insert(moveInfo, "Humanoid") end
    if #moveInfo == 0 then table.insert(moveInfo, "CustomPhysics") end
end

plr.CharacterAdded:Connect(studyChar)
if plr.Character then studyChar(plr.Character) end

-- Mouse tracking
local lastPos = Vector2.new()
local dragDir = Vector3.new()
local dragStr = 0
local held = false

UIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        held = true; clickPos = Vector2.new(mouse.X, mouse.Y); lastPos = clickPos; dragStr = 0
        sliding = false
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        held = false; dragStr = 0
        if clickTP and (Vector2.new(mouse.X, mouse.Y) - clickPos).Magnitude < 10 then
            local now = time()
            local p = mouse.Hit
            if p then
                if now - lastClickTime < dblClickDelay then
                    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = CFrame.new(p.p + Vector3.new(0, 3, 0)) end
                else
                    sliding = true; slideTarget = p.p
                end
            end
            lastClickTime = now
        end
    end
end)

mouse.Move:Connect(function()
    if held then
        local cur = Vector2.new(mouse.X, mouse.Y)
        if lastPos.Magnitude > 0 then
            local d = cur - lastPos
            dragStr = math.min(dragStr + d.Magnitude * 0.1, 500)
            dragDir = Vector3.new(-d.X, 0, -d.Y).Unit
        end
        lastPos = cur
    end
end)

-- Hook
local hookOK = false
local hookMethod = "none"
local hookObj

function doHook()
    hookOK = false; hookMethod = "none"
    pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = function(...)
            local a = {...}
            if pullOn and getnamecallmethod() == "GetMouseDelta" and a[1] == UIS then
                hookOK = true; hookMethod = "namecall"
                return old(...) * pullMult
            end
            return old(...)
        end
        setreadonly(mt, true)
    end)
    if not hookOK then
        pcall(function()
            local oldGMD = UIS.GetMouseDelta
            if hookfunction then
                hookfunction(oldGMD, function(self)
                    if pullOn then hookOK = true; hookMethod = "hookfunction"; return oldGMD(self) * pullMult end
                    return oldGMD(self)
                end)
            end
        end)
    end
    if not hookOK then
        pcall(function()
            local mt = getrawmetatable(game)
            local old = mt.__index
            setreadonly(mt, false)
            mt.__index = function(t, k)
                if t == UIS and k == "GetMouseDelta" then
                    hookOK = true; hookMethod = "__index"
                end
                return old(t, k)
            end
            setreadonly(mt, true)
        end)
    end
    pcall(function()
        for _, v in ipairs(getgc()) do
            if type(v) == "function" then
                local c = { getconstants(v) }
                for _, cc in ipairs(c) do
                    if type(cc) == "string" and (cc:find("GetMouseDelta") or cc:find("MouseDelta")) then
                        if hookfunction then
                            hookOK = true; hookMethod = "gc"
                            hookObj = v
                        end
                    end
                end
            end
        end
    end)
end

-- VIM check
local vimOK = pcall(function() VIM:SendMouseMoveEvent(0, 0, false); return true end)

-- BodyForce
local bodyForce
function attachForce()
    if not plr.Character then return end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if bodyForce and bodyForce.Parent then bodyForce:Destroy() end
    bodyForce = Instance.new("VectorForce")
    bodyForce.Name = "SnqwForce"
    bodyForce.Force = Vector3.new(0, 0, 0)
    bodyForce.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
    bodyForce.Parent = hrp
end
plr.CharacterAdded:Connect(attachForce)
if plr.Character then attachForce() end

-- Pointer
local pointer = Instance.new("Part")
pointer.Name = "SnqwPointer"
pointer.Size = Vector3.new(1.2, 1.2, 1.2)
pointer.Shape = Enum.PartType.Ball
pointer.Color = Color3.fromRGB(200, 200, 200)
pointer.Material = Enum.Material.Neon
pointer.Transparency = 0.35
pointer.Anchored = true
pointer.CanCollide = false
pointer.Visible = false
pointer.Parent = WS

-- RenderStepped
RS.RenderStepped:Connect(function()
    if not plr.Character then return end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dt = RS:GetSteppedDelta()
    local dir = hrp.CFrame.LookVector * Vector3.new(1, 0, 1)

    if speedOn and dir.Magnitude > 0 then
        hrp.Velocity = hrp.Velocity + dir * speedMult * 200 * dt
    end
    if predOn and dir.Magnitude > 0 then
        hrp.Velocity = hrp.Velocity + dir * predInt * 100 * dt
    end
    if pullOn and held and dragStr > 1 then
        local amt = dragStr * pullMult * dt
        if useCFrame then hrp.CFrame = hrp.CFrame + dragDir * amt * 5 end
        hrp.Velocity = hrp.Velocity + dragDir * amt * 40
        if vimOK then VIM:SendMouseMoveEvent(dragStr * pullMult * 0.1, 0, false) end
        if bodyForce and bodyForce.Parent then bodyForce.Force = dragDir * dragStr * pullMult * 50 end
    end
    if sliding and clickTP then
        local d = slideTarget - hrp.Position
        d = Vector3.new(d.X, 0, d.Z)
        if d.Magnitude > 2 then
            local mv = d.Unit * math.min(d.Magnitude, slideMult * 100 * dt)
            hrp.CFrame = hrp.CFrame + mv
            hrp.Velocity = d.Unit * slideMult * 200
        else sliding = false end
    end
    if pointer and clickTP then
        local h = mouse.Hit
        if h then pointer.CFrame = CFrame.new(h.p); pointer.Visible = true
        else pointer.Visible = false end
    elseif pointer then pointer.Visible = false end
end)

-- Hertz
pcall(function() settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled end)
local hzBind
function upHz()
    if hzBind then hzBind:Disconnect() end
    if hzOn then
        pcall(setfpscap, hertz)
        hzBind = RS:BindToRenderStep("Hz", Enum.RenderPriority.Input.Value, function() end)
    end
end
upHz()

doHook()
task.spawn(function() while task.wait(5) do if not hookOK then doHook() end end end)

-- ── RAYFIELD-STYLE UI ──────────────────────────────────────
local gui = Instance.new("ScreenGui"); gui.Name = "Snqw"; gui.ResetOnSpawn = false; gui.Parent = plr:WaitForChild("PlayerGui")
gui.IgnoreGuiInset = true

local main = Instance.new("Frame"); main.Size = UDim2.new(0, 600, 0, 440); main.Position = UDim2.new(0.5, -300, 0.5, -220); main.BackgroundColor3 = Color3.fromRGB(15,15,15); main.BorderSizePixel = 0; main.Active = true; main.ClipsDescendants = true; main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Shadow
for i = 1, 3 do
    local s = Instance.new("ImageLabel"); s.Size = UDim2.new(1, 40, 1, 40); s.Position = UDim2.new(0, -20, 0, -20); s.BackgroundTransparency = 1; s.Image = "rbxassetid://6014261993"; s.ImageColor3 = Color3.fromRGB(0,0,0); s.ImageTransparency = 0.7 - i * 0.15; s.ScaleType = Enum.ScaleType.Slice; s.SliceCenter = Rect.new(20,20,20,20); s.ZIndex = -i; s.Parent = main
end

-- Title bar
local title = Instance.new("Frame", main); title.Size = UDim2.new(1, 0, 0, 46); title.BackgroundColor3 = Color3.fromRGB(20,20,20); title.BorderSizePixel = 0
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)
local tc = Instance.new("UICorner", Instance.new("Frame", main)); tc.CornerRadius = UDim.new(0, 10); tc.Parent.Position = UDim2.new(0, 0, 0, 36); tc.Parent.Size = UDim2.new(1, 0, 1, -36); tc.Parent.BackgroundColor3 = Color3.fromRGB(15,15,15); tc.Parent.BorderSizePixel = 0

local titleText = Instance.new("TextLabel", title); titleText.Size = UDim2.new(1, -50, 1, 0); titleText.Position = UDim2.new(0, 16, 0, 0); titleText.BackgroundTransparency = 1; titleText.Text = "SNQW .0GH"; titleText.TextColor3 = Color3.fromRGB(220,220,220); titleText.TextSize = 18; titleText.Font = Enum.Font.GothamBold; titleText.TextXAlignment = Enum.TextXAlignment.Left

-- Status
local st = Instance.new("TextLabel", main); st.Size = UDim2.new(1, -24, 0, 20); st.Position = UDim2.new(0, 12, 0, 50); st.BackgroundTransparency = 1; st.Text = ""; st.TextColor3 = Color3.fromRGB(0,200,0); st.TextSize = 10; st.Font = Enum.Font.GothamBold; st.TextXAlignment = Enum.TextXAlignment.Left; st.TextWrapped = true

function upSt()
    local m = #moveInfo > 0 and table.concat(moveInfo, ",") or "Unknown"
    st.Text = "Hook:" .. hookMethod .. " Pull:" .. pullMult .. "x Speed:" .. speedMult .. "x " .. hertz .. "Hz  TP:" .. (clickTP and "ON" or "OFF")
end

-- Close btn
local closeBtn = Instance.new("TextButton", title); closeBtn.Size = UDim2.new(0, 32, 0, 32); closeBtn.Position = UDim2.new(1, -40, 0.5, -16); closeBtn.BackgroundColor3 = Color3.fromRGB(35,35,35); closeBtn.BorderSizePixel = 0; closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(180,180,180); closeBtn.TextSize = 16; closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() speedOn=false; pullOn=false; hzOn=false; gui:Destroy() end)

-- Sidebar
local side = Instance.new("Frame", main); side.Size = UDim2.new(0, 170, 1, -66); side.Position = UDim2.new(0, 12, 0, 64); side.BackgroundColor3 = Color3.fromRGB(20,20,20); side.BorderSizePixel = 0
Instance.new("UICorner", side).CornerRadius = UDim.new(0, 8)

-- Content area
local contBg = Instance.new("Frame", main); contBg.Size = UDim2.new(1, -200, 1, -78); contBg.Position = UDim2.new(0, 188, 0, 72); contBg.BackgroundColor3 = Color3.fromRGB(18,18,18); contBg.BorderSizePixel = 0; contBg.ClipsDescendants = true
Instance.new("UICorner", contBg).CornerRadius = UDim.new(0, 8)

-- Draggable
local dragToggle, dragInput, dragStart, startPos
title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true; dragStart = i.Position; startPos = main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
    end
end)
title.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end
end)
UIS.InputChanged:Connect(function(i)
    if i == dragInput and dragToggle then
        local d = i.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Tab system
local tabBtns = {}; local contents = {}
local tabNames = {"PULL", "SPEED", "HZ", "SCAN"}

local sideLayout = Instance.new("UIListLayout", side); sideLayout.Padding = UDim.new(0, 4); sideLayout.SortOrder = Enum.SortOrder.LayoutOrder

for i, name in ipairs(tabNames) do
    local tb = Instance.new("TextButton", side); tb.Size = UDim2.new(1, -8, 0, 36); tb.BackgroundColor3 = i == 1 and Color3.fromRGB(30,30,30) or Color3.fromRGB(22,22,22); tb.BorderSizePixel = 0; tb.Text = name; tb.TextColor3 = i == 1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,140); tb.TextSize = 13; tb.Font = Enum.Font.GothamBold; tb.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("Frame", tb); pad.Size = UDim2.new(0, 3, 1, -8); pad.Position = UDim2.new(0, 0, 0, 4); pad.BackgroundColor3 = Color3.fromRGB(100,100,100); pad.BorderSizePixel = 0; pad.Visible = i == 1
    Instance.new("UICorner", pad).CornerRadius = UDim.new(0, 2)
    tb.MouseButton1Click:Connect(function()
        curTab = i
        for j, b in ipairs(tabBtns) do
            b.BackgroundColor3 = j == i and Color3.fromRGB(30,30,30) or Color3.fromRGB(22,22,22)
            b.TextColor3 = j == i and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,140)
            b:FindFirstChild("Frame").Visible = j == i
        end
        for j, c in ipairs(contents) do c.Visible = j == i end
    end)
    tabBtns[i] = tb
    local c = Instance.new("ScrollingFrame", contBg); c.Size = UDim2.new(1, -12, 1, -12); c.Position = UDim2.new(0, 6, 0, 6); c.BackgroundTransparency = 1; c.BorderSizePixel = 0; c.ScrollBarThickness = 3; c.CanvasSize = UDim2.new(0, 0, 0, 0); c.Visible = i == 1
    contents[i] = c
end

function addBtn(con, txt, cb, desc)
    local b = Instance.new("TextButton", con); b.Size = UDim2.new(1, 0, 0, 34); b.BackgroundColor3 = Color3.fromRGB(25,25,25); b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", b); l.Size = UDim2.new(1, -14, 1, 0); l.Position = UDim2.new(0, 14, 0, 0); l.BackgroundTransparency = 1; l.Text = txt; l.TextColor3 = Color3.fromRGB(200,200,200); l.TextSize = 13; l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
    if desc then
        local d = Instance.new("TextLabel", b); d.Size = UDim2.new(1, -14, 0, 14); d.Position = UDim2.new(0, 14, 0, 16); d.BackgroundTransparency = 1; d.Text = desc; d.TextColor3 = Color3.fromRGB(100,100,100); d.TextSize = 10; d.Font = Enum.Font.Gotham; d.TextXAlignment = Enum.TextXAlignment.Left
    end
    b.MouseEnter:Connect(function() TS:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35,35,35)}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play() end)
    b.MouseButton1Click:Connect(cb)
    return b
end

function addTog(con, txt, get, set)
    local b = Instance.new("TextButton", con); b.Size = UDim2.new(1, 0, 0, 34); b.BackgroundColor3 = Color3.fromRGB(25,25,25); b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", b); l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 14, 0, 0); l.BackgroundTransparency = 1; l.Text = txt; l.TextColor3 = Color3.fromRGB(200,200,200); l.TextSize = 13; l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
    local tog = Instance.new("Frame", b); tog.Size = UDim2.new(0, 36, 0, 20); tog.Position = UDim2.new(1, -48, 0.5, -10); tog.BackgroundColor3 = get() and Color3.fromRGB(80,130,80) or Color3.fromRGB(40,40,40); tog.BorderSizePixel = 0
    Instance.new("UICorner", tog).CornerRadius = UDim.new(0, 10)
    local dot = Instance.new("Frame", tog); dot.Size = UDim2.new(0, 16, 0, 16); dot.Position = get() and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8); dot.BackgroundColor3 = Color3.fromRGB(255,255,255); dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        set(not get())
        tog.BackgroundColor3 = get() and Color3.fromRGB(80,130,80) or Color3.fromRGB(40,40,40)
        dot:TweenPosition(get() and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), "Out", "Quad", 0.15, true)
    end)
    b.MouseEnter:Connect(function() TS:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35,35,35)}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play() end)
    return b
end

function refreshTab(i)
    local c = contents[i]
    local h = 0
    for _, v in ipairs(c:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextBox") then
            h = h + 34 + 4
        end
    end
    c.CanvasSize = UDim2.new(0, 0, 0, h + 8)
end

-- PULL TAB
addTog(contents[1], "Pull", function() return pullOn end, function(v) pullOn = v; upSt() end)
addBtn(contents[1], "Pull x" .. pullMult .. " (x10)", function() pullMult = pullMult * 10; upSt() refreshTab(1) end, "Current multiplier")
addBtn(contents[1], "Pull /10", function() pullMult = math.max(1, pullMult / 10); upSt() refreshTab(1) end)
addTog(contents[1], "CFrame Mode", function() return useCFrame end, function(v) useCFrame = v; upSt() end)
addBtn(contents[1], "Inject Hook", function() doHook(); upSt() end)
addBtn(contents[1], "Reattach Force", attachForce)
addTog(contents[1], "Click TP", function() return clickTP end, function(v) clickTP = v; if not v then sliding = false; pointer.Visible = false end; upSt() end)
addBtn(contents[1], "Slide x" .. slideMult .. " (x2)", function() slideMult = slideMult * 2; upSt() refreshTab(1) end)

-- SPEED TAB
addTog(contents[2], "Speed", function() return speedOn end, function(v) speedOn = v; upSt() end)
addBtn(contents[2], "Speed x2", function() speedMult = speedMult * 2; upSt() refreshTab(2) end, "Current: " .. speedMult .. "x")
addBtn(contents[2], "Speed /2", function() speedMult = math.max(1, speedMult / 2); upSt() refreshTab(2) end)
addTog(contents[2], "Prediction", function() return predOn end, function(v) predOn = v; upSt() end)
addBtn(contents[2], "Pred x2", function() predInt = predInt * 2; upSt() refreshTab(2) end, "Current: " .. predInt .. "x")

-- HZ TAB
local hzBox = Instance.new("TextBox", contents[3]); hzBox.Size = UDim2.new(1, 0, 0, 36); hzBox.BackgroundColor3 = Color3.fromRGB(25,25,25); hzBox.BorderSizePixel = 0; hzBox.Text = tostring(hertz); hzBox.TextColor3 = Color3.fromRGB(200,200,200); hzBox.TextSize = 18; hzBox.Font = Enum.Font.GothamBold; hzBox.PlaceholderText = "Enter Hz..."; hzBox.ClearTextOnFocus = false
Instance.new("UICorner", hzBox).CornerRadius = UDim.new(0, 6)
addBtn(contents[3], "Set Hz", function()
    local n = tonumber(hzBox.Text)
    if n and n > 0 then hertz = n; hzOn = true; upHz(); upSt() end
end)
addTog(contents[3], "Hz Enabled", function() return hzOn end, function(v) hzOn = v; upHz() end)
addBtn(contents[3], "Copy Loader", function() if setclipboard then setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/snqw293-eng/superpull/main/super_pull.lua"))()') end end)
addBtn(contents[3], "Quit", function() speedOn = false; pullOn = false; hzOn = false; gui:Destroy() end)

-- SCAN TAB
addBtn(contents[4], "Rescan Character", function() if plr.Character then studyChar(plr.Character); upSt() end end)
addBtn(contents[4], "Scan Game for Hooks", function()
    pcall(function()
        for _, v in ipairs(getgc()) do
            if type(v) == "function" then
                local c = { getconstants(v) }
                for _, cc in ipairs(c) do
                    if type(cc) == "string" and (cc:lower():find("delta") or cc:lower():find("drag") or cc:lower():find("mouse")) then
                        st.Text = "Found: " .. tostring(getinfo(v).source):sub(1, 40); return
                    end
                end
            end
        end
    end)
end)
addBtn(contents[4], "Test VIM", function() st.Text = "VIM: " .. (vimOK and "AVAILABLE" or "BLOCKED") end)
addBtn(contents[4], "Body: " .. (#moveInfo > 0 and table.concat(moveInfo, ",") or "?"), function() upSt() end)
addBtn(contents[4], "Brute Force Hook", function()
    doHook()
    pcall(function()
        for _, v in ipairs(getgc(true)) do
            if type(v) == "function" then
                local s = getinfo(v).source
                if s and s:find("Delta") then hookOK = true; hookMethod = "brute" end
            end
        end
    end)
    upSt()
end)

-- Footer
local ft = Instance.new("TextLabel", main); ft.Size = UDim2.new(1, -12, 0, 18); ft.Position = UDim2.new(0, 6, 1, -22); ft.BackgroundTransparency = 1; ft.Text = "snqw .0gh on discord  |  Pull:" .. pullMult .. "x  Hz:" .. hertz; ft.TextColor3 = Color3.fromRGB(80,80,80); ft.TextSize = 10; ft.Font = Enum.Font.Gotham

upSt()

-- Layouts per tab
local layouts = {}
for i = 1, 4 do
    layouts[i] = Instance.new("UIListLayout", contents[i])
    layouts[i].Padding = UDim.new(0, 4)
    layouts[i].SortOrder = Enum.SortOrder.LayoutOrder
end

for i = 1, 4 do refreshTab(i) end

main.Position = UDim2.new(0.5, -300, 0.55, -220)
TS:Create(main, TweenInfo.new(0.35), {Position = UDim2.new(0.5, -300, 0.5, -220)}):Play()

print("snqw loaded")
