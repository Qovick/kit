-- Qovick Hub :: Ultimate Build
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Qovick Hub",
   LoadingTitle = "Qovick Hub",
   LoadingSubtitle = "by Sam",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local State = {
    SilentAim = false, AutoShoot = false, FOVSize = 120, TargetPart = "Head",
    KillAura = false, KillDist = 20, AutoKill = false, KnifeThrow = false,
    ESP = false, ESPName = true, ESPBox = false, ESPTracer = false, MaxDist = 2000,
    WalkSpeed = 16, JumpPower = 50, FlyActive = false,
    AutoCoins = false, AutoRespawn = false, FarmDist = 100,
    FlingTarget = nil, FlingPanel = false
}

-- 1. SHERIFF
local SheriffTab = Window:CreateTab("Sheriff", 4483362458)
SheriffTab:CreateSection("Aimbot")
SheriffTab:CreateToggle({ Name = "Silent Aim", CurrentValue = false, Callback = function(v) State.SilentAim = v end })
SheriffTab:CreateToggle({ Name = "Auto Shoot", CurrentValue = false, Callback = function(v) State.AutoShoot = v end })
SheriffTab:CreateSlider({ Name = "Aimbot FOV", Range = {10, 800}, Increment = 10, Suffix = "px", CurrentValue = 120, Callback = function(v) State.FOVSize = v end })
SheriffTab:CreateDropdown({ Name = "Hitbox", Options = {"Head", "HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(o) State.TargetPart = o[1] end })

-- 2. MURDERER
local MurdererTab = Window:CreateTab("Murderer", 4483362458)
MurdererTab:CreateSection("Kill Options")
MurdererTab:CreateToggle({ Name = "Kill Aura", CurrentValue = false, Callback = function(v) State.KillAura = v end })
MurdererTab:CreateSlider({ Name = "Kill Range", Range = {5, 100}, Increment = 1, Suffix = " st", CurrentValue = 20, Callback = function(v) State.KillDist = v end })
MurdererTab:CreateToggle({ Name = "Auto Kill", CurrentValue = false, Callback = function(v) State.AutoKill = v end })

-- 3. VISUALS
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Callback = function(v) State.ESP = v end })
VisualsTab:CreateToggle({ Name = "Show Name", CurrentValue = true, Callback = function(v) State.ESPName = v end })
VisualsTab:CreateToggle({ Name = "Show Box", CurrentValue = false, Callback = function(v) State.ESPBox = v end })
VisualsTab:CreateToggle({ Name = "Show Tracers", CurrentValue = false, Callback = function(v) State.ESPTracer = v end })

-- 4. PLAYER
local PlayerTab = Window:CreateTab("Player", 4483362458)
PlayerTab:CreateSection("Movement")
PlayerTab:CreateSlider({ Name = "Walk Speed", Range = {16, 200}, Increment = 1, Suffix = " spd", CurrentValue = 16, Callback = function(v)
    State.WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end
end })
PlayerTab:CreateSlider({ Name = "Jump Power", Range = {50, 300}, Increment = 5, Suffix = " pwr", CurrentValue = 50, Callback = function(v)
    State.JumpPower = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end
end })
PlayerTab:CreateToggle({ Name = "Fly", CurrentValue = false, Callback = function(v)
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
            bv.Velocity = Camera.CFrame:VectorToWorldSpace(Vector3.new(move.X, 0, move.Z)) * 50
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then bv.Velocity = bv.Velocity + Vector3.new(0, 50, 0) end
            bg.CFrame = Camera.CFrame
        end)
    else
        if hrp:FindFirstChild("QovickFly") then hrp.QovickFly:Destroy() end
        if hrp:FindFirstChild("QovickGyro") then hrp.QovickGyro:Destroy() end
    end
end })

-- 5. TELEPORT
local TpTab = Window:CreateTab("Teleport", 4483362458)
TpTab:CreateButton({ Name = "TP Murderer", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (p.Backpack and p.Backpack:FindFirstChild("Knife")) or (p.Character and p.Character:FindFirstChild("Knife")) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame; break
            end
        end
    end
end })
TpTab:CreateButton({ Name = "TP Sheriff", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (p.Backpack and p.Backpack:FindFirstChild("Gun")) or (p.Character and p.Character:FindFirstChild("Gun")) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame; break
            end
        end
    end
end })

-- 6. FARM
local FarmTab = Window:CreateTab("Farm", 4483362458)
FarmTab:CreateToggle({ Name = "Auto Collect Coins", CurrentValue = false, Callback = function(v) State.AutoCoins = v end })
FarmTab:CreateToggle({ Name = "Auto-Respawn", CurrentValue = false, Callback = function(v) State.AutoRespawn = v end })

