-- ═══════════════════════════════════════════════════════════════════════════
--  QovickHub v1.3 — UI + ESP + Silent Aim + Fly + Speed + AutoFarm + Fling + Player List
-- ═══════════════════════════════════════════════════════════════════════════

local QOVICKHUB_SOURCE = [==[
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local GuiService       = game:GetService("GuiService")
local TextService      = game:GetService("TextService")

if getgenv and getgenv().QOVICKHUB_CLEANUP then pcall(getgenv().QOVICKHUB_CLEANUP) end
local CONNS = {}
local function keep(c) table.insert(CONNS, c) return c end
local function sig(s) return { Connect = function(_, fn) return keep(s:Connect(fn)) end } end
if getgenv then
    getgenv().QOVICKHUB_CLEANUP = function()
        for _, c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
        table.clear(CONNS)
    end
end

local Lucide
pcall(function()
    Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua"))()
end)

local T = {
    root = Color3.fromRGB(18, 20, 27), panel = Color3.fromRGB(24, 27, 36),
    panelHover = Color3.fromRGB(32, 36, 47), inset = Color3.fromRGB(21, 23, 31),
    stroke = Color3.fromRGB(44, 49, 62), strokeSoft = Color3.fromRGB(36, 40, 51),
    text = Color3.fromRGB(240, 244, 250), sub = Color3.fromRGB(168, 178, 196),
    dim = Color3.fromRGB(116, 126, 145), faint = Color3.fromRGB(86, 94, 110),
    descText = Color3.fromRGB(126, 136, 154), star = Color3.fromRGB(94, 234, 176),
    onTrack = Color3.fromRGB(94, 234, 176), onKnob = Color3.fromRGB(14, 18, 24),
    offTrack = Color3.fromRGB(54, 60, 74), offKnob = Color3.fromRGB(240, 244, 250),
}

local FAMILIES = {
    ["Builder Sans"] = { Enum.Font.BuilderSans, Enum.Font.BuilderSansMedium, Enum.Font.BuilderSansBold },
    ["Gotham"]       = { Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold },
    ["Source Sans"]  = { Enum.Font.SourceSans, Enum.Font.SourceSansSemibold, Enum.Font.SourceSansBold },
    ["Ubuntu"]       = { Enum.Font.Ubuntu, Enum.Font.Ubuntu, Enum.Font.Ubuntu },
}
local FAMILY_ORDER = { "Builder Sans", "Gotham", "Source Sans", "Ubuntu" }
local FONT_REG, FONT, FONT_BOLD = table.unpack(FAMILIES["Builder Sans"])

local MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local TEXT_SCALE = MOBILE and 1.42 or 1.15
local ROW_H = MOBILE and 78 or 62
local ROW_H_COMPACT = MOBILE and 58 or 44
local CAT_H = MOBILE and 52 or 40
local SEARCH_H = MOBILE and 54 or 42
local TRACK_W = MOBILE and 52 or 38
local TRACK_H = MOBILE and 28 or 22
local KNOB_D = MOBILE and 20 or 16
local KNOB_PAD = MOBILE and 4 or 3
local KNOB_ON = TRACK_W - KNOB_D - KNOB_PAD
local HIT = MOBILE and 34 or 24
local GLYPH = MOBILE and 36 or 24
local CHIP_H = MOBILE and 28 or 22
local CHIP_PAD = MOBILE and 12 or 10
local CHIP_MIN = CHIP_H + 10

local function lum(c) return 0.299 * c.R + 0.587 * c.G + 0.114 * c.B end
local function contrastKnob(track) return lum(track) > 0.5 and Color3.fromRGB(26, 26, 26) or Color3.fromRGB(240, 240, 240) end

local EASE = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local OPEN = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local CLOSE = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local WIN_FADE = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ANIM = { on = true }
local BLOCKED = { on = false }
local function tw(o, ti, p)
    if not ANIM.on then for k, v in pairs(p) do pcall(function() o[k] = v end) end; return nil end
    local t = TweenService:Create(o, ti, p); t:Play(); return t
end

local KEY_SHORT = {
    LeftShift = "LSHIFT", RightShift = "RSHIFT", LeftControl = "LCTRL", RightControl = "RCTRL",
    LeftAlt = "LALT", RightAlt = "RALT", Space = "SPACE", Backspace = "BSPACE",
    Return = "ENTER", Delete = "DEL", Insert = "INS", PageUp = "PGUP", PageDown = "PGDN",
    CapsLock = "CAPS", Tab = "TAB", Up = "UP", Down = "DOWN", Left = "LEFT", Right = "RIGHT",
    MouseButton1 = "LMB", MouseButton2 = "RMB", MouseButton3 = "MMB",
    MouseWheelUp = "WHEELUP", MouseWheelDown = "WHEELDN",
}
local function spaceName(s) s = s:gsub("(%l)(%u)", "%1 %2"); s = s:gsub("(%u)(%u%l)", "%1 %2"); return s end
local function keyLabel(name) if not name then return nil end; return KEY_SHORT[name] or name:upper() end

local SQUIRCLE = { img = "rbxassetid://89641024074289", rect = Rect.new(460,460,460,460), radius = 310 }
local SQ_OUTLINE = { img = "rbxassetid://74029063732681", rect = Rect.new(512,512,512,512), radius = 310 }

local NAME_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local function randName(min, max)
    local n = math.random(min or 12, max or 22)
    local b = table.create(n)
    for i = 1, n do local k = math.random(1, #NAME_CHARS); b[i] = NAME_CHARS:sub(k, k) end
    return table.concat(b)
end

local BASE_PROPS = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency", "ImageTransparency", "ScrollBarImageTransparency", "Transparency" }
local BASE_BY_CLASS = {}
local function basePropsFor(class)
    local list = BASE_BY_CLASS[class]; if list then return list end
    list = {}
    local made, probe = pcall(Instance.new, class)
    if made then
        for i = 1, #BASE_PROPS do
            local prop = BASE_PROPS[i]
            local ok, v = pcall(function() return probe[prop] end)
            if ok and type(v) == "number" then list[#list + 1] = { prop, "_base_" .. prop } end
        end
        probe:Destroy(); BASE_BY_CLASS[class] = list
    end
    return list
end
local function recordBase(o)
    local list = basePropsFor(o.ClassName)
    for i = 1, #list do local e = list[i]; o:SetAttribute(e[2], o[e[1]]) end
end
local function new(class, props, kids)
    local o = Instance.new(class); o.Name = randName()
    for k, v in pairs(props or {}) do if k ~= "Parent" then o[k] = v end end
    recordBase(o)
    for _, c in ipairs(kids or {}) do c.Parent = o end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function mountPoint()
    if typeof(gethui) == "function" then local ok, h = pcall(gethui); if ok and typeof(h) == "Instance" then return h end end
    if typeof(get_hidden_gui) == "function" then local ok, h = pcall(get_hidden_gui); if ok and typeof(h) == "Instance" then return h end end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then local ok2 = pcall(function() return #cg:GetChildren() end); if ok2 then return cg end end
    local lp = Players.LocalPlayer
    return lp and lp:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")
end
local function protect(gui)
    local fns = {}
    if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then fns[#fns + 1] = syn.protect_gui end
    if typeof(protectgui) == "function" then fns[#fns + 1] = protectgui end
    if typeof(protect_gui) == "function" then fns[#fns + 1] = protect_gui end
    for _, fn in ipairs(fns) do if pcall(fn, gui) then return end end
end

local function panel(props, radius)
    radius = radius or 8
    local p = { BackgroundColor3 = T.panel, BorderSizePixel = 0 }
    local class = "Frame"
    for k, v in pairs(props or {}) do if k == "Class" then class = v else p[k] = v end end
    if class == "ImageButton" or class == "TextButton" then p.AutoButtonColor = false; if class == "TextButton" then p.Text = p.Text or "" end end
    local o = new(class, p)
    new("UICorner", { CornerRadius = UDim.new(0, radius), Parent = o })
    return o
end
local function stroke(parent, color, radius, transparency)
    local st = new("UIStroke", { Color = color or T.stroke, Thickness = 1, Transparency = transparency or 0.25, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent })
    st:SetAttribute("BaseTransparency", st.Transparency); return st
end
local function text(props)
    local p = { BackgroundTransparency = 1, Font = FONT, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center }
    for k, v in pairs(props or {}) do p[k] = v end
    local base = p.TextSize or 14
    p.TextSize = math.floor(base * TEXT_SCALE + 0.5)
    local o = new("TextLabel", p)
    o:SetAttribute("FontRole", p.Font == FONT_BOLD and "bold" or (p.Font == FONT_REG and "reg" or "med"))
    o:SetAttribute("BaseTextSize", base)
    return o
end

local iconCache = {}
local function iconAsset(name) local a = iconCache[name]; if a == nil then a = (Lucide and Lucide.GetAsset(name)) or false; iconCache[name] = a end; return a or nil end
local function setIcon(im, name) local a = iconAsset(name); if a then im.Image = a.Url; im.ImageRectOffset = a.ImageRectOffset; im.ImageRectSize = a.ImageRectSize end; return im end
local function icon(name, props)
    local p = { BackgroundTransparency = 1, ImageColor3 = T.dim, Size = UDim2.fromOffset(24, 24) }
    for k, v in pairs(props or {}) do p[k] = v end
    return setIcon(new("ImageLabel", p), name)
end

local SCROLLERS = {}
local SMOOTH = { scroll = true, drag = false }
local WHEEL_IMPULSE, SCROLL_DECAY, SCROLL_MAX_VEL = 950, 7, 9000
local function shownOnScreen(o) local node = o; while node and node:IsA("GuiObject") do if not node.Visible then return false end; node = node.Parent end; return node ~= nil end
local function scrollerAt(x, y)
    local best, bestZ = nil, -math.huge
    for i = 1, #SCROLLERS do local e = SCROLLERS[i]; local sf = e.sf
        if sf.Parent and not e.frozen and shownOnScreen(sf) then local p, sz = sf.AbsolutePosition, sf.AbsoluteSize
            if x >= p.X and x <= p.X + sz.X and y >= p.Y and y <= p.Y + sz.Y then if sf.ZIndex >= bestZ then best, bestZ = e, sf.ZIndex end end
        end
    end
    return best
end
local function maxScroll(sf, horiz) if horiz then return math.max(0, sf.AbsoluteCanvasSize.X - sf.AbsoluteWindowSize.X) end; return math.max(0, sf.AbsoluteCanvasSize.Y - sf.AbsoluteWindowSize.Y) end
local function stepScrollers(dt)
    local d = math.min(dt, 0.05); local k = math.exp(-SCROLL_DECAY * d)
    for i = 1, #SCROLLERS do local e = SCROLLERS[i]; local sf = e.sf
        if sf.Parent and e.vel and e.vel ~= 0 then local horiz = e.horizontal; local lim = maxScroll(sf, horiz); local cur = horiz and sf.CanvasPosition.X or sf.CanvasPosition.Y; local nxt = cur + e.vel * d; e.vel = e.vel * k
            if nxt <= 0 then nxt, e.vel = 0, 0 elseif nxt >= lim then nxt, e.vel = lim, 0 elseif math.abs(e.vel) < 3 then e.vel = 0 end
            sf.CanvasPosition = horiz and Vector2.new(nxt, 0) or Vector2.new(0, nxt)
        end
    end
end
local function scrollerEntry(sf) for i = 1, #SCROLLERS do if SCROLLERS[i].sf == sf then return SCROLLERS[i] end end end
local function fadeEnds(inst, vertical, head, tail)
    head = head or 0.12; tail = tail or 0.12
    return new("UIGradient", { Rotation = vertical and 90 or 0, Parent = inst, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(head, 0), NumberSequenceKeypoint.new(1 - tail, 0), NumberSequenceKeypoint.new(1, 1) }) })
end
local function customScrollbar(sf, inset)
    sf.ScrollBarThickness = 0
    local bar = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -(inset or 2), 0, 0), Size = UDim2.fromOffset(3, 0), BackgroundColor3 = T.stroke, BackgroundTransparency = 0.25, BorderSizePixel = 0, Visible = false, ZIndex = 30, Parent = sf.Parent })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
    local grad = fadeEnds(bar, true, 0.18, 0.18)
    sf.ScrollingEnabled = true
    SCROLLERS[#SCROLLERS + 1] = { sf = sf, bar = bar, grad = grad, inset = inset or 2 }
    return bar
end
local function updateScrollbars()
    for i = 1, #SCROLLERS do local e = SCROLLERS[i]; local sf, bar = e.sf, e.bar
        if sf.Parent and bar.Parent then local horiz = e.horizontal
            if e.wasHoriz ~= horiz then e.wasHoriz = horiz; e.h, e.pos = nil, nil; bar.AnchorPoint = horiz and Vector2.new(0, 0) or Vector2.new(1, 0); if e.grad then e.grad.Rotation = horiz and 0 or 90 end end
            local view = horiz and sf.AbsoluteWindowSize.X or sf.AbsoluteWindowSize.Y
            local canvas = horiz and sf.AbsoluteCanvasSize.X or sf.AbsoluteCanvasSize.Y
            if canvas <= view + 1 or view < 1 then if bar.Visible then bar.Visible = false end
            else
                local h = math.max(24, math.floor(view * view / canvas)); local at = horiz and sf.CanvasPosition.X or sf.CanvasPosition.Y
                local prog = math.clamp(at / (canvas - view), 0, 1); local rel = sf.AbsolutePosition - sf.Parent.AbsolutePosition
                local p = math.floor((horiz and rel.X or rel.Y) + (view - h) * prog)
                if not bar.Visible then bar.Visible = true end
                if e.h ~= h then e.h = h; bar.Size = horiz and UDim2.fromOffset(h, 3) or UDim2.fromOffset(3, h) end
                if e.pos ~= p then e.pos = p; if horiz then bar.Position = UDim2.fromOffset(p, math.floor(rel.Y + sf.AbsoluteWindowSize.Y - 3 - e.inset)) else bar.Position = UDim2.new(1, -e.inset, 0, p) end end
            end
        end
    end
end

-- ═══ Класс QovickHub ═══
local QovickHub = {}
QovickHub.__index = QovickHub

function QovickHub.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, QovickHub)
    self.cfg = cfg; self.categories, self.tabs, self.allModules = {}, {}, {}; self.sections, self._order = {}, 0
    self.activeCategory, self.activeTab = nil, nil; self.search = ""

    local mount = mountPoint()
    if getgenv and getgenv().__qovick_gui then pcall(function() getgenv().__qovick_gui:Destroy() end) end
    
    self.gui = new("ScreenGui", { ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    protect(self.gui); self.gui.Parent = mount
    if getgenv then getgenv().__qovick_gui = self.gui; getgenv().QovickHub = self end

    local W, H = cfg.Width or 820, cfg.Height or 520
    if MOBILE then
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(900, 500)
        local inset = GuiService:GetGuiInset()
        W = math.floor(math.min(vp.X - 24, 1100)); H = math.floor(math.min(vp.Y - inset.Y - 24, 720))
    end
    self.root = panel({ Class = "Frame", AnchorPoint = Vector2.new(0, 0), Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(W, H), BackgroundColor3 = T.root, BackgroundTransparency = 0, ZIndex = 2, Parent = self.gui }, 10)
    self.rootStroke = stroke(self.root, T.strokeSoft, 10, 0.3)

    function self:Recenter()
        local space = self.gui.AbsoluteSize
        if space.X < 1 then space = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720) end
        local rw, rh = self.root.AbsoluteSize.X, self.root.AbsoluteSize.Y
        if rw < 1 then rw, rh = W, H end
        local inset = GuiService:GetGuiInset(); local usableY = space.Y - inset.Y
        self.root.Position = UDim2.fromOffset(math.floor((space.X - rw) / 2 + 0.5), inset.Y + math.floor((usableY - rh) / 2 + 0.5))
    end
    self:Recenter(); task.defer(function() self:Recenter() end)

    local TOPBAR_H, LOGO_ROW = 86, 52
    local top = new("Frame", { Size = UDim2.new(1, 0, 0, TOPBAR_H), BackgroundTransparency = 1, ZIndex = 3, Parent = self.root })
    local brandRow = new("Frame", { Position = UDim2.fromOffset(22, 0), Size = UDim2.new(0, 0, 0, LOGO_ROW), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, ZIndex = 4, Parent = top })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = brandRow })
    text({ Text = cfg.Title or "QovickHub", Font = FONT_BOLD, TextSize = 18, TextColor3 = T.text, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 1, ZIndex = 4, Parent = brandRow })
    local badge = panel({ Size = UDim2.fromOffset(27, 16), BackgroundColor3 = Color3.fromRGB(48, 48, 48), LayoutOrder = 2, ZIndex = 4, Parent = brandRow }, 4)
    text({ Text = cfg.Version or "v1.0", Font = FONT_BOLD, TextSize = 10, TextColor3 = T.star, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6, Parent = badge })

    local tabHolder = new("Frame", { Position = UDim2.fromOffset(22, LOGO_ROW), Size = UDim2.new(1, -44, 0, TOPBAR_H - LOGO_ROW), BackgroundTransparency = 1, ZIndex = 3, Parent = top })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 30), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabHolder })
    self.tabHolder = tabHolder

    local function iconRow(width, gap)
        local f = new("Frame", { Size = UDim2.fromOffset(width, LOGO_ROW), BackgroundTransparency = 1, ZIndex = 3, Parent = top })
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, gap), Parent = f })
        return f
    end
    local TOOL_W, WIN_W = HIT * 2 + 18, HIT * 3 + 12 * 2
    self.midIcons = iconRow(TOOL_W, 18); self.winIcons = iconRow(WIN_W, 12)
    self.winIcons.Position = UDim2.new(1, -WIN_W - 18, 0, 0)

    local function topIcon(parent, name, cb, hoverColor)
        local b = new("TextButton", { Size = UDim2.fromOffset(HIT, HIT), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = #parent:GetChildren(), ZIndex = 4, Parent = parent })
        local im = icon(name, { Size = UDim2.fromOffset(GLYPH, GLYPH), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ImageColor3 = T.dim, ZIndex = 5, Parent = b })
        b.MouseEnter:Connect(function() if BLOCKED.on then return end; tw(im, FAST, { ImageColor3 = hoverColor or T.text }) end)
        b.MouseLeave:Connect(function() tw(im, FAST, { ImageColor3 = im:GetAttribute("Active") and T.star or T.dim }) end)
        if cb then b.MouseButton1Click:Connect(cb) end
        return b, im
    end
    self.refreshImg = select(2, topIcon(self.midIcons, "refresh-cw", function() self:Reload() end))
    self.layoutImg = select(2, topIcon(self.midIcons, "panels-top-left", function() self:SetCompact(not self.compact) end))
    topIcon(self.winIcons, "minus", function() self:Minimize() end)
    self.fullImg = select(2, topIcon(self.winIcons, "maximize", function() self:ToggleFullscreen() end))
    topIcon(self.winIcons, "x", function() if self.onCloseRequest then self.onCloseRequest() else self:Destroy() end end, Color3.fromRGB(255, 92, 92))

    local topRule = new("Frame", { Position = UDim2.fromOffset(0, TOPBAR_H), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.stroke, BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 5, Parent = self.root })
    new("UIGradient", { Parent = topRule, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.04, 0), NumberSequenceKeypoint.new(0.96, 0), NumberSequenceKeypoint.new(1, 1) }) })

    local SIDE_W = MOBILE and 196 or 205
    local side = new("Frame", { Position = UDim2.fromOffset(0, TOPBAR_H + 13), Size = UDim2.new(0, SIDE_W, 1, -TOPBAR_H - 13), BackgroundTransparency = 1, ZIndex = 3, Parent = self.root })
    self.catHeader = text({ Text = "Категории", Font = FONT_BOLD, TextSize = 16, TextColor3 = T.text, Position = UDim2.fromOffset(18, 4), Size = UDim2.fromOffset(160, 20), ZIndex = 4, Parent = side })
    self.side = side; self.SIDE_W, self.TOPBAR_H = SIDE_W, TOPBAR_H
    side.ClipsDescendants = true
    self.catList = new("ScrollingFrame", { Position = UDim2.fromOffset(8, 42), Size = UDim2.new(0, SIDE_W - 16, 1, -54), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3, Parent = side })
    new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.catList })
    customScrollbar(self.catList)

    local content = new("Frame", { Position = UDim2.fromOffset(SIDE_W, TOPBAR_H + 13), Size = UDim2.new(1, -SIDE_W - 16, 1, -TOPBAR_H - 27), BackgroundTransparency = 1, ZIndex = 3, Parent = self.root })
    local searchBox = panel({ Size = UDim2.new(1, -8, 0, SEARCH_H), BackgroundColor3 = T.inset, ZIndex = 3, Parent = content }, 8)
    self.searchBox = searchBox; stroke(searchBox, T.stroke, 8, 0.55)
    icon("search", { Size = UDim2.fromOffset(24, 24), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 11, 0.5, 0), ImageColor3 = T.dim, ZIndex = 4, Parent = searchBox })
    self.searchInput = new("TextBox", { BackgroundTransparency = 1, Text = "", PlaceholderText = "Поиск модулей...", TextColor3 = T.text, PlaceholderColor3 = T.dim, Font = FONT_REG, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Position = UDim2.fromOffset(42, 0), Size = UDim2.new(1, -54, 1, 0), ZIndex = 4, Parent = searchBox })
    self.searchInput.Focused:Connect(function() if BLOCKED.on then self.searchInput:ReleaseFocus() end end)
    self.searchInput:GetPropertyChangedSignal("Text"):Connect(function() self.search = self.searchInput.Text:lower(); self:Refresh() end)
    self.content = content
    self.edgeStrip = new("Frame", { Position = UDim2.fromOffset(0, TOPBAR_H + 13), Size = UDim2.new(0, 16, 1, -TOPBAR_H - 13), BackgroundTransparency = 1, Visible = false, ZIndex = 8, Parent = self.root })
    self.modList = new("ScrollingFrame", { Position = UDim2.fromOffset(0, 54), Size = UDim2.new(1, 0, 1, -54), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3, Parent = content })
    new("UIPadding", { PaddingRight = UDim.new(0, 8), Parent = self.modList })
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.modList })
    customScrollbar(self.modList)

    local dv = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 5, Parent = self.root })
    self.dividerLine = new("Frame", { Position = UDim2.fromOffset(SIDE_W, TOPBAR_H + 1), Size = UDim2.new(0, 1, 1, -TOPBAR_H - 1), BackgroundColor3 = T.stroke, BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 5, Parent = dv })
    new("UIGradient", { Rotation = 90, Parent = self.dividerLine, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.14, 0), NumberSequenceKeypoint.new(0.94, 0), NumberSequenceKeypoint.new(1, 1) }) })

    self.scrim = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 19, Visible = false, Parent = self.root })
    new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.scrim })
    self.scrim.MouseButton1Click:Connect(function() self:CloseDrawer() end)

    self.drawer = panel({ Class = "TextButton", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 300, 1, 0), BackgroundColor3 = Color3.fromRGB(20, 20, 20), AutoButtonColor = false, ZIndex = 20, Visible = false, Parent = self.root }, 10)
    stroke(self.drawer, T.stroke, 10, 0.3)
    self.drawerTitle = text({ Text = "Настройки", Font = FONT_BOLD, TextSize = 16, TextColor3 = T.text, Position = UDim2.fromOffset(44, 0), Size = UDim2.fromOffset(180, 46), ZIndex = 21, Parent = self.drawer })
    local backBtn = new("TextButton", { Size = UDim2.fromOffset(HIT, HIT), Position = UDim2.fromOffset(14, 11), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 22, Parent = self.drawer })
    local backImg = icon("arrow-left", { Size = UDim2.fromOffset(GLYPH, GLYPH), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ImageColor3 = T.sub, ZIndex = 23, Parent = backBtn })
    backBtn.MouseEnter:Connect(function() tw(backImg, FAST, { ImageColor3 = T.text }) end)
    backBtn.MouseLeave:Connect(function() tw(backImg, FAST, { ImageColor3 = T.sub }) end)
    backBtn.MouseButton1Click:Connect(function() self:CloseDrawer() end)

    self.drawerBody = new("ScrollingFrame", { Position = UDim2.fromOffset(14, 50), Size = UDim2.new(1, -28, 1, -62), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 21, Parent = self.drawer })
    new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.drawerBody })
    customScrollbar(self.drawerBody)

    self.root.BackgroundTransparency = 0
    if self.rootStroke then self.rootStroke.Transparency = 0 end
    task.delay(5, function() if not self._presented and not self._destroyed then self:Present() end end)

    self.root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if not self.midIcons then return end
        self.midIcons.Position = UDim2.fromOffset(math.floor((self.root.AbsoluteSize.X - self.midIcons.AbsoluteSize.X) / 2 + 0.5), 0)
    end)

    keep(RunService.Heartbeat:Connect(function(dt)
        if self._dragGoal then
            local c = self._dragCur
            if not c then c = { X = self.root.Position.X.Offset, Y = self.root.Position.Y.Offset }; self._dragCur = c end
            local a = 1 - math.exp(-26 * math.min(dt, 0.05))
            c.X = c.X + (self._dragGoal.X - c.X) * a; c.Y = c.Y + (self._dragGoal.Y - c.Y) * a
            if math.abs(self._dragGoal.X - c.X) < 0.35 and math.abs(self._dragGoal.Y - c.Y) < 0.35 then
                c.X, c.Y = self._dragGoal.X, self._dragGoal.Y
                if not self._dragging then self._dragGoal = nil; self._dragCur = nil end
            end
            local px, py = math.floor(c.X + 0.5), math.floor(c.Y + 0.5)
            if self.root.Position.X.Offset ~= px or self.root.Position.Y.Offset ~= py then self.root.Position = UDim2.fromOffset(px, py) end
        end
        if self.minimized or not self.root.Visible or not self.gui.Enabled then return end
        if SMOOTH.scroll then stepScrollers(dt) end
        updateScrollbars()
    end))

    local SINK = "QovickWheelSink"; local sunk = false
    local function setSink(on)
        if on == sunk then return end; sunk = on
        if on then ContextActionService:BindActionAtPriority(SINK, function() return Enum.ContextActionResult.Sink end, false, Enum.ContextActionPriority.High.Value + 200, Enum.UserInputType.MouseWheel)
        else pcall(function() ContextActionService:UnbindAction(SINK) end) end
    end
    self._releaseWheel = function() setSink(false) end

    local sinkAt = 0
    keep(RunService.Heartbeat:Connect(function()
        if self._destroyed or self.minimized or not self.root.Visible or not self.gui.Enabled then setSink(false); return end
        local now = os.clock(); if now - sinkAt < 0.05 then return end; sinkAt = now
        local m = UserInputService:GetMouseLocation(); local ins = GuiService:GetGuiInset()
        local e = scrollerAt(m.X - ins.X, m.Y - ins.Y)
        setSink(e ~= nil and (SMOOTH.scroll or e.horizontal ~= nil))
    end))

    keep(UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseWheel then return end
        if self.minimized or not self.root.Visible or not self.gui.Enabled then return end
        local m = UserInputService:GetMouseLocation(); local ins = GuiService:GetGuiInset()
        local e = scrollerAt(m.X - ins.X, m.Y - ins.Y); if not e then return end
        if SMOOTH.scroll then e.vel = math.clamp((e.vel or 0) - i.Position.Z * WHEEL_IMPULSE, -SCROLL_MAX_VEL, SCROLL_MAX_VEL)
        elseif e.horizontal then local sf = e.sf; sf.CanvasPosition = Vector2.new(math.clamp(sf.CanvasPosition.X - i.Position.Z * 60, 0, maxScroll(sf, true)), 0) end
    end))

    self:_drag(top); self:_bindInput()
    self._sideShown = true
    self:SetLayout({ side = "Left", search = "Top" }, false)
    self:_buildUISettings(); self:_buildPages(); self:_buildNotifications(); self:_buildTour(); self:_buildBadge()
    return self
