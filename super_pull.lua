local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()

local pullMult = 500
local speedMult = 10
local hertz = 60
local pullOn = true
local speedOn = true
local hzOn = true
local curTab = 1

-- ── Hertz changer ─────────────────────────────────────────
pcall(function() settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled end)
pcall(setfpscap, hertz)

local hzBind
function updateHz()
    if hzBind then hzBind:Disconnect() end
    if hzOn then
        pcall(setfpscap, hertz)
        hzBind = RS:BindToRenderStep("Hz", Enum.RenderPriority.Input.Value, function() end)
    end
end
updateHz()

-- ── Pull hook ─────────────────────────────────────────────
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

-- ── Pull assist fallback ──────────────────────────────────
local lastP = Vector2.new()
local dragP = 0
mouse.Move:Connect(function()
    if pullOn and not hookOK and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local cur = Vector2.new(mouse.X, mouse.Y)
        if lastP.Magnitude > 0 then dragP = math.min(dragP + (cur - lastP).Magnitude * 0.5, 300) end
        lastP = cur
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then lastP = Vector2.new(); dragP = 0 end
end)

-- ── Speed boost ───────────────────────────────────────────
RS.RenderStepped:Connect(function()
    if speedOn and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        local dir = hrp.CFrame.LookVector * Vector3.new(1, 0, 1)
        if dir.Magnitude > 0 then hrp.Velocity = hrp.Velocity + dir * speedMult * 80 * RS:GetSteppedDelta() end
        if dragP > 1 and not hookOK then
            hrp.Velocity = hrp.Velocity + hrp.CFrame.LookVector * dragP * 500 * RS:GetSteppedDelta()
            dragP = dragP * 0.9
        end
    end
end)

-- ── UI ────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui"); gui.Name = "Snqw"; gui.ResetOnSpawn = false; gui.Parent = plr:WaitForChild("PlayerGui")
local bg = Instance.new("Frame"); bg.Size = UDim2.new(0, 340, 0, 380); bg.Position = UDim2.new(0.5, -170, 0.5, -190); bg.BackgroundColor3 = Color3.fromRGB(0,0,0); bg.BorderSizePixel = 2; bg.BorderColor3 = Color3.fromRGB(255,0,0); bg.Active = true; bg.Draggable = true; bg.Parent = gui

local t = Instance.new("TextLabel", bg); t.Size = UDim2.new(1,0,0,34); t.BackgroundColor3 = Color3.fromRGB(5,5,5); t.BorderSizePixel = 0; t.Text = "SNQW .0GH"; t.TextColor3 = Color3.fromRGB(255,30,30); t.TextSize = 24; t.Font = Enum.Font.FredokaOne

local st = Instance.new("TextLabel", bg); st.Size = UDim2.new(1,-10,0,14); st.Position = UDim2.new(0,5,0,34); st.BackgroundTransparency = 1; st.Text = "Pull:" .. (hookOK and "OK" or "FALLBACK") .. " | " .. pullMult .. "x | Speed:" .. speedMult .. "x | " .. hertz .. "Hz"; st.TextColor3 = Color3.fromRGB(0,255,0); st.TextSize = 11; st.Font = Enum.Font.GothamBold; st.TextXAlignment = Enum.TextXAlignment.Left

-- Tabs
local tabY = 50; local tabH = 28
local tabBtns = {}; local contents = {}
for i, name in ipairs({"PULL","SPEED","HERTZ"}) do
    local tb = Instance.new("TextButton", bg); tb.Size = UDim2.new(0.33,-2,0,tabH); tb.Position = UDim2.new((i-1)*0.33,1,0,tabY); tb.BackgroundColor3 = i==1 and Color3.fromRGB(200,0,0) or Color3.fromRGB(15,15,15); tb.BorderSizePixel = 0; tb.Text = name; tb.TextColor3 = Color3.fromRGB(255,255,255); tb.TextSize = 13; tb.Font = Enum.Font.GothamBold
    tb.MouseButton1Click:Connect(function() curTab=i; for j,b in ipairs(tabBtns) do TS:Create(b,TweenInfo.new(0.12),{BackgroundColor3=j==i and Color3.fromRGB(200,0,0) or Color3.fromRGB(15,15,15)}):Play() end; for j,c in ipairs(contents) do c.Visible=j==i end end)
    tabBtns[i]=tb
    local c = Instance.new("Frame", bg); c.Size = UDim2.new(1,-4,1,-(tabY+tabH+26)); c.Position = UDim2.new(0,2,0,tabY+tabH+4); c.BackgroundColor3 = Color3.fromRGB(0,0,0); c.BorderSizePixel = 0; c.Visible = i==1; contents[i]=c
end

