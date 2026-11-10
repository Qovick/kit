-- mm2 kit :: fresh write
-- part 1/4 : config, registry, fetch, tap guard, resolve

local Kit = {}

Kit.cfg = {
    name      = "Kit",
    tagline   = "MM2 loader",
    theme     = "graphite",
    accent    = Color3.fromRGB(240, 168, 64),
    hotkey    = Enum.KeyCode.RightControl,
    uiLib     = "https://raw.githubusercontent.com/PulseZax/Slate/refs/heads/main/.lua",
    limit     = 6,       -- seconds before "still warming"
    tapGap    = 0.5,     -- seconds between accepted taps
}

Kit.games = {
    {
        id       = "mm2",
        title    = "Murder Mystery 2",
        places   = { 142823291 },
        universe = 66654135,
        source   = "https://api.luarmor.net/files/v4/loaders/5857a6cfae3b902eb3c2dff7cdbf173b.lua",
        visible  = true,
        tint     = Color3.fromRGB(214, 68, 88),
    },
}

Kit.thumb = function(placeId)
    return string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", placeId)
end

Kit.pull = function(entry)
    local ok, err = pcall(function()
        local body = game:HttpGet(entry.source)
        local chunk = loadstring(body, "@kit:" .. entry.id)
        if not chunk then
            error("compile failed")
        end
        return chunk()
    end)
    return ok, err
end

Kit.tap = function(holder, action)
    if type(holder) ~= "table" then
        return
    end
    local mark = 0
    for _, node in ipairs({ holder.button, holder.card, holder.hitbox }) do
        if typeof(node) == "Instance" then
            pcall(function()
                node.Active = true
                node.InputBegan:Connect(function(input)
                    local hit = input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch
                    if not hit then
                        return
                    end
                    if os.clock() - mark < Kit.cfg.tapGap then
                        return
                    end
                    mark = os.clock()
                    local ok, err = pcall(action)
                    if not ok then
                        warn("kit tap :: " .. tostring(err))
                    end
                end)
            end)
        end
    end
end

Kit.pick = function(placeId, universeId)
    for _, game in ipairs(Kit.games) do
        if game.universe and game.universe == universeId then
            return game
        end
    end
    for _, game in ipairs(Kit.games) do
        for _, id in ipairs(game.places) do
            if id == placeId then
                return game
            end
        end
    end
    return nil
end

_G.Kit = Kit

local hit = Kit.pick(game.PlaceId, game.GameId)
if hit then
    local ok, err = Kit.pull(hit)
    if not ok then
        warn("kit :: " .. hit.title .. " -> " .. tostring(err))
    end
    return
end

if type(_G.KitWin) == "table" and _G.KitWin.window then
    pcall(function()
        _G.KitWin.window:Destroy()
    end)
end
_G.KitWin = {}
-- mm2 kit :: fresh write
-- part 2/4 : window, theme, tab, status header

local Kit = _G.Kit
if not Kit then
    warn("kit :: core missing, load part 1 first")
    return
end

local Win = _G.KitWin
if not Win then
    warn("kit :: window slot missing")
    return
end

local cfg = Kit.cfg

local Slate = loadstring(game:HttpGet(cfg.uiLib), "@kit:ui")()
if not Slate then
    warn("kit :: ui lib failed")
    return
end

pcall(function() Slate.Cleanup() end)
pcall(function() Slate:PreloadIcons({ "lucide" }) end)

local window = Slate:CreateWindow({
    Name      = cfg.name,
    Subtitle  = cfg.tagline,
    Icon      = "activity",
    Logo      = true,
    Size      = UDim2.fromOffset(680, 460),
    ToggleKey = cfg.hotkey,
})

pcall(function() Slate.Theme.Preset("Graphite") end)
pcall(function() Slate:SetFontFamily("Inter") end)
pcall(function() window:SetBackdrop("noise") end)

pcall(function()
    local root = window.root
    local corner = root:FindFirstChildOfClass("UICorner")
    if corner then
        corner.CornerRadius = UDim.new(0, 8)
    end
    local stroke = root:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Thickness = 1
        stroke.Color = cfg.accent
        stroke.Transparency = 0.55
    end
end)

Win.window = window
Win.slate = Slate
Win.tab = window:CreateTab({ Name = "Kit", Icon = "server" })

local mapName = "unknown map"
pcall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if info and info.Name then
        mapName = info.Name
    end
end)

local matched = Kit.pick(game.PlaceId, game.GameId)