end

function QovickHub:_buildPages()
    local function makePage(name)
        local f = new("Frame", { Size = UDim2.new(1, -self.SIDE_W - 16, 1, -self.TOPBAR_H - 27), Position = UDim2.fromOffset(self.SIDE_W, self.TOPBAR_H + 13), BackgroundTransparency = 1, Visible = false, ZIndex = 1, Parent = self.root })
        text({ Text = name, Font = FONT_BOLD, TextSize = 24, TextColor3 = T.text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(200, 40), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 2, Parent = f })
        return f
    end
    self.pagePlayers = makePage("Players")
    self.pageServer = makePage("Server")
    self.pageConfigs = makePage("Configs")
    self.pageSettings = makePage("Settings")
    self.pageCredits = makePage("Credits")
end

function QovickHub:_bindInput()
    sig(UserInputService.InputBegan):Connect(function(input, processed)
        if not self.gui or not self.gui.Parent then return end
        local name; local t = input.UserInputType
        if t == Enum.UserInputType.Keyboard then name = input.KeyCode.Name
        elseif t == Enum.UserInputType.MouseButton1 then name = "MouseButton1"
        elseif t == Enum.UserInputType.MouseButton2 then name = "MouseButton2"
        elseif t == Enum.UserInputType.MouseButton3 then name = "MouseButton3"
        elseif t == Enum.UserInputType.MouseWheel then name = (input.Position.Z > 0) and "MouseWheelUp" or "MouseWheelDown"
        elseif input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then name = input.KeyCode.Name
        else return end
        if self.listeningCfg then
            local cfg = self.listeningCfg; self.listeningCfg = nil
            if name ~= "Escape" then cfg.Value = name; if cfg.Callback then task.spawn(cfg.Callback, name) end end
            if cfg._repaint then cfg._repaint() end; return
        end
        if BLOCKED.on and not self.listening then return end
        if self.listening then
            local m = self.listening; self:_listen(nil)
            if name == "MouseButton2" or name == "MouseButton3" then m._eatClear = true end
            m:SetBind(name ~= "Escape" and name or nil); return
        end
        if processed then return end
        for _, m in ipairs(self.allModules) do
            if m.bind == name and m.row.Parent then
                if m.action then if m.callback then task.spawn(m.callback, true) end
                elseif m.hold then m:Toggle(true)
                else m:Toggle() end
            end
        end
    end)
    sig(UserInputService.InputEnded):Connect(function(input)
        if not self.gui or not self.gui.Parent then return end
        local name; local t = input.UserInputType
        if t == Enum.UserInputType.Keyboard then name = input.KeyCode.Name
        elseif t == Enum.UserInputType.MouseButton1 then name = "MouseButton1"
        elseif t == Enum.UserInputType.MouseButton2 then name = "MouseButton2"
        elseif t == Enum.UserInputType.MouseButton3 then name = "MouseButton3"
        else return end
        for _, m in ipairs(self.allModules) do if m.hold and m.bind == name and m.row.Parent then m:Toggle(false) end end
    end)
