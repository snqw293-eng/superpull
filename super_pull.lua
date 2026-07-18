-- snqw .0gh — 10000000x super pull
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
local vBoost = 1000
local moveInfo = {}
local clickPos = Vector2.new()
local lastClickTime = 0
local sliding = false
local slideTarget = Vector3.new()
local dblClickDelay = 0.4

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
    -- Find delta function in GC
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
doHook()

-- Auto rehook every 5s
spawn(function()
    while wait(5) do
        if not hookOK then
            doHook()
            upSt()
        end
    end
end)

-- VIM check
local vimOK = pcall(function() VIM:SendMouseMoveEvent(0, 0, false); return true end)

-- BodyForce attachment
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
    local flat = hrp.CFrame - hrp.CFrame.Position + Vector3.new(0, hrp.Position.Y, 0)

    if speedOn and dir.Magnitude > 0 then
        hrp.Velocity = hrp.Velocity + dir * speedMult * 200 * dt
    end

    if predOn and dir.Magnitude > 0 then
        hrp.Velocity = hrp.Velocity + dir * predInt * 100 * dt
    end

    if pullOn and held and dragStr > 1 then
        local amt = dragStr * pullMult * dt
        if useCFrame then
            hrp.CFrame = hrp.CFrame + dragDir * amt * 5
        end
        hrp.Velocity = hrp.Velocity + dragDir * amt * 40
        if vimOK then
            VIM:SendMouseMoveEvent(dragStr * pullMult * 0.1, 0, false)
        end
        if bodyForce and bodyForce.Parent then
            bodyForce.Force = dragDir * dragStr * pullMult * 50
        end
    end

    if sliding and clickTP then
        local d = slideTarget - hrp.Position
        d = Vector3.new(d.X, 0, d.Z)
        if d.Magnitude > 2 then
            local mv = d.Unit * math.min(d.Magnitude, slideMult * 100 * dt)
            hrp.CFrame = hrp.CFrame + mv
            hrp.Velocity = d.Unit * slideMult * 200
        else
            sliding = false
        end
    end

    if pointer and clickTP then
        local h = mouse.Hit
        if h then
            pointer.CFrame = CFrame.new(h.p)
            pointer.Visible = true
        else
            pointer.Visible = false
        end
    elseif pointer then
        pointer.Visible = false
    end
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

-- UI
local gui = Instance.new("ScreenGui"); gui.Name = "Snqw"; gui.ResetOnSpawn = false; gui.Parent = plr:WaitForChild("PlayerGui")
local bg = Instance.new("Frame"); bg.Size = UDim2.new(0, 500, 0, 460); bg.Position = UDim2.new(0.5, -250, 0.5, -230); bg.BackgroundColor3 = Color3.fromRGB(5,5,5); bg.BorderSizePixel = 0; bg.Active = true; bg.Draggable = true; bg.Parent = gui

local t = Instance.new("TextLabel", bg); t.Size = UDim2.new(1,0,0,34); t.BackgroundColor3 = Color3.fromRGB(8,8,8); t.BorderSizePixel = 0; t.Text = "SNQW .0GH"; t.TextColor3 = Color3.fromRGB(180,180,180); t.TextSize = 22; t.Font = Enum.Font.FredokaOne

local st = Instance.new("TextLabel", bg); st.Size = UDim2.new(1,-10,0,24); st.Position = UDim2.new(0,5,0,34); st.BackgroundTransparency = 1; st.Text = ""; st.TextColor3 = Color3.fromRGB(0,200,0); st.TextSize = 10; st.Font = Enum.Font.GothamBold; st.TextXAlignment = Enum.TextXAlignment.Left; st.TextWrapped = true

function upSt()
    local m = #moveInfo > 0 and table.concat(moveInfo, ",") or "Unknown"
    st.Text = "Hook:" .. hookMethod .. " Pull:" .. pullMult .. "x Speed:" .. speedMult .. "x " .. hertz .. "Hz\nMove:" .. m .. " CFrame:" .. tostring(useCFrame) .. " TP:" .. (clickTP and "ON" or "OFF")
end

