print("[Qovick] 1. Старт")

local QovickUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Colors = {
    Bg = Color3.fromRGB(18, 18, 20),
    Sidebar = Color3.fromRGB(22, 22, 26),
    Panel = Color3.fromRGB(28, 28, 34),
    PanelHover = Color3.fromRGB(35, 35, 42),
    Accent = Color3.fromRGB(240, 168, 64),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 160),
    Red = Color3.fromRGB(255, 60, 60),
    Blue = Color3.fromRGB(60, 150, 255),
    Green = Color3.fromRGB(60, 255, 60)
}

print("[Qovick] 2. Переменные загружены")

-- Ультимативное подключение (gethui -> CoreGui -> PlayerGui)
local ParentGui = nil
pcall(function() ParentGui = gethui() end)
if not ParentGui then
    pcall(function() ParentGui = game:GetService("CoreGui") end)
end
if not ParentGui then
    ParentGui = LocalPlayer:WaitForChild("PlayerGui")
end

print("[Qovick] 3. Экран привязан к: " .. tostring(ParentGui))

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QovickUI_Main"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 620, 0, 420)
Main.Position = UDim2.new(0.5, -310, 0.5, -210)
Main.BackgroundColor3 = Colors.Bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Colors.Accent
Stroke.Thickness = 1
Stroke.Transparency = 0.7

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Colors.Sidebar
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Qovick Hub [RightCtrl to Close]"
Title.TextColor3 = Colors.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 160, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BorderSizePixel = 0

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.VerticalAlignment = Enum.VerticalAlignment.Top

local ContentArea = Instance.new("ScrollingFrame", Main)
ContentArea.Size = UDim2.new(1, -170, 1, -55)
ContentArea.Position = UDim2.new(0, 165, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = Colors.Accent
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)

local ContentList = Instance.new("UIListLayout", ContentArea)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Padding = UDim.new(0, 8)

print("[Qovick] 4. Каркас нарисован")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

local Tabs = {}
local Pages = {}

function QovickUI:CreateTab(name)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.BackgroundColor3 = Colors.Bg
    TabBtn.TextColor3 = Colors.TextDim
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 14
    TabBtn.Text = name
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.AutoButtonColor = false
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    local Padding = Instance.new("UIPadding", TabBtn)
    Padding.PaddingLeft = UDim.new(0, 15)

    local Page = Instance.new("Frame", ContentArea)
    Page.Size = UDim2.new(1, 0, 0, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.AutomaticSize = Enum.AutomaticSize.Y
    
    local PageList = Instance.new("UIListLayout", Page)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Padding = UDim.new(0, 8)

    table.insert(Tabs, TabBtn)
    table.insert(Pages, Page)

    TabBtn.MouseButton1Click:Connect(function()
        for i, p in pairs(Pages) do
            p.Visible = false
            Tabs[i].BackgroundColor3 = Colors.Bg
            Tabs[i].TextColor3 = Colors.TextDim
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Colors.Accent
        TabBtn.TextColor3 = Colors.Bg
    end)

    if #Tabs == 1 then
        Page.Visible = true
        TabBtn.BackgroundColor3 = Colors.Accent
        TabBtn.TextColor3 = Colors.Bg
    end

    local TabAPI = {}

    function TabAPI:CreateButton(text, callback)
        local Btn = Instance.new("TextButton", Page)
        Btn.Size = UDim2.new(1, 0, 0, 35)
        Btn.BackgroundColor3 = Colors.Panel
        Btn.TextColor3 = Colors.Text
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextSize = 14
        Btn.Text = text
        Btn.AutoButtonColor = false
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.PanelHover}):Play() end)
        Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Panel}):Play() end)
        Btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    end

    function TabAPI:CreateToggle(text, default, callback)
        local Holder = Instance.new("Frame", Page)
        Holder.Size = UDim2.new(1, 0, 0, 40)
        Holder.BackgroundColor3 = Colors.Panel
        Instance.new("UICorner", Holder).CornerRadius = UDim.new(0, 6)
        local Label = Instance.new("TextLabel", Holder)
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Colors.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        local ToggleBg = Instance.new("Frame", Holder)
        ToggleBg.Size = UDim2.new(0, 36, 0, 18)
        ToggleBg.Position = UDim2.new(1, -50, 0.5, -9)
        ToggleBg.BackgroundColor3 = default and Colors.Accent or Color3.fromRGB(50, 50, 60)
        Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
        local Dot = Instance.new("Frame", ToggleBg)
        Dot.Size = UDim2.new(0, 14, 0, 14)
        Dot.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
        local state = default
        local Btn = Instance.new("TextButton", Holder)
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = state and Colors.Accent or Color3.fromRGB(50, 50, 60)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
            if callback then callback(state) end
        end)
    end

    function TabAPI:CreateSlider(text, min, max, default, callback)
        local Holder = Instance.new("Frame", Page)
        Holder.Size = UDim2.new(1, 0, 0, 50)
        Holder.BackgroundColor3 = Colors.Panel
        Instance.new("UICorner", Holder).CornerRadius = UDim.new(0, 6)
        local Label = Instance.new("TextLabel", Holder)
        Label.Size = UDim2.new(1, -30, 0, 20)
        Label.Position = UDim2.new(0, 15, 0, 5)
        Label.BackgroundTransparency = 1
        Label.Text = text .. ": " .. default
        Label.TextColor3 = Colors.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        local BarBg = Instance.new("Frame", Holder)
        BarBg.Size = UDim2.new(1, -30, 0, 6)
        BarBg.Position = UDim2.new(0, 15, 0, 30)
        BarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)
        local Fill = Instance.new("Frame", BarBg)
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Colors.Accent
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
        local Btn = Instance.new("TextButton", BarBg)
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        local dragging = false
        Btn.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local mousePos = UserInputService:GetMouseLocation().X
                local barPos = BarBg.AbsolutePosition.X
                local barSize = BarBg.AbsoluteSize.X
                local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                local val = math.floor(min + ((max - min) * percent))
                Label.Text = text .. ": " .. val
                if callback then callback(val) end
            end
        end)
    end
    return TabAPI