end

function QovickHub:_drag(handle, target)
    target = target or self.root
    local dragging, sp, so
    handle.InputBegan:Connect(function(i)
        if target == self.root and self.fullscreen then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging, sp, so = true, i.Position, target.Position; if target == self.root then self._dragging = true end end
    end)
    sig(UserInputService.InputEnded):Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false; self._dragging = false end end)
    sig(UserInputService.InputChanged):Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - sp
            if SMOOTH.drag and target == self.root then
                if not self._dragCur then self._dragCur = { X = target.Position.X.Offset, Y = target.Position.Y.Offset } end
                self._dragGoal = { X = so.X.Offset + d.X, Y = so.Y.Offset + d.Y }
            else target.Position = UDim2.new(so.X.Scale, math.floor(so.X.Offset + d.X + 0.5), so.Y.Scale, math.floor(so.Y.Offset + d.Y + 0.5)) end
        end
    end)
end

function QovickHub:Tab(name)
    local TAB_BASE = 15
    local btn = new("TextButton", { BackgroundTransparency = 1, AutoButtonColor = false, Text = name, Font = FONT, TextColor3 = T.dim, TextSize = math.floor(TAB_BASE * TEXT_SCALE + 0.5), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = #self.tabs + 1, ZIndex = 5, Parent = self.tabHolder })
    btn:SetAttribute("BaseTextSize", TAB_BASE); btn:SetAttribute("FontRole", "med")
    local tab = { name = name, button = btn }; table.insert(self.tabs, tab)
    btn.MouseEnter:Connect(function() if BLOCKED.on then return end; if self.activeTab ~= tab then tw(btn, FAST, { TextColor3 = T.sub }) end end)
    btn.MouseLeave:Connect(function() if self.activeTab ~= tab then tw(btn, FAST, { TextColor3 = T.dim }) end end)
    btn.MouseButton1Click:Connect(function() if BLOCKED.on then return end; self:SelectTab(tab) end)
    if #self.tabs == 1 then task.defer(function() self:SelectTab(tab) end) end
    return tab
end

function QovickHub:SelectTab(tab)
    local changed = self.activeTab ~= tab
    if self.activeTab and changed then tw(self.activeTab.button, FAST, { TextColor3 = T.dim }) end
    self.activeTab = tab; tw(tab.button, EASE, { TextColor3 = T.text })
    if not changed then return end
    local function show()
        local mods = tab.name == "Modules"
        if self.side then self.side.Visible = mods and (self._sideShown ~= false) end
        if self.content then self.content.Visible = mods end
        self:_setDivider(mods and (self._sideShown ~= false) and self.layout and self.layout.side ~= "Bottom", false)
        if self.pagePlayers then self.pagePlayers.Visible = tab.name == "Players" end
        if self.pageServer then self.pageServer.Visible = tab.name == "Server" end
        if self.pageConfigs then self.pageConfigs.Visible = tab.name == "Configs" end
        if self.pageSettings then self.pageSettings.Visible = tab.name == "Settings" end
        if self.pageCredits then self.pageCredits.Visible = tab.name == "Credits" end
    end
    local leavingModules = self._activePage == self.content
    local current = self._activePage
    if current then self:_fade(current, 1, FAST) end
    if leavingModules and self.side and self.side.Visible then self:_fade(self.side, 1, FAST); self:_setDivider(false, true) end
    task.delay(current and 0.10 or 0, function()
        if self.activeTab ~= tab then return end
        show()
        local page = (tab.name == "Players" and self.pagePlayers) or (tab.name == "Server" and self.pageServer) or (tab.name == "Configs" and self.pageConfigs) or (tab.name == "Settings" and self.pageSettings) or (tab.name == "Credits" and self.pageCredits) or self.content
        self._activePage = page
        if tab.name == "Configs" and self._refreshConfigs then self._refreshConfigs() end
        if tab.name == "Server" and self._refreshServer then self._refreshServer() end
        if tab.name == "Settings" and self._refreshSettings then self._refreshSettings() end
        if page then self:_setFade(page, 1); self:_fade(page, 0, OPEN) end
        if tab.name == "Modules" and self.side then self:_setFade(self.side, 1); self:_fade(self.side, 0, OPEN) end
    end)
end

function QovickHub:Category(name, iconName)
    local cat = { name = name, icon = iconName, modules = {}, ui = self }
    local btn = panel({ Class = "ImageButton", Size = UDim2.new(1, 0, 0, CAT_H), BackgroundColor3 = T.panel, BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 4, LayoutOrder = #self.categories + 1, Parent = self.catList }, 6)
    local ico = icon(iconName or "box", { Size = UDim2.fromOffset(24, 24), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), ImageColor3 = T.faint, ZIndex = 6, Parent = btn })
    local lbl = text({ Text = name, TextSize = 15, TextColor3 = T.dim, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 40, 0.5, 0), Size = UDim2.new(1, -104, 0, 18), ZIndex = 6, Parent = btn })
    local chev = text({ Text = "›", TextSize = 16, TextColor3 = T.faint, Font = FONT_REG, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, -1), Size = UDim2.fromOffset(8, 18), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6, Parent = btn })
    local count = text({ Text = "", TextSize = 12, TextColor3 = T.faint, Font = FONT_REG, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -30, 0.5, 0), Size = UDim2.fromOffset(24, 16), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 6, Parent = btn })
    cat.button, cat.iconImg, cat.label, cat.countLabel = btn, ico, lbl, count
    btn.MouseEnter:Connect(function() if BLOCKED.on then return end; if self.activeCategory ~= cat then tw(btn, FAST, { BackgroundTransparency = 0.55 }) end end)
    btn.MouseLeave:Connect(function() if self.activeCategory ~= cat then tw(btn, FAST, { BackgroundTransparency = 1 }) end end)
    btn.MouseButton1Click:Connect(function() if BLOCKED.on then return end; self:SelectCategory(cat) end)

    function cat:Section(name)
        local ui = self.ui; ui._order = ui._order + 1
        local row = new("Frame", { Size = UDim2.new(1, 0, 0, MOBILE and 34 or 28), BackgroundTransparency = 1, LayoutOrder = ui._order, Visible = false, ZIndex = 4, Parent = ui.modList })
        local lbl = text({ Text = name, Font = FONT_BOLD, TextSize = 12, TextColor3 = T.sub, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 22, 1, -6), Size = UDim2.new(1, -44, 0, 16), ZIndex = 5, Parent = row })
        local rule = new("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -14, 1, -11), Size = UDim2.new(1, -44 - math.ceil(lbl.TextBounds.X), 0, 1), BackgroundColor3 = T.stroke, BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 5, Parent = row })
        fadeEnds(rule, false, 0.02, 0.16)
        local sec = { name = name, row = row, label = lbl, rule = rule, cat = cat, modules = {} }
        table.insert(ui.sections, sec); cat._section = sec; ui:_captureBase(row); return sec
    end
    function cat:Module(opts) return self.ui:_module(self, opts) end
    function cat:Adopt(m)
        for _, e in ipairs(cat.modules) do if e == m then return m end end
        table.insert(cat.modules, m); m.categories = m.categories or {}; table.insert(m.categories, cat); self.ui:_updateCounts(); return m
    end
    function cat:Drop(m)
        for i = #cat.modules, 1, -1 do if cat.modules[i] == m then table.remove(cat.modules, i) end end
        for i = #(m.categories or {}), 1, -1 do if m.categories[i] == cat then table.remove(m.categories, i) end end
        self.ui:_updateCounts(); return m
    end
    self:_captureBase(btn); table.insert(self.categories, cat)
    if name == "Favorites" then self.favCategory = cat; btn.Visible = false end
    if not self._bootstrapped then
        self._bootstrapped = true
        task.defer(function() if self.activeCategory then return end; for _, c in ipairs(self.categories) do if c.button.Visible then self:SelectCategory(c) return end end end)
    end
    return cat
end

function QovickHub:_syncFavorites()
    local fav = self.favCategory; if not fav then return end
    local any = #fav.modules > 0; fav.button.Visible = any
    if not any and self.activeCategory == fav then for _, c in ipairs(self.categories) do if c ~= fav then self:SelectCategory(c) break end end end
    self:Refresh()
end

function QovickHub:SelectCategory(cat)
    if self.activeCategory == cat then return end
    local prev = self.activeCategory; self.activeCategory = cat
    if prev then tw(prev.button, FAST, { BackgroundTransparency = 1 }); tw(prev.label, FAST, { TextColor3 = T.dim }); tw(prev.iconImg, FAST, { ImageColor3 = T.faint }) end
    tw(cat.button, EASE, { BackgroundTransparency = 0 }); tw(cat.label, EASE, { TextColor3 = T.text }); tw(cat.iconImg, EASE, { ImageColor3 = (cat.name == "Favorites") and T.star or T.text })
    self:Refresh(true)
end

function QovickHub:_module(cat, opts)
    opts = opts or {}
    local m = { name = opts.Name or "Module", desc = opts.Desc or "", bind = opts.Bind, state = opts.Default and true or false, callback = opts.Callback, settings = {}, category = cat, action = opts.Action and true or false, hold = opts.Hold and true or false, info = opts.Info }
    m.categories = { cat }; self._order = self._order + 1
    local row = panel({ Class = "ImageButton", Size = UDim2.new(1, 0, 0, ROW_H), BackgroundColor3 = T.panel, AutoButtonColor = false, LayoutOrder = self._order, ZIndex = 4, Parent = self.modList }, 8)
    m.section = cat._section; if m.section then table.insert(m.section.modules, m) end
    m.display = spaceName(m.name)
    local title = text({ Text = m.display, TextSize = 14, Font = FONT, TextColor3 = T.sub, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 22, 0.5, 0), Size = UDim2.fromOffset(150, 16), ZIndex = 6, Parent = row })
    local desc = text({ Text = m.desc, TextSize = 12, Font = FONT_REG, TextColor3 = T.descText, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 190, 0.5, 0), Size = UDim2.new(1, -190 - 200, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6, Parent = row })
    local dots = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -math.floor(HIT / 2), 0.5, 0), Size = UDim2.fromOffset(HIT, HIT), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 7, Parent = row })
    local dotsImg = icon("ellipsis-vertical", { Size = UDim2.fromOffset(GLYPH, GLYPH), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ImageColor3 = T.faint, ZIndex = 8, Parent = dots })
    local STAR_X = HIT + 14; local TRACK_X = STAR_X + HIT + 6; local CHIP_X = TRACK_X + TRACK_W + 10
    local star = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -STAR_X, 0.5, 0), Size = UDim2.fromOffset(HIT, HIT), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 7, Parent = row })
    local starImg = icon("star", { Size = UDim2.fromOffset(GLYPH, GLYPH), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ImageColor3 = T.faint, ZIndex = 8, Parent = star })
    local track = panel({ Class = "ImageButton", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -TRACK_X, 0.5, 0), Size = UDim2.fromOffset(TRACK_W, TRACK_H), BackgroundColor3 = T.offTrack, AutoButtonColor = false, ZIndex = 7, Parent = row }, math.floor(TRACK_H / 2))
    stroke(track, T.stroke, math.floor(TRACK_H / 2), 0.45)
    local knob = panel({ AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, KNOB_PAD, 0.5, 0), Size = UDim2.fromOffset(KNOB_D, KNOB_D), BackgroundColor3 = T.offKnob, ZIndex = 8, Parent = track }, math.floor(KNOB_D / 2))
    local chip = panel({ AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -CHIP_X, 0.5, 0), Size = UDim2.fromOffset(CHIP_MIN, CHIP_H), BackgroundColor3 = Color3.fromRGB(44, 44, 44), Visible = not MOBILE, ZIndex = 7, Parent = row }, 6)
    local chipLbl = text({ Text = "", TextSize = 12, Font = FONT_REG, TextColor3 = T.sub, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 8, Parent = chip })
    local chipIcon = icon("keyboard", { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ImageColor3 = T.faint, ZIndex = 8, Parent = chip })
    local function chipWidth(str) if not str or str == "" then return CHIP_MIN end; local ok, sz = pcall(function() return TextService:GetTextSize(str, chipLbl.TextSize, chipLbl.Font, Vector2.new(1000, 100)) end); local w = ok and sz.X or (#str * chipLbl.TextSize * 0.6); return math.max(CHIP_MIN, math.ceil(w) + CHIP_PAD * 2) end
    local chipBtn = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 9, Parent = chip })
    local function paint(animate)
        local ti = animate and EASE or TweenInfo.new(0)
        tw(title, ti, { TextColor3 = m.state and T.text or T.sub }); tw(desc, ti, { TextColor3 = m.state and T.sub or T.descText })
        tw(track, ti, { BackgroundColor3 = m.state and T.onTrack or T.offTrack }); tw(knob, ti, { BackgroundColor3 = m.state and contrastKnob(T.onTrack) or T.offKnob, Position = UDim2.new(0, m.state and KNOB_ON or KNOB_PAD, 0.5, 0) })
    end
    paint(false)
    local function set(v, fire)
        v = v and true or false; if m.state == v then return end; m.state = v; paint(true); cat.ui:_updateCounts()
        if fire and m.callback then task.spawn(m.callback, v) end
        if fire and self.onStateChanged then task.spawn(self.onStateChanged, m, v) end
    end
    if m.action then
        track.Visible = false; chip.Position = UDim2.new(1, -TRACK_X, 0.5, 0)
        row.MouseButton1Click:Connect(function() tw(title, FAST, { TextColor3 = T.text }); task.delay(0.16, function() tw(title, FAST, { TextColor3 = T.sub }) end); if m.callback then task.spawn(m.callback, true) end end)
    else
        track.MouseButton1Click:Connect(function() set(not m.state, true) end)
        row.MouseButton1Click:Connect(function() if BLOCKED.on then return end; set(not m.state, true) end)
    end
    row.MouseEnter:Connect(function() if BLOCKED.on then return end; tw(row, FAST, { BackgroundColor3 = T.panelHover }) end)
    row.MouseLeave:Connect(function() tw(row, FAST, { BackgroundColor3 = T.panel }) end)
    dots.MouseEnter:Connect(function() if BLOCKED.on then return end; tw(dotsImg, FAST, { ImageColor3 = T.text }) end)
    dots.MouseLeave:Connect(function() tw(dotsImg, FAST, { ImageColor3 = T.faint }) end)
    dots.MouseButton1Click:Connect(function() self:OpenDrawer(m) end)
    local function paintStar() tw(starImg, FAST, { ImageColor3 = m.favorite and T.star or T.faint }) end
    star.MouseEnter:Connect(function() if BLOCKED.on then return end; if not m.favorite then tw(starImg, FAST, { ImageColor3 = T.sub }) end end)
    star.MouseLeave:Connect(paintStar)
    star.MouseButton1Click:Connect(function() m:SetFavorite(not m.favorite) end)
    local function paintChip() local listening = self.listening == m; local label = listening and "..." or keyLabel(m.bind); chipLbl.Text = label or ""; chipIcon.Visible = label == nil; chip.Size = UDim2.fromOffset(chipWidth(label), CHIP_H); tw(chipLbl, FAST, { TextColor3 = listening and T.star or T.sub }) end
    chipBtn.MouseEnter:Connect(function() if self.listening ~= m and not m.bind then tw(chipIcon, FAST, { ImageColor3 = T.sub }) end end)
    chipBtn.MouseLeave:Connect(function() tw(chipIcon, FAST, { ImageColor3 = T.faint }); paintChip() end)
    chipBtn.MouseButton1Click:Connect(function() if self.listening == m then self:_listen(nil) else self:_listen(m) end end)
    chipBtn.MouseButton2Click:Connect(function() if m._eatClear then m._eatClear = nil return end; if self.listening == m then self:_listen(nil) return end; if not m.bind then return end; m:SetBind(nil) end)
    self:_captureBase(row)
    m.row, m.titleLbl, m.descLbl, m.chip, m.chipLbl = row, title, desc, chip, chipLbl
    m.starImg, m._paintChip, m._paintStar = starImg, paintChip, paintStar; m._paint = paint
    function m:Get() return m.state end
    function m:Toggle(v) if v == nil then v = not m.state end; set(v and true or false, true) end
    function m:SetDesc(t) m.desc = t; desc.Text = t end
    function m:SetBind(k) if k then for _, o in ipairs(self.ui and self.ui.allModules or {}) do if o ~= m and o.bind == k then o:SetBind(nil) end end end; m.bind = k; paintChip() end
    function m:SetFavorite(v) v = v and true or false; if m.favorite == v then return end; m.favorite = v; local fav = cat.ui.favCategory; if fav and fav ~= cat then if v then fav:Adopt(m) else fav:Drop(m) end end; paintStar(); cat.ui:_syncFavorites() end
    function m:Setting(cfg) table.insert(m.settings, cfg); return m end
    m.ui = self
    table.insert(cat.modules, m); table.insert(self.allModules, m)
    if opts.Favorite then task.defer(function() m:SetFavorite(true) end) end
    paintChip(); self:_updateCounts(); self:Refresh()
    return m