local tabBtns = {}; local contents = {}
local sideW = 82
local side = Instance.new("Frame", bg); side.Size = UDim2.new(0, sideW, 1, -62); side.Position = UDim2.new(0,0,0,60); side.BackgroundColor3 = Color3.fromRGB(8,8,8); side.BorderSizePixel = 0
local contBg = Instance.new("Frame", bg); contBg.Size = UDim2.new(1,-sideW-2, 1,-64); contBg.Position = UDim2.new(0,sideW+2,0,62); contBg.BackgroundColor3 = Color3.fromRGB(5,5,5); contBg.BorderSizePixel = 0

local tabNames = {"PULL","SPEED","HZ","SCAN"}
for i, name in ipairs(tabNames) do
    local tb = Instance.new("TextButton", side); tb.Size = UDim2.new(1,-4,0,38); tb.Position = UDim2.new(0,2,0,(i-1)*42+2); tb.BackgroundColor3 = i==1 and Color3.fromRGB(20,20,20) or Color3.fromRGB(10,10,10); tb.BorderSizePixel = 0; tb.Text = name; tb.TextColor3 = i==1 and Color3.fromRGB(200,200,200) or Color3.fromRGB(90,90,90); tb.TextSize = 12; tb.Font = Enum.Font.GothamBold
    tb.MouseButton1Click:Connect(function() curTab=i; for j,b in ipairs(tabBtns) do b.BackgroundColor3=j==i and Color3.fromRGB(20,20,20) or Color3.fromRGB(10,10,10); b.TextColor3=j==i and Color3.fromRGB(200,200,200) or Color3.fromRGB(90,90,90) end; for j,c in ipairs(contents) do c.Visible=j==i end end)
    tabBtns[i]=tb
    local c = Instance.new("Frame", contBg); c.Size = UDim2.new(1,-4,1,-4); c.Position = UDim2.new(0,2,0,2); c.BackgroundColor3 = Color3.fromRGB(5,5,5); c.BorderSizePixel = 0; c.Visible = i==1; contents[i]=c
end

function cbtn(con, txt, y, col, cb)
    local b = Instance.new("TextButton", con); b.Size = UDim2.new(0.95,0,0,30); b.Position = UDim2.new(0.025,0,0,y); b.BackgroundColor3 = col or Color3.fromRGB(12,12,12); b.BorderSizePixel = 0; b.Text = txt; b.TextColor3 = Color3.fromRGB(200,200,200); b.TextSize = 11; b.Font = Enum.Font.GothamBold
    b.MouseEnter:Connect(function() b.BackgroundColor3 = col and col:Lerp(Color3.fromRGB(40,40,40),0.5) or Color3.fromRGB(22,22,22) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = col or Color3.fromRGB(12,12,12) end)
    b.MouseButton1Click:Connect(cb)
end

-- PULL
cbtn(contents[1], "Pull " .. (pullOn and "ON" or "OFF"), 4, Color3.fromRGB(18,18,40), function() pullOn=not pullOn; upSt() end)
cbtn(contents[1], "Pull x" .. pullMult .. " (x10)", 38, Color3.fromRGB(15,15,35), function() pullMult=pullMult*10; upSt() end)
cbtn(contents[1], "Pull /10", 72, Color3.fromRGB(15,15,15), function() pullMult=math.max(1,pullMult/10); upSt() end)
cbtn(contents[1], "CFrame " .. (useCFrame and "ON" or "OFF"), 106, Color3.fromRGB(20,20,20), function() useCFrame=not useCFrame; upSt() end)
cbtn(contents[1], "Inject Hook", 140, Color3.fromRGB(20,20,20), doHook)
cbtn(contents[1], "Reattach Force", 174, Color3.fromRGB(18,18,18), attachForce)
cbtn(contents[1], "Click TP " .. (clickTP and "ON" or "OFF"), 208, Color3.fromRGB(18,18,18), function() clickTP=not clickTP; if not clickTP then sliding=false; pointer.Visible=false end; upSt() end)
cbtn(contents[1], "Slide x" .. slideMult .. " (x2)", 242, Color3.fromRGB(14,14,25), function() slideMult=slideMult*2; upSt() end)

-- SPEED
cbtn(contents[2], "Speed " .. (speedOn and "ON" or "OFF"), 4, Color3.fromRGB(15,35,15), function() speedOn=not speedOn; upSt() end)
cbtn(contents[2], "Speed x2", 38, Color3.fromRGB(12,30,12), function() speedMult=speedMult*2; upSt() end)
cbtn(contents[2], "Speed /2", 72, Color3.fromRGB(15,15,15), function() speedMult=math.max(1,speedMult/2); upSt() end)
cbtn(contents[2], "Prediction " .. (predOn and "ON" or "OFF"), 106, Color3.fromRGB(18,18,18), function() predOn=not predOn; upSt() end)
cbtn(contents[2], "Pred x" .. predInt .. " (x2)", 140, Color3.fromRGB(14,14,30), function() predInt=predInt*2; upSt() end)