function cbtn(con, txt, y, col, cb)
    local b = Instance.new("TextButton", con); b.Size = UDim2.new(0.9,0,0,30); b.Position = UDim2.new(0.05,0,0,y); b.BackgroundColor3 = col or Color3.fromRGB(20,20,20); b.BorderSizePixel = 1; b.BorderColor3 = Color3.fromRGB(80,80,80); b.Text = txt; b.TextColor3 = Color3.fromRGB(255,255,255); b.TextSize = 12; b.Font = Enum.Font.GothamBold
    local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,4)
    b.MouseEnter:Connect(function() TS:Create(b,TweenInfo.new(0.1),{BackgroundColor3=col and col:Lerp(Color3.fromRGB(255,255,255),0.25) or Color3.fromRGB(45,45,45)}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(b,TweenInfo.new(0.12),{BackgroundColor3=col or Color3.fromRGB(20,20,20)}):Play() end)
    b.MouseButton1Click:Connect(cb)
end

-- PULL tab
cbtn(contents[1], "Pull " .. (pullOn and "ON" or "OFF"), 6, Color3.fromRGB(25,25,140), function() pullOn=not pullOn; st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz" end)
cbtn(contents[1], "Pull x" .. pullMult .. " (+100)", 40, Color3.fromRGB(20,20,100), function() pullMult=pullMult+100; st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz" end)
cbtn(contents[1], "Pull x2", 74, Color3.fromRGB(40,20,80), function() pullMult=pullMult*2; st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz" end)
cbtn(contents[1], "PULL 5000x", 108, Color3.fromRGB(150,0,0), function() pullMult=5000; pullOn=true; st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz" end)
cbtn(contents[1], "PULL 10000x", 142, Color3.fromRGB(200,0,0), function() pullMult=10000; pullOn=true; st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz" end)

-- SPEED tab
cbtn(contents[2], "Speed " .. (speedOn and "ON" or "OFF"), 6, Color3.fromRGB(25,120,25), function() speedOn=not speedOn; st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz" end)
cbtn(contents[2], "Speed +10", 40, Color3.fromRGB(20,80,20), function() speedMult=speedMult+10; st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz" end)
cbtn(contents[2], "Speed x2", 74, Color3.fromRGB(40,60,20), function() speedMult=speedMult*2; st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz" end)
cbtn(contents[2], "SPEED 100x", 108, Color3.fromRGB(150,0,0), function() speedMult=100; speedOn=true; st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz" end)
cbtn(contents[2], "SPEED 500x", 142, Color3.fromRGB(200,0,0), function() speedMult=500; speedOn=true; st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz" end)

-- HERTZ tab
local hzVals = {30,60,120,240,480,999}
local hzIdx = 2
cbtn(contents[3], "Hz: " .. hertz .. " (cycle)", 6, Color3.fromRGB(100,30,30), function()
    hzIdx = hzIdx % #hzVals + 1; hertz = hzVals[hzIdx]; hzOn=true; updateHz()
    st.Text="Pull:"..(hookOK and "OK" or "FALLBACK").." | "..pullMult.."x | Speed:"..speedMult.."x | "..hertz.."Hz"
end)
cbtn(contents[3], "Hz " .. (hzOn and "ON" or "OFF"), 40, Color3.fromRGB(30,30,100), function() hzOn=not hzOn; updateHz() end)
cbtn(contents[3], "Copy Loader", 74, Color3.fromRGB(30,30,30), function() if setclipboard then setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/snqw293-eng/superpull/main/super_pull.lua"))()') end end)
cbtn(contents[3], "Rescan Game", 108, Color3.fromRGB(40,30,15), function() pcall(function() for _,v in ipairs(getgc()) do if type(v)=="function" then for _,cc in ipairs({getconstants(v)}) do if type(cc)=="string" and (cc:lower():find("delta") or cc:lower():find("drag")) then st.Text="Found: "..tostring(getinfo(v).source):sub(1,30); return end end end end end) end)
cbtn(contents[3], "QUIT", 142, Color3.fromRGB(120,0,0), function() speedOn=false; pullOn=false; hzOn=false; gui:Destroy() end)

-- Footer
local ft = Instance.new("TextLabel", bg); ft.Size = UDim2.new(1,0,0,16); ft.Position = UDim2.new(0,0,1,-16); ft.BackgroundTransparency = 1; ft.Text = "snqw .0gh on discord"; ft.TextColor3 = Color3.fromRGB(80,80,80); ft.TextSize = 11; ft.Font = Enum.Font.Gotham

-- Animate in
bg.Position = UDim2.new(0.5,-170,0.55,-190)
TS:Create(bg,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-170,0.5,-190)}):Play()

print("snqw .0gh OP loaded")