end

function QovickHub:_listen(m) local prev = self.listening; self.listening = m; if prev and prev._paintChip then prev._paintChip() end; if m then if self.searchInput then self.searchInput:ReleaseFocus() end; if m._paintChip then m._paintChip() end end end
function QovickHub:_updateCounts() for _, cat in ipairs(self.categories) do local n = 0; for _, m in ipairs(cat.modules) do if m.state and not m.action then n = n + 1 end end; cat.countLabel.Text = n > 0 and tostring(n) or "" end end
function QovickHub:Refresh(animate)
    local q = self.search; local shown = 0
    for _, m in ipairs(self.allModules) do
        local match = (q == "") or m.name:lower():find(q, 1, true) or (m.display or m.name):lower():find(q, 1, true) or m.desc:lower():find(q, 1, true)
        local inActive = false; for _, c in ipairs(m.categories) do if c == self.activeCategory then inActive = true break end end
        local show = match and (q ~= "" or inActive); m.row.Visible = show and true or false
        if show then shown = shown + 1; if animate then local idx = shown; self:_setFade(m.row, 1); task.delay(math.min(idx, 6) * 0.014, function() if m.row.Parent then self:_fade(m.row, 0, EASE) end end) end end
    end
    for _, sec in ipairs(self.sections) do local any = false; for _, m in ipairs(sec.modules) do if m.row.Visible then any = true break end end; sec.row.Visible = any end
end

local function baseOf(c, prop) local v = c:GetAttribute("_base_" .. prop); if v ~= nil then return v end; recordBase(c); v = c:GetAttribute("_base_" .. prop); if v ~= nil then return v end; local ok, cur = pcall(function() return c[prop] end); return (ok and type(cur) == "number") and cur or 0 end
local P_TEXT = { "TextTransparency", "TextStrokeTransparency", "BackgroundTransparency" }
local P_IMAGE = { "ImageTransparency", "BackgroundTransparency" }
local P_BUTTON = { "TextTransparency", "TextStrokeTransparency", "BackgroundTransparency" }
local P_SCROLL = { "BackgroundTransparency", "ScrollBarImageTransparency" }
local P_FRAME = { "BackgroundTransparency" }
local P_STROKE = { "Transparency" }
local function propsFor(c) if c:IsA("ScrollingFrame") then return P_SCROLL end; if c:IsA("TextButton") then return P_BUTTON end; if c:IsA("TextLabel") or c:IsA("TextBox") then return P_TEXT end; if c:IsA("ImageLabel") or c:IsA("ImageButton") then return P_IMAGE end; if c:IsA("Frame") then return P_FRAME end; if c:IsA("UIStroke") then return P_STROKE end; return nil end
local fadePlans = setmetatable({}, { __mode = "k" })
local function fadePlan(root)
    local plan = fadePlans[root]; if plan then return plan end
    plan = {}; local n = 1; plan[1] = { root, "BackgroundTransparency", baseOf(root, "BackgroundTransparency") }
    if root:IsA("ImageLabel") or root:IsA("ImageButton") then n = 2; plan[2] = { root, "ImageTransparency", baseOf(root, "ImageTransparency") } end
    for _, c in ipairs(root:GetDescendants()) do local props = propsFor(c); if props then for i = 1, #props do n = n + 1; plan[n] = { c, props[i], baseOf(c, props[i]) } end end end
    fadePlans[root] = plan
    local conns
    local function invalidate() fadePlans[root] = nil; if conns then for i = 1, #conns do pcall(function() conns[i]:Disconnect() end) end; conns = nil end end
    conns = { root.DescendantAdded:Connect(invalidate), root.DescendantRemoving:Connect(invalidate) }
    return plan
end
local function eachFadeTarget(root, alpha, apply) local plan = fadePlan(root); for i = 1, #plan do local e = plan[i]; local base = e[3]; apply(e[1], e[2], base + (1 - base) * alpha) end end
function QovickHub:_captureBase(root) eachFadeTarget(root, 0, function() end) end
function QovickHub:_setFade(root, alpha) eachFadeTarget(root, alpha, function(inst, prop, value) inst[prop] = value end) end
function QovickHub:_fade(root, alpha, ti) ti = ti or EASE; eachFadeTarget(root, alpha, function(inst, prop, value) tw(inst, ti, { [prop] = value }) end) end