end

print("[Qovick] 5. Библиотека UI готова")

local State = {
    SilentAim = false, AutoShoot = false, FOVSize = 120, TargetPart = "Head",
    KillAura = false, KillDist = 20,
    ESP = false, ESPName = true, ESPBox = false, ESPTracer = false, ESPOutline = false, MaxDist = 2000,
    WalkSpeed = 16, JumpPower = 50, FlyActive = false,
    AutoFarm = false, AutoPickupGun = false, ResetOnFull = false, KillAllOnFull = false
}

local Sheriff = QovickUI:CreateTab("Sheriff")
Sheriff:CreateToggle("Silent Aim", false, function(v) State.SilentAim = v end)
Sheriff:CreateToggle("Auto Shoot", false, function(v) State.AutoShoot = v end)
Sheriff:CreateSlider("Aimbot FOV", 10, 800, 120, function(v) State.FOVSize = v end)
Sheriff:CreateButton("Pick Up Gun (Any Dist)", function()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "GunDrop" or (obj:IsA("Tool") and obj.Name == "Gun") then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 1)
            end
        end
    end
end)
Sheriff:CreateToggle("Auto Pickup Gun", false, function(v) State.AutoPickupGun = v end)

local Murderer = QovickUI:CreateTab("Murderer")
Murderer:CreateToggle("Kill Aura", false, function(v) State.KillAura = v end)
Murderer:CreateSlider("Kill Range", 5, 100, 20, function(v) State.KillDist = v end)

local Visuals = QovickUI:CreateTab("Visuals")
Visuals:CreateToggle("Enable ESP", false, function(v) State.ESP = v end)
Visuals:CreateToggle("Show Box", false, function(v) State.ESPBox = v end)
Visuals:CreateToggle("Show Tracers", false, function(v) State.ESPTracer = v end)
Visuals:CreateToggle("Outline (Chams)", false, function(v) State.ESPOutline = v end)

local PlayerTab = QovickUI:CreateTab("Player")
PlayerTab:CreateSlider("Walk Speed", 16, 200, 16, function(v)
    State.WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end
end)
PlayerTab:CreateSlider("Jump Power", 50, 300, 50, function(v)
    State.JumpPower = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end
end)

PlayerTab:CreateToggle("Fly [Space/Shift]", false, function(v)
    State.FlyActive = v
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if v then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "QovickFly"; bv.MaxForce = Vector3.new(1,1,1)*100000; bv.Velocity = Vector3.zero
        local bg = Instance.new("BodyGyro", hrp); bg.Name = "QovickGyro"; bg.MaxTorque = Vector3.new(1,1,1)*100000; bg.P = 1000
        RunService.RenderStepped:Connect(function()
            if not State.FlyActive or not hrp or not hrp.Parent then return end
            local move = UserInputService:GetMoveVector()
            local cam = Camera.CFrame
            local dir = (cam.LookVector * -move.Z + cam.RightVector * move.X).Unit
            
            local yDir = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then yDir = 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then yDir = -1 end
            
            bv.Velocity = (dir * 50) + Vector3.new(0, yDir * 50, 0)
            bg.CFrame = cam
            char.Humanoid.PlatformStand = true
        end)
    else
        if hrp:FindFirstChild("QovickFly") then hrp.QovickFly:Destroy() end
        if hrp:FindFirstChild("QovickGyro") then hrp.QovickGyro:Destroy() end
        if char:FindFirstChildOfClass("Humanoid") then char.Humanoid.PlatformStand = false end
    end
end)