-- HZ
local hzBox = Instance.new("TextBox", contents[3]); hzBox.Size = UDim2.new(0.9,0,0,34); hzBox.Position = UDim2.new(0.05,0,0,4); hzBox.BackgroundColor3 = Color3.fromRGB(10,10,10); hzBox.BorderSizePixel = 0; hzBox.Text = tostring(hertz); hzBox.TextColor3 = Color3.fromRGB(200,200,200); hzBox.TextSize = 18; hzBox.Font = Enum.Font.GothamBold; hzBox.PlaceholderText = "Enter Hz..."
Instance.new("UICorner", hzBox).CornerRadius = UDim.new(0,4)
local hzSet = Instance.new("TextButton", contents[3]); hzSet.Size = UDim2.new(0.9,0,0,28); hzSet.Position = UDim2.new(0.05,0,0,44); hzSet.BackgroundColor3 = Color3.fromRGB(20,20,20); hzSet.BorderSizePixel = 0; hzSet.Text = "SET HZ"; hzSet.TextColor3 = Color3.fromRGB(180,180,180); hzSet.TextSize = 12; hzSet.Font = Enum.Font.GothamBold
Instance.new("UICorner", hzSet).CornerRadius = UDim.new(0,4)
hzSet.MouseButton1Click:Connect(function()
    local n = tonumber(hzBox.Text)
    if n and n > 0 then hertz = n; hzOn = true; upHz(); upSt() end
end)
cbtn(contents[3], "Hz " .. (hzOn and "ON" or "OFF"), 80, Color3.fromRGB(15,15,35), function() hzOn=not hzOn; upHz() end)
cbtn(contents[3], "Copy Loader", 114, Color3.fromRGB(12,12,12), function() if setclipboard then setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/snqw293-eng/superpull/main/super_pull.lua"))()') end end)
cbtn(contents[3], "Quit", 148, Color3.fromRGB(25,25,25), function() speedOn=false; pullOn=false; hzOn=false; gui:Destroy() end)

-- SCAN
cbtn(contents[4], "Rescan Character", 4, Color3.fromRGB(20,18,10), function() if plr.Character then studyChar(plr.Character); upSt() end end)
cbtn(contents[4], "Scan Game for Hook", 38, Color3.fromRGB(20,18,10), function() pcall(function() for _,v in ipairs(getgc()) do if type(v)=="function" then local c={getconstants(v)}; for _,cc in ipairs(c) do if type(cc)=="string" and (cc:lower():find("delta") or cc:lower():find("drag") or cc:lower():find("mouse")) then st.Text="Found: "..tostring(getinfo(v).source):sub(1,40); return end end end end end) end)
cbtn(contents[4], "Test VIM", 72, Color3.fromRGB(15,15,35), function() st.Text = "VIM: " .. (vimOK and "AVAILABLE" or "BLOCKED") end)
cbtn(contents[4], "BodyMove: " .. (#moveInfo>0 and table.concat(moveInfo,",") or "?"), 106, Color3.fromRGB(12,12,12), function() upSt() end)
cbtn(contents[4], "Brute Force Hook", 140, Color3.fromRGB(25,18,10), function() doHook(); pcall(function() for _,v in ipairs(getgc(true)) do if type(v)=="function" then local s = getinfo(v).source if s and s:find("Delta") then hookOK=true; hookMethod="brute" end end end end); upSt() end)

local ft = Instance.new("TextLabel", bg); ft.Size = UDim2.new(1,0,0,16); ft.Position = UDim2.new(0,0,1,-16); ft.BackgroundTransparency = 1; ft.Text = "snqw .0gh on discord"; ft.TextColor3 = Color3.fromRGB(60,60,60); ft.TextSize = 11; ft.Font = Enum.Font.Gotham

upSt()
bg.Position = UDim2.new(0.5,-250,0.55,-230)
TS:Create(bg,TweenInfo.new(0.35),{Position=UDim2.new(0.5,-250,0.5,-230)}):Play()

print("snqw 10000000x loaded")