function QovickHub:OpenDrawer(m)
    self.drawerTitle.Text = m and (m.display or m.name) or "Настройки"
    for _, c in ipairs(self.drawerBody:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    if m and (m.info or m.desc) ~= nil and (m.info or m.desc) ~= "" then
        local txt = m.info or m.desc; local width = self.drawerBody.AbsoluteSize.X; if width < 1 then width = 272 end
        local size = math.floor(13 * TEXT_SCALE + 0.5); local ok, sz = pcall(function() return TextService:GetTextSize(txt, size, FONT_REG, Vector2.new(width - 20, 10000)) end)
        local h = ok and math.ceil(sz.Y) or 34
        local row = new("Frame", { Size = UDim2.new(1, 0, 0, h + 8), BackgroundTransparency = 1, LayoutOrder = -1, ZIndex = 22, Parent = self.drawerBody })
        text({ Text = txt, TextSize = 13, Font = FONT_REG, TextColor3 = T.descText, Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(width - 20, h), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 23, Parent = row })
    end
    if m then
        if #m.settings == 0 and not (m.info or m.desc) then text({ Text = "Нет настроек для модуля.", TextSize = 12, Font = FONT_REG, TextColor3 = T.faint, Size = UDim2.new(1, 0, 0, 20), ZIndex = 22, Parent = self.drawerBody }) end
        for _, s in ipairs(m.settings) do self:_setting(s) end
    else for _, s in ipairs(self.uiSettings or {}) do self:_setting(s) end end
    self.drawerBody.ScrollingEnabled = true; self.drawer.Position = UDim2.new(1, 0, 0, 0); self.drawer.Visible = true
    self.modalOpen = true; BLOCKED.on = true; self:_freezeScroll(true); self.scrim.Visible = true; self.scrim.BackgroundTransparency = 1
    tw(self.scrim, OPEN, { BackgroundTransparency = 0.45 }); self:_setFade(self.drawer, 1); self:_fade(self.drawer, 0, OPEN)
end
function QovickHub:CloseDrawer()
    self.modalOpen = false; BLOCKED.on = false; self.drawerBody.ScrollingEnabled = true; self:_freezeScroll(false)
    self:_fade(self.drawer, 1, CLOSE); tw(self.scrim, CLOSE, { BackgroundTransparency = 1 })
    task.delay(0.24, function() if self.drawer.BackgroundTransparency >= 0.99 then self.drawer.Visible = false; self.scrim.Visible = false end end)
end
function QovickHub:_freezeScroll(on)
    for i = 1, #SCROLLERS do local e = SCROLLERS[i]; if e.sf.Parent and e.sf ~= self.drawerBody then e.frozen = on or nil; if on then e.vel = 0 end; e.sf.ScrollingEnabled = not on end end
end
function QovickHub:SetSmoothScroll(on) SMOOTH.scroll = on and true or false; for i = 1, #SCROLLERS do local e = SCROLLERS[i]; if e.sf.Parent then e.vel = 0; e.sf.ScrollingEnabled = not e.frozen end end end
function QovickHub:SetSmoothDrag(on) SMOOTH.drag = on and true or false; if not SMOOTH.drag then self._dragGoal = nil end end

function QovickHub:Confirm(cfg)
    cfg = cfg or {}; if self._confirmOpen then return end; self._confirmOpen = true
    local W = MOBILE and 380 or 348; local innerW = W - 36; local bodyText = cfg.Body or ""
    local bs = math.floor(13 * TEXT_SCALE + 0.5); local okB, bz = pcall(function() return TextService:GetTextSize(bodyText, bs, FONT_REG, Vector2.new(innerW, 10000)) end)
    local bh = math.max(okB and math.ceil(bz.Y) or 40, 18); local H = 46 + bh + 22 + 34 + 18
    local host = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 70, Parent = self.gui })
    local shade = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 70, Parent = host })
    local card = panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(W, H), BackgroundColor3 = T.panel, ZIndex = 71, Parent = host }, 12)
    stroke(card, T.strokeSoft, 12, 0.25)
    text({ Text = cfg.Title or "Вы уверены?", Font = FONT_BOLD, TextSize = 16, TextColor3 = T.text, Position = UDim2.fromOffset(18, 18), Size = UDim2.fromOffset(innerW, 20), ZIndex = 72, Parent = card })
    text({ Text = bodyText, TextSize = 13, Font = FONT_REG, TextColor3 = T.descText, Position = UDim2.fromOffset(18, 46), Size = UDim2.fromOffset(innerW, bh), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 72, Parent = card })
    local function mk(label, xOff, w, danger)
        local idle = danger and Color3.fromRGB(196, 62, 62) or T.inset; local hot = danger and Color3.fromRGB(224, 78, 78) or T.panelHover; local lit = danger and Color3.fromRGB(255, 255, 255) or T.sub
        local b = panel({ Class = "TextButton", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, xOff, 1, -18), Size = UDim2.fromOffset(w, 34), BackgroundColor3 = idle, AutoButtonColor = false, ZIndex = 72, Parent = card }, 8)
        local l = text({ Text = label, TextSize = 13, TextColor3 = lit, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 73, Parent = b })
        b.MouseEnter:Connect(function() tw(b, FAST, { BackgroundColor3 = hot }); tw(l, FAST, { TextColor3 = danger and Color3.fromRGB(255, 255, 255) or T.text }) end)
        b.MouseLeave:Connect(function() tw(b, FAST, { BackgroundColor3 = idle }); tw(l, FAST, { TextColor3 = lit }) end)
        return b
    end
    local yesBtn = mk(cfg.ConfirmText or "Подтвердить", -18, 138, true); local noBtn = mk(cfg.CancelText or "Отмена", -166, 112, false)
    self:_captureBase(host); self:_setFade(host, 1); self:_fade(host, 0, OPEN); tw(shade, OPEN, { BackgroundTransparency = 0.5 })
    card.Size = UDim2.fromOffset(math.floor(W * 0.93), math.floor(H * 0.93)); tw(card, OPEN, { Size = UDim2.fromOffset(W, H) })
    local wasBlocked = BLOCKED.on; BLOCKED.on = true
    local done = false
    local function close(run) if done then return end; done = true; BLOCKED.on = wasBlocked; self._confirmOpen = false; self:_fade(host, 1, CLOSE); tw(shade, CLOSE, { BackgroundTransparency = 1 }); tw(card, CLOSE, { Size = UDim2.fromOffset(math.floor(W * 0.93), math.floor(H * 0.93)) }); task.delay(0.26, function() pcall(function() host:Destroy() end); if run then task.spawn(run) end end) end
    yesBtn.MouseButton1Click:Connect(function() close(cfg.OnConfirm) end)
    noBtn.MouseButton1Click:Connect(function() close(cfg.OnCancel) end)
    shade.MouseButton1Click:Connect(function() close(cfg.OnCancel) end)
end

function QovickHub:Reload()
    if self._reloading then return end; self._reloading = true
    if self.refreshImg then self.refreshImg.Rotation = 0; tw(self.refreshImg, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Rotation = 360 }) end
    local name = self.activeTab and self.activeTab.name or "Modules"; local onModules = name == "Modules"; local page = self._activePage
    if onModules then if self.searchInput then self.searchInput.Text = "" end; self.search = ""; self:_fade(self.side, 1, FAST); self:_fade(self.content, 1, FAST)
    elseif page then self:_fade(page, 1, FAST) end
    task.delay(0.10, function()
        if onModules then self:_updateCounts(); self:_syncFavorites(); self:Refresh(false)
        elseif name == "Players" and self._rebuildPlayers then self._rebuildPlayers()
        elseif name == "Server" and self._refreshServer then self._refreshServer()
        elseif name == "Configs" and self._refreshConfigs then self._refreshConfigs()
        elseif name == "Settings" and self._refreshSettings then self._refreshSettings() end
        if onModules then self:_fade(self.side, 0, OPEN); self:_fade(self.content, 0, OPEN)
        elseif page then self:_setFade(page, 1); self:_fade(page, 0, OPEN) end
        task.delay(0.3, function() self._reloading = false end)
    end)
end

function QovickHub:_buildNotifications()
    self.notifyHost = new("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -18, 1, -18), Size = UDim2.fromOffset(MOBILE and 320 or 288, 1), BackgroundTransparency = 1, ZIndex = 40, Parent = self.gui })
    new("UIListLayout", { VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = self.notifyHost })
    self.notifySeq = 0
end
function QovickHub:Notify(cfg)
    cfg = cfg or {}; if not self.notifyHost then return end; self.notifySeq = self.notifySeq + 1
    local PAD_X, PAD_T, PAD_B, TITLE_H, GAP = 14, 11, 12, 18, 3
    local hostW = self.notifyHost.AbsoluteSize.X; if hostW < 1 then hostW = MOBILE and 320 or 288 end
    local innerW = hostW - PAD_X * 2; local bodySize = math.floor(13 * TEXT_SCALE + 0.5); local bodyH = 0
    if cfg.Content and cfg.Content ~= "" then local ok, sz = pcall(function() return TextService:GetTextSize(cfg.Content, bodySize, FONT_REG, Vector2.new(innerW, 10000)) end); bodyH = ok and math.ceil(sz.Y) or bodySize + 2 end
    local BAR_H, BAR_GAP = 3, 7; local cardH = PAD_T + TITLE_H + (bodyH > 0 and (GAP + bodyH) or 0) + PAD_B + BAR_H + BAR_GAP
    local card = panel({ Size = UDim2.fromOffset(hostW, cardH), BackgroundColor3 = T.panel, ClipsDescendants = true, LayoutOrder = self.notifySeq, ZIndex = 41, Parent = self.notifyHost }, 8)
    stroke(card, T.strokeSoft, 8, 0.35)
    local title = text({ Text = cfg.Title or "Уведомление", Font = FONT_BOLD, TextSize = 14, TextColor3 = T.text, Position = UDim2.fromOffset(PAD_X, PAD_T), Size = UDim2.fromOffset(innerW, TITLE_H), ZIndex = 42, Parent = card })
    local body
    if bodyH > 0 then body = text({ Text = cfg.Content, TextSize = 13, Font = FONT_REG, TextColor3 = T.descText, Position = UDim2.fromOffset(PAD_X, PAD_T + TITLE_H + GAP), Size = UDim2.fromOffset(innerW, bodyH), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 42, Parent = card }) end
    local barTrack = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -BAR_GAP), Size = UDim2.new(1, -PAD_X * 2, 0, BAR_H), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 42, Parent = card })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barTrack })
    local barFill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = cfg.Color or T.onTrack, BorderSizePixel = 0, ZIndex = 43, Parent = barTrack })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barFill })
    self:_captureBase(card); self:_setFade(card, 1); self:_fade(card, 0, OPEN)
    local handle, closed = {}, false
    function handle:Close() if closed then return end; closed = true; local ui = handle._ui; ui:_fade(card, 1, CLOSE); task.delay(0.26, function() pcall(function() card:Destroy() end) end) end
    handle._ui = self; function handle:SetContent(t) if body then body.Text = tostring(t) end end; function handle:SetTitle(t) title.Text = tostring(t) end
    local dur = cfg.Duration
    if dur == 0 then barTrack.Visible = false else dur = dur or 3; tw(barFill, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) }); task.delay(dur, function() handle:Close() end) end
    return handle
end

function QovickHub:_buildTour()
    local host = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 60, Parent = self.gui })
    local shade = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 60, Parent = host })
    local ring = new("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 61, Parent = host })
    new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = ring })
    new("UIStroke", { Color = T.onTrack, Thickness = 2, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = ring })
    local CARD_W = MOBILE and 340 or 300; local card = panel({ Size = UDim2.fromOffset(CARD_W, 150), BackgroundColor3 = T.panel, ZIndex = 62, Parent = host }, 10)
    stroke(card, T.strokeSoft, 10, 0.3)
    local step = text({ Text = "", TextSize = 11, Font = FONT_REG, TextColor3 = T.faint, Position = UDim2.fromOffset(16, 13), Size = UDim2.fromOffset(120, 14), ZIndex = 63, Parent = card })
    local title = text({ Text = "", Font = FONT_BOLD, TextSize = 16, TextColor3 = T.text, Position = UDim2.fromOffset(16, 30), Size = UDim2.fromOffset(CARD_W - 32, 20), ZIndex = 63, Parent = card })
    local body = text({ Text = "", TextSize = 13, Font = FONT_REG, TextColor3 = T.descText, Position = UDim2.fromOffset(16, 54), Size = UDim2.fromOffset(CARD_W - 32, 60), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 63, Parent = card })
    local function mkBtn(label, x, w, primary)
        local b = panel({ Class = "TextButton", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, x, 1, -14), Size = UDim2.fromOffset(w, 30), BackgroundColor3 = primary and T.onTrack or T.inset, AutoButtonColor = false, ZIndex = 63, Parent = card }, 7)
        local l = text({ Text = label, TextSize = 13, TextColor3 = primary and contrastKnob(T.onTrack) or T.sub, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 64, Parent = b })
        b.MouseEnter:Connect(function() if not primary then tw(b, FAST, { BackgroundColor3 = T.panelHover }) end; tw(l, FAST, { TextColor3 = primary and contrastKnob(T.onTrack) or T.text }) end)
        b.MouseLeave:Connect(function() if not primary then tw(b, FAST, { BackgroundColor3 = T.inset }) end; tw(l, FAST, { TextColor3 = primary and contrastKnob(T.onTrack) or T.sub }) end)
        return b, l
    end
    local nextBtn, nextLbl = mkBtn("Далее", -14, 84, true); local skipBtn = mkBtn("Пропустить", -106, 68, false)
    self.tour = { host = host, shade = shade, ring = ring, card = card, step = step, title = title, body = body, cardW = CARD_W, nextBtn = nextBtn, nextLbl = nextLbl, skipBtn = skipBtn, steps = {}, index = 0 }
    self:_captureBase(host)
    nextBtn.MouseButton1Click:Connect(function() self:_tourNext() end); skipBtn.MouseButton1Click:Connect(function() self:EndTour() end); shade.MouseButton1Click:Connect(function() self:_tourNext() end)
end
function QovickHub:AddTourStep(cfg) if not self.tour then return end; table.insert(self.tour.steps, cfg) end
function QovickHub:_tourPlace(target)
    local t = self.tour; local pad = 2
    if typeof(target) == "Instance" and target:IsA("GuiObject") then
        local rp = self.root.AbsolutePosition; local ap, as = target.AbsolutePosition, target.AbsoluteSize
        local px = ap.X - rp.X + self.root.Position.X.Offset - pad; local py = ap.Y - rp.Y + self.root.Position.Y.Offset - pad
        local sx, sy = as.X + pad * 2, as.Y + pad * 2
        if t.ring.Visible then tw(t.ring, EASE, { Position = UDim2.fromOffset(px, py), Size = UDim2.fromOffset(sx, sy) })
        else t.ring.Position = UDim2.fromOffset(px, py); t.ring.Size = UDim2.fromOffset(sx, sy); t.ring.Visible = true end
        local space = self.gui.AbsoluteSize; local cw, ch = t.card.AbsoluteSize.X, t.card.AbsoluteSize.Y
        local x = ap.X - rp.X + self.root.Position.X.Offset + as.X / 2 - cw / 2; local y = ap.Y - rp.Y + self.root.Position.Y.Offset + as.Y + pad + 12
        if y + ch > space.Y - 16 then y = ap.Y - rp.Y + self.root.Position.Y.Offset - ch - pad - 12 end
        x = math.clamp(math.floor(x), 16, math.max(16, space.X - cw - 16)); y = math.clamp(math.floor(y), 16, math.max(16, space.Y - ch - 16))
        tw(t.card, EASE, { Position = UDim2.fromOffset(x, y) })
    else t.ring.Visible = false; local space = self.gui.AbsoluteSize; tw(t.card, EASE, { Position = UDim2.fromOffset(math.floor((space.X - t.card.AbsoluteSize.X) / 2), math.floor((space.Y - t.card.AbsoluteSize.Y) / 2)) }) end