local Tp = QovickUI:CreateTab("Teleport")
Tp:CreateButton("TP Murderer", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (p.Backpack and p.Backpack:FindFirstChild("Knife")) or (p.Character and p.Character:FindFirstChild("Knife")) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame; break
            end
        end
    end
end)
Tp:CreateButton("TP Sheriff", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (p.Backpack and p.Backpack:FindFirstChild("Gun")) or (p.Character and p.Character:FindFirstChild("Gun")) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame; break
            end
        end
    end
end)

local Farm = QovickUI:CreateTab("Farm")
Farm:CreateToggle("AutoFarm (Under & Hover)", false, function(v) State.AutoFarm = v end)
Farm:CreateToggle("Death on Full Bag", false, function(v) State.ResetOnFull = v end)
Farm:CreateToggle("Kill All on Full Bag (Murderer)", false, function(v) State.KillAllOnFull = v end)

local Troll = QovickUI:CreateTab("Troll")
Troll:CreateToggle("Fake Headless", false, function(v)
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        if v then
            if not head:FindFirstChildOfClass("SpecialMesh") then
                local m = Instance.new("SpecialMesh", head); m.Scale = Vector3.new(0,0,0)
            end
        else
            if head:FindFirstChildOfClass("SpecialMesh") then head:FindFirstChildOfClass("SpecialMesh"):Destroy() end
        end
    end
end)

local Settings = QovickUI:CreateTab("Settings")
Settings:CreateButton("Unload Hub", function() ScreenGui:Destroy() end)

print("[Qovick] 6. Вкладки и кнопки созданы")

-- ==========================================
-- ЦИКЛЫ (ESP, ОБВОДКА, РОЛИ)
-- ==========================================
local Drawings = {}
local Highlights = {}

Players.PlayerRemoving:Connect(function(p)
    if Drawings[p] then
        if Drawings[p].Text then Drawings[p].Text:Remove() end
        if Drawings[p].Box then Drawings[p].Box:Remove() end
        if Drawings[p].Tracer then Drawings[p].Tracer:Remove() end
        Drawings[p] = nil
    end
    if Highlights[p] then
        Highlights[p]:Destroy()
        Highlights[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not State.ESP and not State.ESPOutline then
        for _, d in pairs(Drawings) do 
            if d.Text then d.Text:Remove() end
            if d.Box then d.Box:Remove() end
            if d.Tracer then d.Tracer:Remove() end
        end
        Drawings = {} 
        for _, h in pairs(Highlights) do h:Destroy() end
        Highlights = {}
        return
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character
            local hrp = char.HumanoidRootPart
            
            local roleText = ""
            local roleColor = Colors.Text
            local hasKnife = (p.Backpack and p.Backpack:FindFirstChild("Knife")) or (char:FindFirstChild("Knife"))
            local hasGun = (p.Backpack and p.Backpack:FindFirstChild("Gun")) or (char:FindFirstChild("Gun"))
            
            if hasKnife then
                roleText = " [Murderer]"
                roleColor = Colors.Red
            elseif hasGun then
                roleText = " [Sheriff]"
                roleColor = Colors.Blue
            else
                roleText = " [Innocent]"
                roleColor = Colors.Green
            end
            
            if State.ESPOutline then
                if not Highlights[p] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "QovickESP"
                    hl.FillColor = roleColor
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = roleColor
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                    Highlights[p] = hl
                else
                    Highlights[p].FillColor = roleColor
                    Highlights[p].OutlineColor = roleColor
                end
            else
                if Highlights[p] then Highlights[p]:Destroy(); Highlights[p] = nil end
            end

            if State.ESP then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    if not Drawings[p] then Drawings[p] = { Text = Drawing.new("Text"), Box = Drawing.new("Square"), Tracer = Drawing.new("Line") } end
                    local d = Drawings[p]
                    
                    if State.ESPName then
                        d.Text.Visible = true
                        d.Text.Text = p.Name .. roleText
                        d.Text.Color = roleColor
                        d.Text.Size = 16
                        d.Text.Center = true
                        d.Text.Outline = true
                        d.Text.Position = Vector2.new(pos.X, pos.Y - 20)
                    else d.Text.Visible = false end
                    
                    if State.ESPBox then
                        d.Box.Visible = true; d.Box.Color = roleColor; d.Box.Thickness = 1; d.Box.Size = Vector2.new(50, 80); d.Box.Position = Vector2.new(pos.X - 25, pos.Y - 40)
                    else d.Box.Visible = false end
                    
                    if State.ESPTracer then
                        d.Tracer.Visible = true; d.Tracer.Color = roleColor; d.Tracer.Thickness = 1; d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); d.Tracer.To = Vector2.new(pos.X, pos.Y + 20)
                    else d.Tracer.Visible = false end
                else
                    if Drawings[p] then Drawings[p].Text.Visible = false; Drawings[p].Box.Visible = false; Drawings[p].Tracer.Visible = false end
                end
            end
        end
    end
end)

