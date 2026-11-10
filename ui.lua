-- QovickUI :: Custom UI Framework
-- No external dependencies. Pure Roblox API.

local QovickUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function QovickUI:CreateWindow(config)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "QovickUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(138, 43, 226)
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.5
    UIStroke.Parent = MainFrame

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Text = config.Name or "Qovick Hub"
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = TopBar

    -- Sidebar (Tabs)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 8)
    SideCorner.Parent = Sidebar

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -10, 1, -10)
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -160, 1, -50)
    ContentArea.Position = UDim2.new(0, 155, 0, 45)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local API = {}
    API.Tabs = {}

    function API:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 14
        TabBtn.Text = "  " .. name
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabContainer
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.Parent = ContentArea

        local PageList = Instance.new("UIListLayout")
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 8)
        PageList.Parent = Page
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingLeft = UDim.new(0, 5)
        PagePadding.PaddingRight = UDim.new(0, 5)
        PagePadding.Parent = Page

        -- Tab switch logic
        local tabAPI = {}
        tabAPI.Page = Page
        tabAPI.Button = TabBtn
        table.insert(API.Tabs, tabAPI)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(API.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
                t.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            Page.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        if #API.Tabs == 1 then
            TabBtn:GetPropertyChangedSignal("Parent"):Connect(function()
                if API.Tabs[1] then
                    Page.Visible = true
                    TabBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
                end
            end)
            task.defer(function()
                Page.Visible = true
                TabBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
                TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
        end

        -- Components inside Tab
        local function baseComponent(height)
            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, 0, 0, height)
            Holder.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
            Holder.BorderSizePixel = 0
            Holder.Parent = Page
            
            local HC = Instance.new("UICorner")
            HC.CornerRadius = UDim.new(0, 6)
            HC.Parent = Holder
            
            return Holder
        end

        function tabAPI:CreateToggle(text, default, callback)
            local Holder = baseComponent(40)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.Parent = Holder
            
            local ToggleBg = Instance.new("Frame")
            ToggleBg.Size = UDim2.new(0, 40, 0, 20)
            ToggleBg.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleBg.BackgroundColor3 = default and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(50, 50, 60)
            ToggleBg.Parent = Holder
            
            local TC = Instance.new("UICorner")
            TC.CornerRadius = UDim.new(1, 0)
            TC.Parent = ToggleBg
            
            local ToggleDot = Instance.new("Frame")
            ToggleDot.Size = UDim2.new(0, 16, 0, 16)
            ToggleDot.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleDot.Parent = ToggleBg
            
            local DC = Instance.new("UICorner")
            DC.CornerRadius = UDim.new(1, 0)
            DC.Parent = ToggleDot
            
            local state = default
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = Holder
            
            Btn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(50, 50, 60)}):Play()
                TweenService:Create(ToggleDot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                if callback then callback(state) end
            end)
        end

        function tabAPI:CreateButton(text, callback)
            local Holder = baseComponent(35)
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 14
            Btn.Parent = Holder
            
            Btn.MouseEnter:Connect(function()
                TweenService:Create(Holder, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Holder, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 42)}):Play()
            end)
            Btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end

        function tabAPI:CreateSlider(text, min, max, default, callback)
            local Holder = baseComponent(50)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.BackgroundTransparency = 1
            Label.Text = text .. ": " .. default
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.Parent = Holder
            
            local BarBg = Instance.new("Frame")
            BarBg.Size = UDim2.new(1, -20, 0, 6)
            BarBg.Position = UDim2.new(0, 10, 0, 30)
            BarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            BarBg.Parent = Holder
            
            local BGC = Instance.new("UICorner")
            BGC.CornerRadius = UDim.new(1, 0)
            BGC.Parent = BarBg
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
            Fill.Parent = BarBg
            
            local FC = Instance.new("UICorner")
            FC.CornerRadius = UDim.new(1, 0)
            FC.Parent = Fill
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = BarBg
            
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

        return tabAPI
    end

    return API
end

return QovickUI