end
function QovickHub:_tourNext()
    local t = self.tour; if not t or not t.host.Visible then return end; t.index = t.index + 1; local s = t.steps[t.index]; if not s then return self:EndTour() end
    if s.Before then pcall(s.Before, self) end; t.step.Text = ("Шаг %d из %d"):format(t.index, #t.steps); t.title.Text = s.Title or ""
    t.nextLbl.Text = (t.index >= #t.steps) and "Готово" or "Далее"; local bodyText = s.Body or ""; t.body.Text = bodyText
    local innerW = t.cardW - 32; local bodySize = math.floor(13 * TEXT_SCALE + 0.5); local okB, bz = pcall(function() return TextService:GetTextSize(bodyText, bodySize, FONT_REG, Vector2.new(innerW, 10000)) end)
    local bh = math.max(okB and math.ceil(bz.Y) or 60, 18); t.body.Size = UDim2.fromOffset(innerW, bh); t.card.Size = UDim2.fromOffset(t.cardW, bh + 114)
    local rawTarget = s.Target; local myIndex = t.index
    task.spawn(function() RunService.Heartbeat:Wait(); RunService.Heartbeat:Wait(); if t.index ~= myIndex or not t.host.Visible then return end; local target = rawTarget; if typeof(target) == "function" then local ok, r = pcall(target, self); target = ok and r or nil end; self:_tourPlace(target) end)
end
function QovickHub:StartTour()
    local t = self.tour; if not t or #t.steps == 0 then return end; t.index = 0; t.ring.Visible = false; t.host.Visible = true; BLOCKED.on = true
    self:_setFade(t.host, 1); self:_fade(t.host, 0, OPEN); tw(t.shade, OPEN, { BackgroundTransparency = 0.55 }); self:_tourNext()
end
function QovickHub:EndTour()
    local t = self.tour; if not t or not t.host.Visible then return end; BLOCKED.on = false; self:_fade(t.host, 1, CLOSE); tw(t.shade, CLOSE, { BackgroundTransparency = 1 }); task.delay(0.26, function() t.host.Visible = false end); if self.onTourEnd then pcall(self.onTourEnd) end
end

function QovickHub:_buildBadge()
    local cfg = self.cfg or {}; local hasLogo = self.logoId ~= nil; local markRect = hasLogo and cfg.LogoMarkRect or nil; local BW, BH
    if markRect then BW, BH = 52, 52 elseif hasLogo then BW, BH = 106, 46 else BW, BH = 46, 46 end
    local SS = 0.05
    self.badge = new("ImageButton", { Image = SQUIRCLE.img, ScaleType = Enum.ScaleType.Slice, SliceCenter = SQUIRCLE.rect, SliceScale = SS, ImageColor3 = T.root, BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.fromOffset(BW, BH), Visible = false, ZIndex = 30, Parent = self.gui })
    new("UIGradient", { Rotation = 90, Parent = self.badge, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(214, 214, 214)) })
    new("ImageLabel", { Image = SQ_OUTLINE.img, ScaleType = Enum.ScaleType.Slice, SliceCenter = SQ_OUTLINE.rect, SliceScale = SS, ImageColor3 = T.stroke, ImageTransparency = 0, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 32, Parent = self.badge })
    local parts = {}
    local function crop(rect, posY, w, h) parts[#parts + 1] = new("ImageLabel", { Image = self.logoId, BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, ImageRectOffset = Vector2.new(rect[1], rect[2]), ImageRectSize = Vector2.new(rect[3], rect[4]), ImageColor3 = T.text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, posY), Size = UDim2.fromOffset(w, h), ZIndex = 31, Parent = self.badge }) end
    if markRect then crop(markRect, 0.5, 32, 24)
    elseif hasLogo then parts[1] = new("ImageLabel", { Image = self.logoId, BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, ImageColor3 = T.text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(BW - 24, 24), ZIndex = 31, Parent = self.badge })
    else parts[1] = text({ Text = "Q", Font = FONT_BOLD, TextSize = 20, TextColor3 = T.text, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 31, Parent = self.badge }) end
    local function paintMark(c) for _, p in ipairs(parts) do if p:IsA("ImageLabel") then tw(p, FAST, { ImageColor3 = c }) else tw(p, FAST, { TextColor3 = c }) end end end
    self.badge.MouseEnter:Connect(function() tw(self.badge, FAST, { ImageColor3 = T.panelHover }); paintMark(T.onTrack) end)
    self.badge.MouseLeave:Connect(function() tw(self.badge, FAST, { ImageColor3 = T.root }); paintMark(T.text) end)
    local downAt, moved = nil, false
    self.badge.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then downAt, moved = i.Position, false end end)
    self.badge.InputChanged:Connect(function(i) if downAt and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then if math.abs(i.Position.X - downAt.X) > 3 or math.abs(i.Position.Y - downAt.Y) > 3 then moved, self._badgeMoved = true, true end end end)
    self.badge.MouseButton1Click:Connect(function() local wasDrag = moved; downAt, moved = nil, false; if not wasDrag then self:Restore() end end)
    self:_drag(self.badge, self.badge)
end

function QovickHub:_clampToScreen(x, y, w, h) local M = 8; local space = self.gui.AbsoluteSize; local inset = GuiService:GetGuiInset(); return UDim2.fromOffset(math.clamp(math.floor(x), M, math.max(M, space.X - w - M)), math.clamp(math.floor(y), inset.Y + M, math.max(inset.Y + M, space.Y - h - M))) end
function QovickHub:Present() if self._presented or self._destroyed then return end; self._presented = true; self.root.BackgroundTransparency = 0; if self.rootStroke then tw(self.rootStroke, OPEN, { Transparency = baseOf(self.rootStroke, "Transparency") }) end end
function QovickHub:Minimize()
    if self.minimized then return end; self.minimized = true; if self.drawer.Visible then self:CloseDrawer() end
    if not self._badgeMoved then local rp, rs, bs = self.root.Position, self.root.AbsoluteSize, self.badge.AbsoluteSize; self.badge.Position = self:_clampToScreen(rp.X.Offset + math.floor(rs.X / 2) - math.floor(bs.X / 2), rp.Y.Offset + math.floor(rs.Y / 2) - math.floor(bs.Y / 2), bs.X, bs.Y) end
    tw(self.root, WIN_FADE, { BackgroundTransparency = 1 }); if self.rootStroke then tw(self.rootStroke, WIN_FADE, { Transparency = 1 }) end
    task.delay(0.06, function() if not self.minimized then return end; self.badge.Visible = true; self:_setFade(self.badge, 1); self:_fade(self.badge, 0, WIN_FADE) end)
    task.delay(0.26, function() if not self.minimized then return end; self.root.Visible = false end)
end
function QovickHub:Restore()
    if not self.minimized then return end; self.minimized = false
    if self.fullscreen then local space = self.gui.AbsoluteSize; local inset = GuiService:GetGuiInset(); local usableY = space.Y - inset.Y; local M = 18; self.root.Size = UDim2.fromOffset(space.X - M * 2, usableY - M * 2); self.root.Position = UDim2.fromOffset(M, inset.Y + M)
    else local bp, bs, rs = self.badge.Position, self.badge.AbsoluteSize, self.root.AbsoluteSize; self.root.Position = self:_clampToScreen(bp.X.Offset + math.floor(bs.X / 2) - math.floor(rs.X / 2), bp.Y.Offset + math.floor(bs.Y / 2) - math.floor(rs.Y / 2), rs.X, rs.Y) end
    self:_fade(self.badge, 1, WIN_FADE); task.delay(0.24, function() if self.minimized then return end; self.badge.Visible = false end)
    self.root.Visible = true; self.root.BackgroundTransparency = 0; if self.rootStroke then self.rootStroke.Transparency = 1; tw(self.rootStroke, WIN_FADE, { Transparency = baseOf(self.rootStroke, "Transparency") }) end
end
function QovickHub:ToggleFullscreen()
    local M = 18
    if self.fullscreen then self.fullscreen = false; local ps = self._preSize; local w = ps.X.Offset > 0 and ps.X.Offset or self.root.AbsoluteSize.X; local h = ps.Y.Offset > 0 and ps.Y.Offset or self.root.AbsoluteSize.Y; tw(self.root, EASE, { Size = ps, Position = self:_clampToScreen(self._prePos.X.Offset, self._prePos.Y.Offset, w, h) }); setIcon(self.fullImg, "maximize"); self.fullImg:SetAttribute("Active", false); tw(self.fullImg, FAST, { ImageColor3 = T.dim })
    else self.fullscreen = true; self._preSize, self._prePos = self.root.Size, self.root.Position; local space = self.gui.AbsoluteSize; local inset = GuiService:GetGuiInset(); local usableY = space.Y - inset.Y; tw(self.root, EASE, { Size = UDim2.fromOffset(space.X - M * 2, usableY - M * 2), Position = UDim2.fromOffset(M, inset.Y + M) }); setIcon(self.fullImg, "minimize"); self.fullImg:SetAttribute("Active", true); tw(self.fullImg, FAST, { ImageColor3 = T.star }) end
    task.delay(0.27, function() self:SetLayout(nil, false) end)
end
function QovickHub:Destroy()
    if self._destroyed then return end; self._destroyed = true
    for _, m in ipairs(self.allModules) do if not m.action and m.state then pcall(function() m:Toggle(false) end) end end
    if self._releaseWheel then pcall(self._releaseWheel) end
    local OUT = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.In); local rs = self.root.AbsoluteSize; local rx, ry = self.root.Position.X.Offset, self.root.Position.Y.Offset; local sx, sy = math.floor(rs.X * 0.9), math.floor(rs.Y * 0.9)
    tw(self.root, OUT, { BackgroundTransparency = 1, Size = UDim2.fromOffset(sx, sy), Position = UDim2.fromOffset(rx + math.floor((rs.X - sx) / 2), ry + math.floor((rs.Y - sy) / 2)) })
    if self.rootStroke then tw(self.rootStroke, OUT, { Transparency = 1 }) end; if self.badge then self:_fade(self.badge, 1, CLOSE) end
    task.delay(0.36, function() if self._releaseWheel then pcall(self._releaseWheel) end; if getgenv and getgenv().QOVICKHUB_CLEANUP then pcall(getgenv().QOVICKHUB_CLEANUP) end; if getgenv then getgenv().QOVICKHUB_CLEANUP = nil; getgenv().QovickHub = nil end; pcall(function() self.gui:Destroy() end); if getgenv then getgenv().__qovick_gui = nil end; if self.onDestroy then pcall(self.onDestroy) end end)
end

function QovickHub:SetLayout(opts, animate)
    opts = opts or {}; self.layout = self.layout or { side = "Left", search = "Top" }
    if opts.side then self.layout.side = opts.side end; if opts.search then self.layout.search = opts.search end
    local function clean(props) local t = {}; for k, v in pairs(props) do if k ~= "__fast" then t[k] = v end end; return t end
    local put = animate and function(o, props) tw(o, props.__fast and FAST or EASE, clean(props)) end or function(o, props) for k, v in pairs(clean(props)) do o[k] = v end end
    local L, TB, SW = self.layout, self.TOPBAR_H, self.SIDE_W; local BOTTOM_H, PAD, GUTTER = 62, 13, 12
    local bottom = L.side == "Bottom"; local right = L.side == "Right"; local w = self._sideShown == false and 0 or SW
    if bottom then put(self.side, { Position = UDim2.new(0, 0, 1, -BOTTOM_H), Size = UDim2.new(1, 0, 0, BOTTOM_H) }) else put(self.side, { Position = UDim2.fromOffset(right and (self.root.AbsoluteSize.X - w) or 0, TB + PAD), Size = UDim2.new(0, w, 1, -TB - PAD), __fast = not self._sideShown }) end
    local layout = self.catList:FindFirstChildWhichIsA("UIListLayout"); layout.FillDirection = bottom and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
    self.catList.AutomaticCanvasSize = bottom and Enum.AutomaticSize.X or Enum.AutomaticSize.Y
    local ce = scrollerEntry(self.catList); if ce and ce.horizontal ~= (bottom or nil) then ce.horizontal = bottom or nil; ce.vel = 0; self.catList.CanvasPosition = Vector2.new(0, 0) end
    self.catHeader.Visible = not bottom
    if bottom then self.catList.Position = UDim2.fromOffset(8, 10); self.catList.Size = UDim2.new(1, -16, 0, 42) else self.catList.Position = UDim2.fromOffset(8, 42); self.catList.Size = UDim2.new(0, SW - 16, 1, -54) end
    for _, c in ipairs(self.categories) do c.button.Size = bottom and UDim2.fromOffset(MOBILE and 190 or 150, CAT_H) or UDim2.new(1, 0, 0, CAT_H) end
    local cx = (bottom or right) and 16 or (w + GUTTER); put(self.content, { Position = UDim2.fromOffset(cx, TB + PAD), Size = UDim2.new(1, bottom and -32 or (-w - GUTTER - 16), 1, -TB - PAD - 14 - (bottom and BOTTOM_H or 0)), __fast = not self._sideShown })
    if L.search == "Bottom" then put(self.searchBox, { Position = UDim2.new(0, 0, 1, -SEARCH_H) }); put(self.modList, { Position = UDim2.fromOffset(0, 0) }) else put(self.searchBox, { Position = UDim2.fromOffset(0, 0) }); put(self.modList, { Position = UDim2.fromOffset(0, SEARCH_H + 12) }) end
    put(self.modList, { Size = UDim2.new(1, 0, 1, -SEARCH_H - 12) })
    local grad = self.dividerLine:FindFirstChildWhichIsA("UIGradient")
    if bottom then self.dividerLine.Position = UDim2.new(0, 0, 1, -BOTTOM_H); self.dividerLine.Size = UDim2.new(1, 0, 0, 1); if grad then grad.Rotation = 0 end
    else self.dividerLine.Position = UDim2.fromOffset(right and (self.root.AbsoluteSize.X - w) or w, TB + 1); self.dividerLine.Size = UDim2.new(0, 1, 1, -TB - 1); if grad then grad.Rotation = 90 end end
    local onModules = (not self.activeTab) or self.activeTab.name == "Modules"; self:_setDivider(onModules and (bottom or (self._sideShown ~= false)), animate)
    self.edgeStrip.Position = UDim2.fromOffset(right and (self.root.AbsoluteSize.X - 16) or 0, TB + PAD)
    if self.midIcons then self.midIcons.Position = UDim2.fromOffset(math.floor((self.root.AbsoluteSize.X - self.midIcons.AbsoluteSize.X) / 2 + 0.5), 0) end
end
function QovickHub:_setDivider(shown, animate)
    local line = self.dividerLine; if not line then return end; if shown then line.Visible = true end
    if animate then tw(line, shown and OPEN or FAST, { BackgroundTransparency = shown and 0.35 or 1 }); if not shown then task.delay(0.16, function() if line.BackgroundTransparency >= 0.99 then line.Visible = false end end) end
    else line.BackgroundTransparency = shown and 0.35 or 1; line.Visible = shown end