do
    local head = Win.tab:CreateSection({ Name = "Status" })
    head:Paragraph({
        Name        = "Map: " .. mapName,
        Description = matched
            and ("Matched profile: " .. matched.title .. ". Auto-run fires on inject.")
            or  ("No profile matches this map. Choose a build below."),
    })
end
-- mm2 kit :: fresh write
-- part 3/4 : build grid, arm button, timeout flow, notify

local Kit = _G.Kit
local Win = _G.KitWin
if not Kit or not Win or not Win.tab then
    warn("kit :: parts 1+2 required")
    return
end

local cfg = Kit.cfg
local Slate = Win.slate
local tab = Win.tab

local function runEntry(entry)
    Slate:Notify({
        Title       = cfg.name,
        Description = "Arming " .. entry.title,
        Icon        = "loader",
        Duration    = 4,
    })

    task.spawn(function()
        local state = { done = false, ok = nil, err = nil }

        task.spawn(function()
            state.ok, state.err = Kit.pull(entry)
            state.done = true
        end)

        local elapsed = 0
        while not state.done and elapsed < cfg.limit do
            task.wait(0.25)
            elapsed = elapsed + 0.25
        end

        if not state.done then
            Slate:Notify({
                Title       = cfg.name,
                Description = entry.title .. " still warming after " .. cfg.limit .. "s",
                Icon        = "hourglass",
                Tone        = "Warning",
                Duration    = 9,
            })
        elseif not state.ok then
            Slate:Notify({
                Title       = cfg.name,
                Description = entry.title .. " errored: " .. tostring(state.err),
                Icon        = "octagon-alert",
                Tone        = "Danger",
                Duration    = 9,
            })
        else
            Slate:Notify({
                Title       = cfg.name,
                Description = entry.title .. " armed",
                Icon        = "check-circle",
                Tone        = "Success",
                Duration    = 6,
            })
        end
    end)
end

do
    local body = tab:CreateSection({ Name = "Builds" })
    local grid = body:Grid({ Columns = 2, Height = 196, MinWidth = 188 })

    for _, entry in ipairs(Kit.games) do
        if entry.visible then
            local card = grid:Invite({
                Name        = entry.title,
                Icon        = Kit.thumb(entry.places[1]),
                Stats       = { { Text = "pid " .. tostring(entry.places[1]), Dot = entry.tint } },
                Game        = "ROBLOX",
                GameIcon    = "gamepad-2",
                Tone        = entry.tint,
                Glyph       = "play",
                ButtonText  = "Arm",
                ButtonColor = entry.tint,
                CopiedText  = "Arming",
                Callback    = function() runEntry(entry) end,
            })
            Kit.tap(card, function() runEntry(entry) end)
        end
    end
end
-- mm2 kit :: fresh write
-- part 4/4 : control, close, boot notify

local Kit = _G.Kit
local Win = _G.KitWin
if not Kit or not Win or not Win.tab then
    warn("kit :: parts 1-3 required")
    return
end

local cfg = Kit.cfg
local Slate = Win.slate
local tab = Win.tab
local window = Win.window

do
    local ctl = tab:CreateSection({ Name = "Control" })

    ctl:Button({
        Name = "Reload registry",
        Icon = "refresh-cw",
        Callback = function()
            local n = 0
            for _, entry in ipairs(Kit.games) do
                if entry.visible then n = n + 1 end
            end
            Slate:Notify({
                Title       = cfg.name,
                Description = string.format("Registry ok, %d profile(s) visible", n),
                Icon        = "list",
                Tone        = "Success",
                Duration    = 4,
            })
        end,
    })

    ctl:Button({
        Name = "Copy boot line",
        Icon = "clipboard",
        Callback = function()
            local line = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/REPO/main/kit.lua"))()'
            if setclipboard then
                pcall(setclipboard, line)
            end
            Slate:Notify({
                Title       = cfg.name,
                Description = "boot line copied (edit REPO before sharing)",
                Icon        = "clipboard-check",
                Tone        = "Success",
                Duration    = 5,
            })
        end,
    })

    ctl:Button({
        Name = "Close kit",
        Icon = "x",
        Callback = function()
            pcall(function() window:Destroy() end)
            _G.KitWin = nil
        end,
    })
end

Slate:Notify({
    Title       = cfg.name,
    Description = "Kit ready. Pick a build to arm.",
    Icon        = "triangle-alert",
    Tone        = "Warning",
    Duration    = 8,
})