-- 7. TROLL
local TrollTab = Window:CreateTab("Troll", 4483362458)
local playerList = {}
local function updateList()
    table.clear(playerList)
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(playerList, p.Name) end end
end
updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
TrollTab:CreateDropdown({ Name = "Fling Target", Options = playerList, CurrentOption = {}, Callback = function(o) State.FlingTarget = o[1] end })
TrollTab:CreateToggle({ Name = "Fling Player", CurrentValue = false, Callback = function(v)
    State.FlingPanel = v
    if v and State.FlingTarget then
        local target = Players:FindFirstChild(State.FlingTarget)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyAngularVelocity", target.Character.HumanoidRootPart)
            bv.AngularVelocity = Vector3.new(9999, 9999, 9999); bv.MaxTorque = Vector3.new(9999, 9999, 9999)
            task.wait(1); bv:Destroy()
        end
    end
end })
TrollTab:CreateToggle({ Name = "Fake Headless", CurrentValue = false, Callback = function(v)
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
end })

-- 8. SERVER
local ServerTab = Window:CreateTab("Server", 4483362458)
ServerTab:CreateButton({ Name = "Rejoin Server", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
ServerTab:CreateButton({ Name = "Server Hop", Callback = function()
    local api = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local response = HttpService:JSONDecode(game:HttpGet(api))
    if #response.data > 0 then
        local target = response.data[math.random(1, #response.data)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer)
    end
end })
ServerTab:CreateButton({ Name = "Copy Job ID", Callback = function() if setclipboard then setclipboard(game.JobId) end end })

-- 9. MOBILE
local MobileUI = Instance.new("ScreenGui", game.CoreGui)
MobileUI.Name = "QovickMobile"
MobileUI.ResetOnSpawn = false
local MobileBtn = Instance.new("TextButton", MobileUI)
MobileBtn.Size = UDim2.new(0, 100, 0, 40)
MobileBtn.Position = UDim2.new(0.5, -50, 0.8, 0)
MobileBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
MobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileBtn.Text = "Kill All"
MobileBtn.Font = Enum.Font.GothamBold
MobileBtn.Visible = false
MobileBtn.Active = true
MobileBtn.Draggable = true

local MobileTab = Window:CreateTab("Mobile", 4483362458)
MobileTab:CreateToggle({ Name = "Show Screen Button", CurrentValue = false, Callback = function(v) MobileBtn.Visible = v end })

-- 10. SETTINGS
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateButton({ Name = "Unload Hub", Callback = function()
    Rayfield:Destroy()
    if MobileUI then MobileUI:Destroy() end
end })
SettingsTab:CreateButton({ Name = "Reset Character Stats", Callback = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end })

-- === ЛОГИКА ===
local Drawings = {}
RunService.RenderStepped:Connect(function()
    if not State.ESP then
        for _, d in pairs(Drawings) do d:Remove() end
        Drawings = {}; return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if (Camera.CFrame.Position - hrp.Position).Magnitude <= State.MaxDist then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    if not Drawings[p] then Drawings[p] = { Text = Drawing.new("Text"), Box = Drawing.new("Square"), Tracer = Drawing.new("Line") } end
                    local d = Drawings[p]
                    d.Text.Visible = State.ESPName
                    if State.ESPName then
                        d.Text.Text = p.Name; d.Text.Color = Color3.fromRGB(255,255,255); d.Text.Size = 16; d.Text.Center = true; d.Text.Outline = true; d.Text.Position = Vector2.new(pos.X, pos.Y - 20)
                    end
                    d.Box.Visible = State.ESPBox
                    if State.ESPBox then
                        d.Box.Color = Color3.fromRGB(255, 50, 50); d.Box.Thickness = 1; d.Box.Size = Vector2.new(50, 80); d.Box.Position = Vector2.new(pos.X - 25, pos.Y - 40)
                    end
                    d.Tracer.Visible = State.ESPTracer
                    if State.ESPTracer then
                        d.Tracer.Color = Color3.fromRGB(255,255,255); d.Tracer.Thickness = 1; d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); d.Tracer.To = Vector2.new(pos.X, pos.Y + 20)
                    end
                else
                    if Drawings[p] then Drawings[p].Text.Visible = false; Drawings[p].Box.Visible = false; Drawings[p].Tracer.Visible = false end
                end
            end
        end
    end
end)

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

Rayfield:Notify({ Title = "Qovick Hub", Content = "Loaded successfully!", Duration = 5 })