end
function QovickHub:_setSidebar(shown, animate)
    if self._sideShown == shown then return end; self._sideShown = shown; local onModules = (not self.activeTab) or self.activeTab.name == "Modules"
    if shown and onModules then self.side.Visible = true end
    self:_fade(self.side, shown and 0 or 1, animate and (shown and OPEN or FAST) or TweenInfo.new(0)); self:SetLayout(nil, animate)
end
function QovickHub:SetCompact(v)
    self.compact = v and true or false; local h = self.compact and ROW_H_COMPACT or ROW_H
    for _, m in ipairs(self.allModules) do tw(m.row, EASE, { Size = UDim2.new(1, 0, 0, h) }); if m.descLbl then m.descLbl.Visible = (not self.compact) and self.showDesc ~= false end end
    if self.layoutImg then setIcon(self.layoutImg, self.compact and "rows-3" or "panels-top-left"); self.layoutImg:SetAttribute("Active", self.compact); tw(self.layoutImg, FAST, { ImageColor3 = self.compact and T.star or T.dim }) end
    self.edgeStrip.Visible = self.compact; self:_setSidebar(not self.compact, true)
    if not self._hoverWired then
        self._hoverWired = true
        sig(UserInputService.InputChanged):Connect(function(i)
            if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end; if not self.compact or not self.root.Parent then return end
            local p = UserInputService:GetMouseLocation(); local ins = GuiService:GetGuiInset(); local o = self.root.AbsolutePosition; local x, y = p.X - o.X, p.Y - ins.Y - o.Y
            local w = self._sideShown and self.SIDE_W or 16; local inside = x >= 0 and x <= w and y >= self.TOPBAR_H and y <= self.root.AbsoluteSize.Y
            if inside and not self._sideShown then self:_setSidebar(true, true) elseif not inside and self._sideShown then self:_setSidebar(false, true) end
        end)
    end
end
function QovickHub:SetTextScale(mult) TEXT_SCALE = mult; for _, d in ipairs(self.gui:GetDescendants()) do local base = d:GetAttribute("BaseTextSize"); if base then d.TextSize = math.floor(base * mult + 0.5) end end end
function QovickHub:SetFontFamily(name)
    local fam = FAMILIES[name]; if not fam then return end; FONT_REG, FONT, FONT_BOLD = fam[1], fam[2], fam[3]
    local byRole = { reg = FONT_REG, med = FONT, bold = FONT_BOLD }
    for _, d in ipairs(self.gui:GetDescendants()) do if d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("TextButton") then local role = d:GetAttribute("FontRole"); if role and byRole[role] then d.Font = byRole[role] end end end
end
function QovickHub:SetAccent(color)
    T.star, T.onTrack = color, color
    for _, m in ipairs(self.allModules) do if m._paint then m._paint(true) end; if m._paintStar then m._paintStar() end end
    for _, c in ipairs(self.categories) do if c == self.activeCategory then tw(c.iconImg, FAST, { ImageColor3 = (c == self.favCategory) and T.star or T.text }) end end
    if self.layoutImg and self.compact then tw(self.layoutImg, FAST, { ImageColor3 = T.star }) end
    for _, d in ipairs(self.gui:GetDescendants()) do local role = d:GetAttribute("AccentRole"); if role == "fill" then tw(d, FAST, { BackgroundColor3 = color }) elseif role == "track" and d:GetAttribute("AccentOn") then tw(d, FAST, { BackgroundColor3 = color }) elseif role == "knob" and d:GetAttribute("AccentOn") then tw(d, FAST, { BackgroundColor3 = contrastKnob(color) }) end end
end
function QovickHub:SetOpacity(pct) local a = 1 - math.clamp(pct, 20, 100) / 100; self.root.BackgroundTransparency = a; self.root:SetAttribute("_base_BackgroundTransparency", a) end
function QovickHub:ResetSettings()
    for _, cfg in ipairs(self.uiSettings or {}) do if cfg.Title and cfg.Default ~= nil then local cur = cfg.Value; if cur == nil then cur = cfg.Default end; if cur ~= cfg.Default then cfg.Value = cfg.Default; if cfg.Callback then pcall(cfg.Callback, cfg.Default) end end end end
    if self._refreshSettings then self._refreshSettings() end
end

function QovickHub:_buildUISettings()
    local accents = { Gray = Color3.fromRGB(205, 205, 205), Orange = Color3.fromRGB(255, 157, 46), White = Color3.fromRGB(232, 232, 232), Blue = Color3.fromRGB(80, 160, 255), Green = Color3.fromRGB(96, 210, 130), Red = Color3.fromRGB(255, 92, 92), Purple = Color3.fromRGB(178, 130, 255) }
    self.uiSettings = {
        { Type = "Section", Text = "ВНЕШНИЙ ВИД" },
        { Type = "Dropdown", Title = "Акцент", Values = { "Gray", "Orange", "White", "Blue", "Green", "Red", "Purple" }, Default = "Gray", Callback = function(v) self:SetAccent(accents[v] or accents.Gray) end },
        { Type = "Dropdown", Title = "Шрифт", Values = FAMILY_ORDER, Default = FAMILY_ORDER[1], Callback = function(v) self:SetFontFamily(v) end },
        { Type = "Dropdown", Title = "Размер текста", Values = { "Small", "Normal", "Large", "Huge" }, Default = "Normal", Callback = function(v) self:SetTextScale(({ Small = 1.0, Normal = 1.15, Large = 1.3, Huge = 1.45 })[v] or 1.15) end },
        { Type = "Slider", Title = "Прозрачность", Min = 40, Max = 100, Default = 100, Callback = function(v) self:SetOpacity(v) end },
        { Type = "Section", Text = "РАСКЛАДКА" },
        { Type = "Dropdown", Title = "Категории", Values = { "Left", "Right", "Bottom" }, Default = "Left", Callback = function(v) self:SetLayout({ side = v }, true) end },
        { Type = "Dropdown", Title = "Поиск", Values = { "Top", "Bottom" }, Default = "Top", Callback = function(v) self:SetLayout({ search = v }, true) end },
        { Type = "Toggle", Title = "Компактные строки", Default = false, Callback = function(v) self:SetCompact(v) end },
        { Type = "Slider", Title = "Ширина", Min = 700, Max = 1100, Default = self.root.AbsoluteSize.X, Callback = function(v) if self.fullscreen then self:ToggleFullscreen() end; self.root.Size = UDim2.fromOffset(v, self.root.AbsoluteSize.Y); self._preSize = self.root.Size; self:Recenter(); self:SetLayout(nil, false) end },
        { Type = "Slider", Title = "Высота", Min = 400, Max = 760, Default = self.root.AbsoluteSize.Y, Callback = function(v) if self.fullscreen then self:ToggleFullscreen() end; self.root.Size = UDim2.fromOffset(self.root.AbsoluteSize.X, v); self._preSize = self.root.Size; self:Recenter(); self:SetLayout(nil, false) end },
        { Type = "Button", Title = "Центрировать окно", Callback = function() self:Recenter() end },
        { Type = "Section", Text = "ПОВЕДЕНИЕ" },
        { Type = "Toggle", Title = "Показывать описания", Default = true, Callback = function(v) self.showDesc = v; for _, m in ipairs(self.allModules) do if m.descLbl then m.descLbl.Visible = v and not self.compact end end end },
        { Type = "Toggle", Title = "Показывать бинды", Default = true, Callback = function(v) for _, m in ipairs(self.allModules) do if m.chip then m.chip.Visible = v end end end },
        { Type = "Toggle", Title = "Анимации", Default = true, Callback = function(v) ANIM.on = v end },
        { Type = "Toggle", Title = "Плавный скролл", Default = true, Callback = function(v) self:SetSmoothScroll(v) end },
        { Type = "Toggle", Title = "Плавное перетаскивание", Default = false, Callback = function(v) self:SetSmoothDrag(v) end },
    }
end

local activeSlider = nil
sig(UserInputService.InputChanged):Connect(function(i) if not activeSlider then return end; if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then activeSlider(i.Position.X) end end)
sig(UserInputService.InputEnded):Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then activeSlider = nil end end)
local function settingValue(cfg) if cfg.Value == nil then cfg.Value = cfg.Default end; return cfg.Value end

function QovickHub:_setting(cfg, body)
    local kind = cfg.Type or "Toggle"; body = body or self.drawerBody
    if kind == "Toggle" then
        local row = panel({ Class = "TextButton", Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = T.inset, BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 22, Parent = body }, 7)
        text({ Text = cfg.Title or "Toggle", TextSize = 14, TextColor3 = T.text, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(1, -66, 0, 16), ZIndex = 23, Parent = row })
        local state = settingValue(cfg) and true or false
        local track = panel({ AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(TRACK_W, TRACK_H), BackgroundColor3 = state and T.onTrack or T.offTrack, ZIndex = 23, Parent = row }, 11)
        stroke(track, T.stroke, 11, 0.45)
        local knob = panel({ AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, state and KNOB_ON or KNOB_PAD, 0.5, 0), Size = UDim2.fromOffset(KNOB_D, KNOB_D), BackgroundColor3 = state and contrastKnob(T.onTrack) or T.offKnob, ZIndex = 24, Parent = track }, 8)
        track:SetAttribute("AccentRole", "track"); track:SetAttribute("AccentOn", state); knob:SetAttribute("AccentRole", "knob"); knob:SetAttribute("AccentOn", state)
        row.MouseEnter:Connect(function() tw(row, FAST, { BackgroundTransparency = 0 }) end); row.MouseLeave:Connect(function() tw(row, FAST, { BackgroundTransparency = 1 }) end)
        row.MouseButton1Click:Connect(function() state = not state; cfg.Value = state; track:SetAttribute("AccentOn", state); knob:SetAttribute("AccentOn", state); tw(track, EASE, { BackgroundColor3 = state and T.onTrack or T.offTrack }); tw(knob, EASE, { BackgroundColor3 = state and contrastKnob(T.onTrack) or T.offKnob, Position = UDim2.new(0, state and KNOB_ON or KNOB_PAD, 0.5, 0) }); if cfg.Callback then task.spawn(cfg.Callback, state) end end)
    elseif kind == "Slider" then
        local row = new("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, ZIndex = 22, Parent = body })
        text({ Text = cfg.Title or "Slider", TextSize = 14, TextColor3 = T.text, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -60, 0, 16), ZIndex = 23, Parent = row })
        local min, max = cfg.Min or 0, cfg.Max or 100; local value = settingValue(cfg) or min
        local function fmtVal(v) if cfg.Format then local ok, str = pcall(cfg.Format, v); if ok and type(str) == "string" then return str end end; return tostring(v) end
        local valLbl = text({ Text = fmtVal(value), TextSize = 12, TextColor3 = T.sub, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 0), Size = UDim2.fromOffset(46, 16), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 23, Parent = row })
        local KNOB = 14; local bar = panel({ Position = UDim2.new(0, 10, 0, 31), Size = UDim2.new(1, -20, 0, 4), BackgroundColor3 = T.offTrack, ZIndex = 23, Parent = row }, 2)
        local a = math.clamp((value - min) / math.max(max - min, 1), 0, 1)
        local fill = panel({ Size = UDim2.new(a, 0, 1, 0), BackgroundColor3 = T.onTrack, ZIndex = 24, Parent = bar }, 2); fill:SetAttribute("AccentRole", "fill")
        local knob = panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(a, 0, 0.5, 0), Size = UDim2.fromOffset(KNOB, KNOB), BackgroundColor3 = T.offKnob, ZIndex = 25, Parent = bar }, KNOB / 2)
        local hit = new("TextButton", { BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 20), ZIndex = 26, Parent = row })
        local function apply(px) local rel = math.clamp((px - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1); local v = math.floor(min + (max - min) * rel + 0.5); if cfg.Adjust then local ok, adj = pcall(cfg.Adjust, v); if ok and type(adj) == "number" then v = adj end end; if cfg.Value == v then return end; cfg.Value = v; valLbl.Text = fmtVal(v); local av = math.clamp((v - min) / math.max(max - min, 1), 0, 1); tw(fill, FAST, { Size = UDim2.new(av, 0, 1, 0) }); tw(knob, FAST, { Position = UDim2.new(av, 0, 0.5, 0) }); if cfg.Callback then task.spawn(cfg.Callback, v) end end
        hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then activeSlider = apply; apply(i.Position.X) end end)
    elseif kind == "Dropdown" then
        local row = panel({ Class = "TextButton", Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = T.inset, AutoButtonColor = false, ZIndex = 22, Parent = body }, 7)
        text({ Text = cfg.Title or "Select", TextSize = 14, TextColor3 = T.text, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(1, -80, 0, 16), ZIndex = 23, Parent = row })
        local cur = settingValue(cfg) or (cfg.Values and cfg.Values[1])
        local valLbl = text({ Text = tostring(cur), TextSize = 12, TextColor3 = T.star, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -28, 0.5, 0), Size = UDim2.fromOffset(80, 16), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 23, Parent = row })
        text({ Text = "▾", TextSize = 12, TextColor3 = T.faint, Font = FONT_REG, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(14, 16), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 23, Parent = row })
        local popup
        row.MouseButton1Click:Connect(function()
            if popup then pcall(function() popup:Destroy() end); popup = nil; return end
            local items = cfg.Values or {}; local ih = 30; local ph = #items * ih + 8
            popup = panel({ Position = row.Position + UDim2.fromOffset(0, 34 + 4), Size = UDim2.new(1, 0, 0, ph), BackgroundColor3 = T.panel, ZIndex = 40, Parent = body }, 7)
            stroke(popup, T.strokeSoft, 7, 0.25)
            new("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = popup })
            new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = popup })
            for i, val in ipairs(items) do
                local b = panel({ Class = "TextButton", Size = UDim2.new(1, 0, 0, ih), BackgroundColor3 = T.panel, BackgroundTransparency = 1, AutoButtonColor = false, LayoutOrder = i, ZIndex = 41, Parent = popup }, 5)
                text({ Text = tostring(val), TextSize = 13, TextColor3 = (val == cur) and T.star or T.text, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), ZIndex = 42, Parent = b })
                b.MouseEnter:Connect(function() tw(b, FAST, { BackgroundTransparency = 0, BackgroundColor3 = T.panelHover }) end)
                b.MouseLeave:Connect(function() tw(b, FAST, { BackgroundTransparency = 1 }) end)
                b.MouseButton1Click:Connect(function() cur = val; cfg.Value = val; valLbl.Text = tostring(val); if cfg.Callback then task.spawn(cfg.Callback, val) end; if popup then pcall(function() popup:Destroy() end); popup = nil end end)
            end
        end)
    end