-- ==========================================
-- АВТОФАРМ (ПОД МОНЕТУ + ЗАВИСАНИЕ)
-- ==========================================
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local bagSize = 0
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, obj in pairs(backpack:GetChildren()) do
            if obj.Name:lower():find("coin") or obj.Name:lower():find("candy") then bagSize = 50 end
        end
    end

    if bagSize >= 50 then
        if State.KillAllOnFull then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid").Health > 0 then
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    if tool and tool:FindFirstChild("Kill") then
                        tool.Kill:FireServer(p.Character)
                    end
                end
            end
        end
        if State.ResetOnFull or State.KillAllOnFull then
            char:BreakJoints()
            task.wait(1)
            return
        end
    end

    if not State.AutoFarm then return end
    
    local targetCoin = nil
    local shortestDist = 1000

    for _, obj in pairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find("coin") or n:find("candy") or n:find("drop") or n:find("event") then
            local handle = obj:FindFirstChild("Handle") or (obj:IsA("BasePart") and obj)
            if handle and handle:IsA("BasePart") then
                local dist = (char.HumanoidRootPart.Position - handle.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    targetCoin = handle
                end
            end
        end
    end

    if targetCoin then
        char.HumanoidRootPart.CFrame = targetCoin.CFrame * CFrame.new(0, -3, 0)
        char.HumanoidRootPart.Velocity = Vector3.zero
        char.HumanoidRootPart.Anchored = true
        
        if firetouchinterest then
            firetouchinterest(char.HumanoidRootPart, targetCoin, 0)
            firetouchinterest(char.HumanoidRootPart, targetCoin, 1)
        end
        
        local waitTime = 0
        while targetCoin.Parent and waitTime < 1 do
            task.wait(0.05)
            waitTime = waitTime + 0.05
        end
        
        char.HumanoidRootPart.Anchored = false
    end
end)

-- АВТО-ПОДБОР ПИСТОЛЕТА
RunService.Heartbeat:Connect(function()
    if not State.AutoPickupGun then return end
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Tool") and obj.Name == "Gun" then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                LocalPlayer.Character.HumanoidRootPart.CFrame = handle.CFrame
                task.wait(0.1)
            end
        end
    end
end)

-- Aimbot / Kill Aura
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local closestTarget = nil
    local shortestDist = State.FOVSize
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local tChar = p.Character
            local tHrp = tChar.HumanoidRootPart
            local hum = tChar:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if State.KillAura then
                    if (hrp.Position - tHrp.Position).Magnitude <= State.KillDist then
                        local tool = char:FindFirstChildWhichIsA("Tool")
                        if tool and tool:FindFirstChild("Kill") then tool.Kill:FireServer(tChar) end
                    end
                end
                if State.SilentAim then
                    local vec, onScreen = Camera:WorldToViewportPoint(tHrp.Position)
                    if onScreen then
                        local distToMouse = (Vector2.new(vec.X, vec.Y) - mousePos).Magnitude
                        if distToMouse < shortestDist then shortestDist = distToMouse; closestTarget = tChar end
                    end
                end
            end
        end
    end
    if State.SilentAim and closestTarget then
        local targetPart = closestTarget:FindFirstChild(State.TargetPart) or closestTarget:FindFirstChild("HumanoidRootPart")
        if targetPart and Mouse.Target then pcall(function() Mouse.Target = targetPart end) end
    end
    if State.AutoShoot and closestTarget then pcall(function() mouse1click() end) end
end)

print("[Qovick] 7. Скрипт успешно загружен!")