end

return QovickHub
]==]

-- ═══════════════════════════════════════════════════════════════════════════
--  Инициализация QovickHub + Читы + Auto Farm + Fling
-- ═══════════════════════════════════════════════════════════════════════════
local QovickHub = loadstring(QOVICKHUB_SOURCE)()

local Hub = QovickHub.new({
    Title = "QovickHub",
    Version = "v1.3",
    Width = 820,
    Height = 520,
})

task.wait(0.2)

Hub:Tab("Modules")
Hub:Tab("Players")
Hub:Tab("Server")
Hub:Tab("Configs")
Hub:Tab("Settings")
Hub:Tab("Credits")

task.wait(0.2)

local Visuals = Hub:Category("Visuals", "star")
local Combat = Hub:Category("Combat", "star")
local Movement = Hub:Category("Movement", "settings")
local AutoFarm = Hub:Category("Auto Farm", "coins")
local Misc = Hub:Category("Misc", "settings")

task.wait(0.2)

-- ═══ Читы ═══
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local State = { ESP = false, SilentAim = false, Fly = false, Speed = false, SpeedValue = 50 }
local ESPObjects = {}
local FlyConnection = nil
local SpeedConnection = nil
local OriginalWalkSpeed = 16
local FlingSelected = {}

-- ESP
local function GetPlayerRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    local roleObj = player:FindFirstChild("Role") or player:FindFirstChild("role") or player:FindFirstChild("RoleName") or player:FindFirstChild("Team")
    if roleObj and roleObj:IsA("StringValue") then
        local r = roleObj.Value:lower()
        if r:find("murder") or r:find("убийца") then return "Murderer" end
        if r:find("sheriff") or r:find("шериф") then return "Sheriff" end
    end
    local backpack = player:FindFirstChild("Backpack")
    local inventory = {}
    if backpack then for _, item in ipairs(backpack:GetChildren()) do if item:IsA("Tool") then table.insert(inventory, item) end end end
    for _, item in ipairs(char:GetChildren()) do if item:IsA("Tool") then table.insert(inventory, item) end end
    for _, item in ipairs(inventory) do
        local name = item.Name:lower()
        if name:find("knife") or name:find("нож") or name:find("dagger") then return "Murderer"
        elseif name:find("gun") or name:find("пистолет") or name:find("revolver") or name:find("pistol") then return "Sheriff" end
    end
    return "Innocent"
end

local function CreateESP(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local role = GetPlayerRole(player)
    local roleColor = Color3.fromRGB(50, 255, 50)
    local roleText = "Innocent"
    
    if role == "Murderer" then roleColor = Color3.fromRGB(255, 50, 50); roleText = "Убийца"
    elseif role == "Sheriff" then roleColor = Color3.fromRGB(50, 150, 255); roleText = "Шериф" end

    local highlight = Instance.new("Highlight")
    highlight.Name = "QovickESP_Highlight"
    highlight.Adornee = char
    highlight.FillColor = roleColor
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = roleColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "QovickESP"
    billboard.Adornee = hrp
    billboard.Size = UDim2.fromOffset(200, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = Hub.gui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard

    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0, 20)
    roleLabel.Position = UDim2.fromOffset(0, 20)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = roleText
    roleLabel.TextColor3 = roleColor
    roleLabel.Font = Enum.Font.GothamBold
    roleLabel.TextSize = 14
    roleLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 20)
    distLabel.Position = UDim2.fromOffset(0, 40)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.Parent = billboard

    table.insert(ESPObjects, { player = player, billboard = billboard, distLabel = distLabel, highlight = highlight, roleLabel = roleLabel })
end

local function RemoveESP()
    for _, obj in ipairs(ESPObjects) do pcall(function() obj.billboard:Destroy(); if obj.highlight then obj.highlight:Destroy() end end) end
    ESPObjects = {}
end

local function UpdateESP()
    if not State.ESP then RemoveESP(); return end
    for i = #ESPObjects, 1, -1 do
        local obj = ESPObjects[i]
        if not obj.player.Character or not obj.player.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() obj.billboard:Destroy(); if obj.highlight then obj.highlight:Destroy() end end)
            table.remove(ESPObjects, i)
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local found = false
            for _, obj in ipairs(ESPObjects) do if obj.player == player then found = true; break end end
            if not found then CreateESP(player) end
        end
    end
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if myRoot then
        for _, obj in ipairs(ESPObjects) do
            local char = obj.player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = math.floor((hrp.Position - myRoot.Position).Magnitude)
                obj.distLabel.Text = dist .. "m"
                
                local role = GetPlayerRole(obj.player)
                local roleColor = Color3.fromRGB(50, 255, 50)
                local roleText = "Невинный"
                
                if role == "Murderer" then roleColor = Color3.fromRGB(255, 50, 50); roleText = "Убийца"
                elseif role == "Sheriff" then roleColor = Color3.fromRGB(50, 150, 255); roleText = "Шериф" end
                
                obj.roleLabel.Text = roleText
                obj.roleLabel.TextColor3 = roleColor
                if obj.highlight then obj.highlight.FillColor = roleColor; obj.highlight.OutlineColor = roleColor end
            end
        end
    end
end

-- Silent Aim
local SilentAim = { enabled = false, targetPart = "Head", teamCheck = false, ignoreWalls = false, fov = 150, conn = nil }
local function GetTarget()
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local closest, closestDist = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local cam = workspace.CurrentCamera
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if SilentAim.teamCheck and player.Team == LP.Team then continue end
                local targetPart = char:FindFirstChild(SilentAim.targetPart)
                if targetPart then
                    if SilentAim.fov > 0 then
                        local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                        if not onScreen then continue end
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist > SilentAim.fov then continue end
                    end
                    if not SilentAim.ignoreWalls then
                        local ray = Ray.new(cam.CFrame.Position, (targetPart.Position - cam.CFrame.Position).Unit * 500)
                        local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {myChar})
                        if hit and not hit:IsDescendantOf(char) then continue end
                    end
                    local dist = (targetPart.Position - myRoot.Position).Magnitude
                    if dist < closestDist then closest, closestDist = targetPart, dist end
                end
            end
        end
    end
    return closest
end
local function EnableSilentAim(on)
    if SilentAim.conn then SilentAim.conn:Disconnect(); SilentAim.conn = nil end
    SilentAim.enabled = on
    if not on then return end
    SilentAim.conn = RunService.RenderStepped:Connect(function()
        if not SilentAim.enabled then return end
        local target = GetTarget()
        if target then
            local cam = workspace.CurrentCamera
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
        end
    end)
end

-- Fly
local function EnableFly(on)
    if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    if not on then humanoid.PlatformStand = false; hrp.Velocity = Vector3.new(0, 0, 0); return end
    humanoid.PlatformStand = true
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.Parent = hrp
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not State.Fly then bodyVel:Destroy(); humanoid.PlatformStand = false; return end
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
        bodyVel.Velocity = moveDir * 50
    end)
end

-- Speed
local function EnableSpeed(on, val)
    if SpeedConnection then SpeedConnection:Disconnect(); SpeedConnection = nil end
    local char = LP.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    if not on then humanoid.WalkSpeed = OriginalWalkSpeed; return end
    SpeedConnection = RunService.Heartbeat:Connect(function()
        if not State.Speed then return end
        humanoid.WalkSpeed = State.SpeedValue
    end)
end

-- ═══ Auto Farm (Candy + Coin) ═══
local AutoFarmState = { farmingCandy = false, farmingCoin = false, collected = 0, startTime = 0, speed = 15, visited = {} }

local function StartAutoFarm(isCandy)
    local farmType = isCandy and "Candy" or "Coin"
    if isCandy then AutoFarmState.farmingCandy = true else AutoFarmState.farmingCoin = true end
    AutoFarmState.collected = 0
    AutoFarmState.startTime = tick()
    AutoFarmState.visited = {}

    task.spawn(function()
        while (isCandy and AutoFarmState.farmingCandy) or (not isCandy and AutoFarmState.farmingCoin) do
            local char = LP.Character or LP.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local closest, dist = nil, math.huge
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name == "Coin_Server"
                       and obj:GetAttribute("CoinID") == farmType
                       and not AutoFarmState.visited[obj] then
                        local d = (obj.Position - hrp.Position).Magnitude
                        if d < dist and d <= 250 then closest, dist = obj, d end
                    end
                end
                
                if closest and closest.Parent then
                    AutoFarmState.visited[closest] = true
                    for _, part in ipairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
                    local tween = TweenService:Create(hrp, TweenInfo.new(dist / AutoFarmState.speed, Enum.EasingStyle.Linear), { CFrame = CFrame.new(closest.Position) })
                    tween:Play()
                    tween.Completed:Wait()
                    AutoFarmState.collected += 1
                end
            end
            task.wait(0.3)
        end
    end)
end

local function StopAutoFarm(isCandy)
    if isCandy then AutoFarmState.farmingCandy = false else AutoFarmState.farmingCoin = false end
    if not AutoFarmState.farmingCandy and not AutoFarmState.farmingCoin then
        local char = LP.Character
        if char then for _, part in ipairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = true end end end
    end
end

-- ═══ Fling ═══
local function FlingTarget(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local body = Instance.new("BodyAngularVelocity")
    body.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    body.AngularVelocity = Vector3.new(0, 0, 0)
    body.Parent = hrp
    
    local av = Instance.new("BodyVelocity")
    av.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    av.Velocity = Vector3.new(0, 0, 0)
    av.Parent = hrp
    
    local flinging = true
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not flinging or not hrp.Parent then
            body:Destroy()
            av:Destroy()
            if conn then conn:Disconnect() end
            return
        end
        local dir = (hrp.Position - LP.Character.HumanoidRootPart.Position).Unit
        av.Velocity = dir * 1000
        body.AngularVelocity = Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000))
    end)
    
    task.delay(3, function()
        flinging = false
        body:Destroy()
        av:Destroy()
        if conn then conn:Disconnect() end
    end)
end

local function FlingAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then FlingTarget(player) end
    end
end

-- ═══ Добавление модулей в меню ═══
Visuals:Section("ESP")
Visuals:Module({ Name = "ESP Player", Desc = "Показывает игроков, роли и обводку", Default = false, Callback = function(state) State.ESP = state; if not state then RemoveESP() end end })

Combat:Section("Aimbot")
Combat:Module({ Name = "Silent Aim", Desc = "Автоматически целится в ближайшего игрока", Default = false, Callback = function(state) EnableSilentAim(state) end })
    :Setting({ Type = "Dropdown", Title = "Target Part", Values = { "Head", "HumanoidRootPart" }, Default = "Head", Callback = function(v) SilentAim.targetPart = v end })
    :Setting({ Type = "Slider", Title = "FOV", Min = 0, Max = 500, Default = 150, Callback = function(v) SilentAim.fov = v end })
    :Setting({ Type = "Toggle", Title = "Ignore Walls", Default = false, Callback = function(v) SilentAim.ignoreWalls = v end })

Movement:Section("Movement")
Movement:Module({ Name = "Fly", Desc = "Полёт (WASD + Space/Shift)", Default = false, Callback = function(state) State.Fly = state; EnableFly(state) end })
Movement:Module({ Name = "Speed", Desc = "Ускорение персонажа", Default = false, Callback = function(state) State.Speed = state; EnableSpeed(state, State.SpeedValue) end })
    :Setting({ Type = "Slider", Title = "Speed Value", Min = 10, Max = 200, Default = 50, Callback = function(v) State.SpeedValue = v; if State.Speed then EnableSpeed(true, v) end end })

AutoFarm:Section("Auto Farm")
AutoFarm:Module({ Name = "Auto Farm Candy", Desc = "Собирает конфеты (Candy)", Default = false, Callback = function(state) if state then StartAutoFarm(true) else StopAutoFarm(true) end end })
    :Setting({ Type = "Slider", Title = "Fly Speed", Min = 5, Max = 50, Default = 15, Callback = function(v) AutoFarmState.speed = v end })
AutoFarm:Module({ Name = "Auto Farm Coin", Desc = "Собирает монеты (Coin)", Default = false, Callback = function(state) if state then StartAutoFarm(false) else StopAutoFarm(false) end end })
    :Setting({ Type = "Slider", Title = "Fly Speed", Min = 5, Max = 50, Default = 15, Callback = function(v) AutoFarmState.speed = v end })

Misc:Section("Fling")
Misc:Module({ Name = "Fling All", Desc = "Флингает всех игроков", Action = true, Callback = function() FlingAll() end })

Misc:Section("Server")
Misc:Module({ Name = "Rejoin", Desc = "Перезайти на текущий сервер", Action = true, Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end })

Hub:SelectCategory(Visuals)
RunService.Heartbeat:Connect(UpdateESP)
RunService.Heartbeat:Connect(function()
    -- Динамическое обновление списка игроков для вкладки Players
    if Hub.pagePlayers and Hub.pagePlayers.Visible then
        -- (можно добавить логику обновления списка)
    end
end)

Hub:Notify({ Title = "QovickHub", Content = "Загружено! ESP + AutoFarm + Fling", Duration = 5 })
