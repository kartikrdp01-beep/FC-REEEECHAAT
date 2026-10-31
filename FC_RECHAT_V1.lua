--[[
    FC RECHAT V1
    Clean chat + AI demo for Roblox / Delta
    - No Firebase
    - No music, commands, themes tab, RP-name editing, ranks, or admin systems
    - Local demo chat (messages are visible only to this client)
    - AI demo mode works offline
    - Optional AI proxy integration: set AI_ENDPOINT to your own HTTPS backend.

    IMPORTANT:
    Never put a private AI API key in this client script.
    A Roblox client/executor script can be inspected. Keep provider keys on
    your own backend and let this script call that backend.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ========================= CONFIG =========================
local APP_NAME = "FC RECHAT V1"
local AI_ENDPOINT = "" -- Example: "https://your-domain.example/api/chat"
local USE_DEMO_AI = true -- true = offline demo replies; false = call AI_ENDPOINT
local MAX_MESSAGES = 100
local ACCENT = Color3.fromRGB(151, 102, 255)
local BG = Color3.fromRGB(15, 13, 23)
local PANEL = Color3.fromRGB(24, 21, 35)
local PANEL_2 = Color3.fromRGB(33, 29, 47)
local TEXT = Color3.fromRGB(245, 241, 255)
local MUTED = Color3.fromRGB(159, 150, 179)

-- ========================= CLEANUP =========================
local old = PlayerGui:FindFirstChild("FC_RECHAT_V1")
if old then old:Destroy() end

local ScreenGui

-- ========================= HELPERS =========================
local function create(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, obj)
end

local function outline(obj, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or ACCENT,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, obj)
end

local function tween(obj, duration, props)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function makeLabel(parent, text, size, position, fontSize, color)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        Size = size,
        Position = position,
        Font = Enum.Font.Gotham,
        TextSize = fontSize or 13,
        TextColor3 = color or TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

local function makeButton(parent, text, size, position, color)
    local b = create("TextButton", {
        Size = size,
        Position = position,
        BackgroundColor3 = color or PANEL_2,
        Text = text,
        TextColor3 = TEXT,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false
    }, parent)
    round(b, 9)
    b.MouseEnter:Connect(function()
        tween(b, 0.12, {BackgroundColor3 = ACCENT})
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.12, {BackgroundColor3 = color or PANEL_2})
    end)
    return b
end

local function notify(text)
    local toast = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 14),
        Size = UDim2.new(0, 230, 0, 38),
        BackgroundColor3 = PANEL_2,
        Text = text,
        TextColor3 = TEXT,
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        ZIndex = 30
    }, ScreenGui)
    round(toast, 10)
    outline(toast, ACCENT, 1)
    toast.TextWrapped = true
    tween(toast, 0.2, {Position = UDim2.new(1, -14, 0, 24)})
    task.delay(2.3, function()
        if toast.Parent then
            tween(toast, 0.2, {BackgroundTransparency = 1, TextTransparency = 1})
            task.wait(0.22)
            toast:Destroy()
        end
    end)
end

-- ========================= ROOT UI =========================
ScreenGui = create("ScreenGui", {
    Name = "FC_RECHAT_V1",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local Main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.92, 0, 0.78, 0),
    BackgroundColor3 = BG,
    ClipsDescendants = true
}, ScreenGui)
Main.Size = UDim2.fromOffset(420, 570)
round(Main, 16)
outline(Main, ACCENT, 1.5)
local UIScale = create("UIScale", {Scale = 1}, Main)
local function updateScale()
    local cam = workspace.CurrentCamera
    if cam then
        local v = cam.ViewportSize
        UIScale.Scale = math.clamp(math.min(v.X / 430, v.Y / 610), 0.72, 1)
    end
end
updateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local sizeConstraint = create("UISizeConstraint", {
    MinSize = Vector2.new(300, 390),
    MaxSize = Vector2.new(520, 720)
}, Main)

local Header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = PANEL
}, Main)
round(Header, 16)

local HeaderMask = create("Frame", {
    Position = UDim2.new(0, 0, 1, -14),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
}, Header)

local Brand = makeLabel(Header, "✦  FC RECHAT", UDim2.new(1, -120, 0, 25), UDim2.new(0, 17, 0, 7), 17, TEXT)
Brand.Font = Enum.Font.GothamBold
local Version = makeLabel(Header, "PRIVATE CHAT EXPERIENCE  •  V1", UDim2.new(1, -120, 0, 15), UDim2.new(0, 18, 0, 32), 8, MUTED)

local Minimize = makeButton(Header, "—", UDim2.fromOffset(32, 30), UDim2.new(1, -78, 0, 14))
local Close = makeButton(Header, "×", UDim2.fromOffset(32, 30), UDim2.new(1, -39, 0, 14), Color3.fromRGB(100, 43, 63))

local TabBar = create("Frame", {
    Position = UDim2.new(0, 12, 0, 68),
    Size = UDim2.new(1, -24, 0, 38),
    BackgroundColor3 = PANEL,
}, Main)
round(TabBar, 10)

local function tabButton(name, x, width)
    local b = makeButton(TabBar, name, UDim2.new(0, width, 1, -6), UDim2.new(0, x, 0, 3))
    b.Name = name .. "Tab"
    return b
end

local ChatTab = tabButton("CHAT", 3, 63)
local AITab = tabButton("FC AI", 69, 55)
local StickerTab = tabButton("STICKERS", 127, 73)
local MusicTab = tabButton("MUSIC", 203, 55)
local RanksTab = tabButton("RANKS", 261, 55)
local AboutTab = tabButton("ABOUT", 319, 62)

local Pages = create("Frame", {
    Position = UDim2.new(0, 12, 0, 116),
    Size = UDim2.new(1, -24, 1, -128),
    BackgroundTransparency = 1
}, Main)

local function newPage(name)
    return create("Frame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false
    }, Pages)
end

local ChatPage = newPage("ChatPage")
local AIPage = newPage("AIPage")
local AboutPage = newPage("AboutPage")
local StickerPage = newPage("StickerPage")
local MusicPage = newPage("MusicPage")
local RanksPage = newPage("RanksPage")

local function switchPage(which)
    ChatPage.Visible = which == "CHAT"
    AIPage.Visible = which == "AI"
    AboutPage.Visible = which == "ABOUT"
    StickerPage.Visible = which == "STICKERS"
    MusicPage.Visible = which == "MUSIC"
    RanksPage.Visible = which == "RANKS"
    ChatTab.BackgroundColor3 = which == "CHAT" and ACCENT or PANEL_2
    AITab.BackgroundColor3 = which == "AI" and ACCENT or PANEL_2
    StickerTab.BackgroundColor3 = which == "STICKERS" and ACCENT or PANEL_2
    MusicTab.BackgroundColor3 = which == "MUSIC" and ACCENT or PANEL_2
    RanksTab.BackgroundColor3 = which == "RANKS" and ACCENT or PANEL_2
    AboutTab.BackgroundColor3 = which == "ABOUT" and ACCENT or PANEL_2
end

ChatTab.Activated:Connect(function() switchPage("CHAT") end)
AITab.Activated:Connect(function() switchPage("AI") end)
AboutTab.Activated:Connect(function() switchPage("ABOUT") end)
StickerTab.Activated:Connect(function() switchPage("STICKERS") end)
MusicTab.Activated:Connect(function() switchPage("MUSIC") end)
RanksTab.Activated:Connect(function() switchPage("RANKS") end)

local FC_RANKS = {
    ["ahmed_noobda7"]     = {title = "[DIRECTOR]", type = "rgb"},
    ["cr1mz_zane"]        = {title = "[DIRECTOR]", type = "rgb"},
    ["pariqueen775"]      = {title = "[CUTE]", color = Color3.fromRGB(255, 40, 40)},
    ["lunargotbanned7"]   = {title = "[COMGOD]", type = "rgb"},
    ["kabir_priv"]        = {title = "[VIP]", color = Color3.fromRGB(0, 50, 180)},
    ["mikeboyff"]         = {title = "[DIRECTOR]", type = "rgb"},
    ["editer_pxx"]        = {title = "[DIRECTOR]", type = "rgb"},
    ["mr_kittuuu"]        = {title = "[GRANDFATHER]", color = Color3.fromRGB(0, 0, 0)},
    ["ctxxleo"]           = {title = "[GRANDFATHER]", color = Color3.fromRGB(0, 0, 0)},
    ["potato25122008"]    = {title = "[GRANDFATHER]", color = Color3.fromRGB(0, 0, 0)},
    ["rishu_00118"]       = {title = "[SARDAR JI]", type = "rgb"},
    ["legend"]            = {title = "[LEGEND]", color = Color3.fromRGB(255, 0, 0)},
    ["batman"]            = {title = "[BATMAN]", color = Color3.fromRGB(0, 0, 0)},
    ["daddy"]             = {title = "[DADDY]", type = "rgb"},
    ["og"]                = {title = "[OG]", type = "rgb"},
    ["randy"]             = {title = "[RANDY]", color = Color3.fromRGB(255, 105, 180)},
    ["apex_shadow728"]    = {title = "[BABE]", type = "rgb"},
    ["archugotbanned6"]   = {title = "[CUTE]", type = "rgb"},
    ["aadi55523"]         = {title = "[PAPPU PELU]", color = Color3.fromRGB(255, 215, 0)},
    ["baap"]              = {title = "[BAAP]", type = "rgb"},
    ["ninja"]             = {title = "[NINJA]", color = Color3.fromRGB(255, 0, 0)},
    ["cow"]               = {title = "[COW]", color = Color3.fromRGB(0, 0, 0)},
    ["classy"]            = {title = "[CLASSY]", color = Color3.fromRGB(255, 255, 255)},
    ["honored_one"]       = {title = "[HONORED_ONE]", type = "rgb"},
    ["oldie"]             = {title = "[OLDIE]", type = "rgb"},
    ["almighty"]          = {title = "[ALMIGHTY]", type = "rgb"},
    ["owner"]             = {title = "[OWNER]", type = "rgb"},
    ["lord"]              = {title = "[LORD]", color = Color3.fromRGB(255, 0, 0)},
    ["light"]             = {title = "[LIGHT]", color = Color3.fromRGB(255, 215, 0)},
    ["randy1"]            = {title = "[RANDY1]", color = Color3.fromRGB(255, 105, 180)}
}

local function getFCRank(username)
    local entry = FC_RANKS[string.lower(username or "")]
    if entry then return entry end
    return nil
end

local function rankPrefix(username)
    local entry = getFCRank(username)
    return entry and (entry.title .. " ") or ""
end
\n-- ========================= CHAT PAGE =========================
local ChatInfo = makeLabel(ChatPage, "LOCAL DEMO CHAT  •  Messages stay on this device", UDim2.new(1, 0, 0, 22), UDim2.new(0, 3, 0, 0), 9, MUTED)

local MessageScroll = create("ScrollingFrame", {
    Position = UDim2.new(0, 0, 0, 27),
    Size = UDim2.new(1, 0, 1, -82),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = ACCENT,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, ChatPage)
round(MessageScroll, 12)
create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 9),
    PaddingRight = UDim.new(0, 9)
}, MessageScroll)
local MessageLayout = create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
}, MessageScroll)

local Composer = create("Frame", {
    Position = UDim2.new(0, 0, 1, -46),
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = PANEL
}, ChatPage)
round(Composer, 11)

local ChatInput = create("TextBox", {
    Position = UDim2.new(0, 10, 0, 4),
    Size = UDim2.new(1, -68, 1, -8),
    BackgroundTransparency = 1,
    PlaceholderText = "Write a message...",
    PlaceholderColor3 = MUTED,
    Text = "",
    TextColor3 = TEXT,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left
}, Composer)

local Send = makeButton(Composer, "➤", UDim2.fromOffset(42, 34), UDim2.new(1, -46, 0, 4), ACCENT)

local messageCount = 0
local function addMessage(sender, body, mine, isAI)
    messageCount += 1
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = messageCount
    }, MessageScroll)

    local bubble = create("Frame", {
        AnchorPoint = Vector2.new(mine and 1 or 0, 0),
        Position = UDim2.new(mine and 1 or 0, 0, 0, 0),
        Size = UDim2.new(0.86, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = isAI and Color3.fromRGB(49, 36, 75) or (mine and Color3.fromRGB(67, 47, 105) or PANEL_2)
    }, row)
    round(bubble, 11)
    if isAI then outline(bubble, ACCENT, 1, 0.35) end

    local name = makeLabel(bubble, sender, UDim2.new(1, -18, 0, 16), UDim2.new(0, 9, 0, 6), 9, isAI and ACCENT or MUTED)
    name.Font = Enum.Font.GothamBold

    if typeof(body) == "string" and body:match("^rbxthumb://") then
        local image = create("ImageLabel", {
            Position = UDim2.new(0, 9, 0, 23),
            Size = UDim2.fromOffset(112, 112),
            BackgroundTransparency = 1,
            Image = body,
            ScaleType = Enum.ScaleType.Fit
        }, bubble)
        create("UIPadding", {PaddingBottom = UDim.new(0, 8)}, bubble)
    else
    local content = create("TextLabel", {
        Position = UDim2.new(0, 9, 0, 23),
        Size = UDim2.new(1, -18, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = body,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextColor3 = TEXT,
        TextSize = 12,
        Font = Enum.Font.Gotham
    }, bubble)

    create("UIPadding", {
        PaddingBottom = UDim.new(0, 8)
    }, bubble)
    end

    task.defer(function()
        MessageScroll.CanvasPosition = Vector2.new(0, math.max(0, MessageLayout.AbsoluteContentSize.Y))
    end)

    while #MessageScroll:GetChildren() > MAX_MESSAGES * 2 + 5 do
        local first
        for _, child in ipairs(MessageScroll:GetChildren()) do
            if child:IsA("Frame") and (not first or child.LayoutOrder < first.LayoutOrder) then
                first = child
            end
        end
        if first then first:Destroy() else break end
    end
end

local function sendChat()
    local text = ChatInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return end
    ChatInput.Text = ""
    addMessage(rankPrefix(Player.Name) .. Player.DisplayName .. "  •  You", text, true, false)
end

Send.Activated:Connect(sendChat)
ChatInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then sendChat() end
end)

addMessage("FC RECHAT", "Welcome! This is your clean FC RECHAT demo. Open FC AI to try the assistant.", false, true)

-- ========================= AI PAGE =========================
local AIHeader = makeLabel(AIPage, "FC AI  /  PERSONAL ASSISTANT", UDim2.new(1, 0, 0, 24), UDim2.new(0, 2, 0, 0), 12, TEXT)
AIHeader.Font = Enum.Font.GothamBold

local AIStatus = makeLabel(AIPage, "●  DEMO MODE • Offline replies", UDim2.new(1, 0, 0, 18), UDim2.new(0, 2, 0, 24), 9, Color3.fromRGB(125, 220, 165))

local AIHistory = create("ScrollingFrame", {
    Position = UDim2.new(0, 0, 0, 49),
    Size = UDim2.new(1, 0, 1, -105),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = ACCENT,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, AIPage)
round(AIHistory, 12)
create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 9),
    PaddingRight = UDim.new(0, 9)
}, AIHistory)
local AIList = create("UIListLayout", {Padding = UDim.new(0, 8)}, AIHistory)

local AIComposer = create("Frame", {
    Position = UDim2.new(0, 0, 1, -46),
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = PANEL
}, AIPage)
round(AIComposer, 11)

local AIInput = create("TextBox", {
    Position = UDim2.new(0, 10, 0, 4),
    Size = UDim2.new(1, -68, 1, -8),
    BackgroundTransparency = 1,
    PlaceholderText = "Ask FC AI anything...",
    PlaceholderColor3 = MUTED,
    Text = "",
    TextColor3 = TEXT,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left
}, AIComposer)
local AISend = makeButton(AIComposer, "➤", UDim2.fromOffset(42, 34), UDim2.new(1, -46, 0, 4), ACCENT)

local function addAIMessage(sender, body, mine)
    local bubble = create("Frame", {
        Size = UDim2.new(0.9, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(mine and 1 or 0, 0),
        Position = UDim2.new(mine and 1 or 0, 0, 0, 0),
        BackgroundColor3 = mine and Color3.fromRGB(67, 47, 105) or Color3.fromRGB(49, 36, 75)
    }, create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    }, AIHistory))
    round(bubble, 10)
    local senderLabel = makeLabel(bubble, sender, UDim2.new(1, -18, 0, 16), UDim2.new(0, 9, 0, 6), 9, mine and MUTED or ACCENT)
    senderLabel.Font = Enum.Font.GothamBold
    local bodyLabel = create("TextLabel", {
        Position = UDim2.new(0, 9, 0, 23),
        Size = UDim2.new(1, -18, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = body,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextColor3 = TEXT,
        TextSize = 12,
        Font = Enum.Font.Gotham
    }, bubble)
    create("UIPadding", {PaddingBottom = UDim.new(0, 8)}, bubble)
    task.defer(function()
        AIHistory.CanvasPosition = Vector2.new(0, math.max(0, AIList.AbsoluteContentSize.Y))
    end)
end

local function demoReply(prompt)
    local p = string.lower(prompt)
    if p:find("hello") or p:find("hi") then
        return "Hey! FC AI is online. What are we building today?"
    elseif p:find("roblox") then
        return "Roblox project mode activated. Tell me what system or UI you want to create."
    elseif p:find("who are you") then
        return "I'm FC AI, the assistant inside FC RECHAT V1."
    elseif p:find("help") then
        return "I can help brainstorm features, explain code, debug Lua, and plan your next project."
    else
        return "Demo response received: \"" .. prompt .. "\"\n\nConnect your own secure AI proxy in AI_ENDPOINT to enable real AI replies."
    end
end

local function requestAI(prompt)
    if USE_DEMO_AI then
        task.wait(0.55)
        return demoReply(prompt)
    end

    if AI_ENDPOINT == "" then
        return "AI endpoint is not configured yet. Add your HTTPS backend URL to AI_ENDPOINT."
    end

    local requestFunction = (syn and syn.request) or (http and http.request) or http_request or request
    if not requestFunction then
        return "This executor does not expose an HTTP request function."
    end

    local payload = HttpService:JSONEncode({
        message = prompt,
        user = Player.Name,
        app = APP_NAME
    })

    local ok, response = pcall(function()
        return requestFunction({
            Url = AI_ENDPOINT,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end)

    if not ok or not response then
        return "Could not reach the AI service. Check your backend URL and connection."
    end

    local body = response.Body or response.body or ""
    local decodedOk, decoded = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if decodedOk and type(decoded) == "table" then
        return tostring(decoded.reply or decoded.response or decoded.message or "The AI service returned no reply.")
    end
    return tostring(body):sub(1, 3000)
end

local aiBusy = false
local function sendAI()
    local prompt = AIInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if prompt == "" or aiBusy then return end
    AIInput.Text = ""
    addAIMessage("YOU", prompt, true)
    aiBusy = true
    AIStatus.Text = "●  FC AI IS THINKING..."
    AIStatus.TextColor3 = ACCENT
    task.spawn(function()
        local answer = requestAI(prompt)
        addAIMessage("FC AI", answer, false)
        aiBusy = false
        AIStatus.Text = USE_DEMO_AI and "●  DEMO MODE • Offline replies" or "●  AI SERVICE READY"
        AIStatus.TextColor3 = Color3.fromRGB(125, 220, 165)
    end)
end

AISend.Activated:Connect(sendAI)
AIInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then sendAI() end
end)
addAIMessage("FC AI", "Hello! I'm FC AI. This demo works without a key or database.", false)

-- ========================= ABOUT PAGE =========================
local AboutCard = create("Frame", {
    Size = UDim2.new(1, 0, 0, 190),
    Position = UDim2.new(0, 0, 0, 5),
    BackgroundColor3 = PANEL
}, AboutPage)
round(AboutCard, 13)
outline(AboutCard, ACCENT, 1, 0.5)

local AboutTitle = makeLabel(AboutCard, "FC RECHAT V1", UDim2.new(1, -24, 0, 30), UDim2.new(0, 12, 0, 12), 18, TEXT)
AboutTitle.Font = Enum.Font.GothamBold
makeLabel(AboutCard, "A lightweight chat + AI interface demo.", UDim2.new(1, -24, 0, 22), UDim2.new(0, 12, 0, 48), 11, MUTED)
makeLabel(AboutCard, "• Firebase removed completely\n• Music player + source sticker pack + preset ranks\n• No Firebase / no Zane branding or RP-name tools\n• Chat remains local demo only\n• AI uses offline demo replies by default", UDim2.new(1, -24, 0, 100), UDim2.new(0, 12, 0, 82), 11, TEXT).TextYAlignment = Enum.TextYAlignment.Top

local SetupNote = create("TextLabel", {
    Position = UDim2.new(0, 4, 0, 210),
    Size = UDim2.new(1, -8, 0, 90),
    BackgroundTransparency = 1,
    Text = "REAL AI SETUP\nCreate a small HTTPS backend that accepts { message = \"...\" } and returns { reply = \"...\" }. Keep your AI provider key on that backend, never in this script. Then set AI_ENDPOINT and USE_DEMO_AI = false.",
    TextColor3 = MUTED,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
}, AboutPage)


-- ========================= STICKER PICKER =========================
local FC_STICKERS = {
    {url="rbxthumb://type=Asset&id=126155452969559&w=420&h=420", label="Sticker 1"},
    {url="rbxthumb://type=Asset&id=76528918733148&w=420&h=420", label="Sticker 2"},
    {url="rbxthumb://type=Asset&id=139746534721570&w=420&h=420", label="Sticker 3"},
    {url="rbxthumb://type=Asset&id=107882158860216&w=420&h=420", label="Sticker 4"},
    {url="rbxthumb://type=Asset&id=99467189295335&w=420&h=420", label="Sticker 5"},
    {url="rbxthumb://type=Asset&id=114738142020573&w=420&h=420", label="Sticker 6"},
    {url="rbxthumb://type=Asset&id=100644268219896&w=420&h=420", label="Sticker 7"},
    {url="rbxthumb://type=Asset&id=82732486060449&w=420&h=420", label="Sticker 8"},
    {url="rbxthumb://type=Asset&id=84345768144066&w=420&h=420", label="Sticker 9"},
    {url="rbxthumb://type=Asset&id=85611228914039&w=420&h=420", label="Sticker 10"},
    {url="rbxthumb://type=Asset&id=126857592936719&w=420&h=420", label="Sticker 11"},
    {url="rbxthumb://type=Asset&id=106945724992072&w=420&h=420", label="Sticker 12"},
    {url="rbxthumb://type=Asset&id=102454731178873&w=420&h=420", label="Sticker 13"},
    {url="rbxthumb://type=Asset&id=33230128&w=420&h=420", label="Sticker 14"},
    {url="rbxthumb://type=Asset&id=33199969&w=420&h=420", label="Sticker 15"},
    {url="rbxthumb://type=Asset&id=33200194&w=420&h=420", label="Sticker 16"},
    {url="rbxthumb://type=Asset&id=33200310&w=420&h=420", label="Sticker 17"},
    {url="rbxthumb://type=Asset&id=33200394&w=420&h=420", label="Sticker 18"},
    {url="rbxthumb://type=Asset&id=250852269&w=420&h=420", label="Sticker 19"},
    {url="rbxthumb://type=Asset&id=146447101&w=420&h=420", label="Sticker 20"},
    {url="rbxthumb://type=Asset&id=36061967&w=420&h=420", label="Sticker 21"},
    {url="rbxthumb://type=Asset&id=31325913&w=420&h=420", label="Sticker 22"},
    {url="rbxthumb://type=Asset&id=15805629980&w=420&h=420", label="Sticker 23"},
    {url="rbxthumb://type=Asset&id=16022747924&w=420&h=420", label="Sticker 24"},
    {url="rbxthumb://type=Asset&id=87693756574279&w=420&h=420", label="Sticker 25"},
    {url="rbxthumb://type=Asset&id=72793460663497&w=420&h=420", label="Sticker 26"},
    {url="rbxthumb://type=Asset&id=72687512455219&w=420&h=420", label="Sticker 27"},
    {url="rbxthumb://type=Asset&id=95112780943766&w=420&h=420", label="Sticker 28"},
    {url="rbxthumb://type=Asset&id=130819442854007&w=420&h=420", label="Sticker 29"},
    {url="rbxthumb://type=Asset&id=15995320422&w=420&h=420", label="Sticker 30"},
    {url="rbxthumb://type=Asset&id=97531898393056&w=420&h=420", label="Sticker 31"},
    {url="rbxthumb://type=Asset&id=140080676995337&w=420&h=420", label="Sticker 32"},
    {url="rbxthumb://type=Asset&id=85186927570541&w=420&h=420", label="Sticker 33"},
    {url="rbxthumb://type=Asset&id=104982476854875&w=420&h=420", label="Sticker 34"},
    {url="rbxthumb://type=Asset&id=75855310731142&w=420&h=420", label="Sticker 35"},
    {url="rbxthumb://type=Asset&id=15770267559&w=420&h=420", label="Sticker 36"},
    {url="rbxthumb://type=Asset&id=5018114793&w=420&h=420", label="Sticker 37"},
    {url="rbxthumb://type=Asset&id=15286481424&w=420&h=420", label="Sticker 38"},
    {url="rbxthumb://type=Asset&id=128344314510489&w=420&h=420", label="Sticker 39"},
    {url="rbxthumb://type=Asset&id=136067952747541&w=420&h=420", label="Sticker 40"},
    {url="rbxthumb://type=Asset&id=99958778133344&w=420&h=420", label="Sticker 41"},
    {url="rbxthumb://type=Asset&id=119529499&w=420&h=420", label="Sticker 42"},
    {url="rbxthumb://type=Asset&id=87410449404372&w=420&h=420", label="Sticker 43"},
    {url="rbxthumb://type=Asset&id=135626579756980&w=420&h=420", label="Sticker 44"},
    {url="rbxthumb://type=Asset&id=139957369535197&w=420&h=420", label="Sticker 45"},
    {url="rbxthumb://type=Asset&id=76041428119690&w=420&h=420", label="Sticker 46"},
    {url="rbxthumb://type=Asset&id=121519423315170&w=420&h=420", label="Sticker 47"},
    {url="rbxthumb://type=Asset&id=93373631313287&w=420&h=420", label="Sticker 48"},
    {url="rbxthumb://type=Asset&id=97394539876577&w=420&h=420", label="Sticker 49"},
    {url="rbxthumb://type=Asset&id=101940253916665&w=420&h=420", label="Sticker 50"},
    {url="rbxthumb://type=Asset&id=78230203607312&w=420&h=420", label="Sticker 51"},
    {url="rbxthumb://type=Asset&id=80353264115457&w=420&h=420", label="Sticker 52"},
    {url="rbxthumb://type=Asset&id=101341480444341&w=420&h=420", label="Sticker 53"},
    {url="rbxthumb://type=Asset&id=137764081130069&w=420&h=420", label="Sticker 54"},
    {url="rbxthumb://type=Asset&id=129411122687899&w=420&h=420", label="Sticker 55"},
    {url="rbxthumb://type=Asset&id=108586661676568&w=420&h=420", label="Sticker 56"},
    {url="rbxthumb://type=Asset&id=139170316377078&w=420&h=420", label="Sticker 57"},
    {url="rbxthumb://type=Asset&id=131387856318248&w=420&h=420", label="Sticker 58"},
    {url="rbxthumb://type=Asset&id=85031627481050&w=420&h=420", label="Sticker 59"},
    {url="rbxthumb://type=Asset&id=90949982441987&w=420&h=420", label="Sticker 60"},
    {url="rbxthumb://type=Asset&id=123566128421906&w=420&h=420", label="Sticker 61"},
}
local StickerTitle = makeLabel(StickerPage, "STICKER COLLECTION", UDim2.new(1, 0, 0, 24), UDim2.new(0, 2, 0, 0), 12, TEXT)
StickerTitle.Font = Enum.Font.GothamBold
makeLabel(StickerPage, "Tap a sticker to post it in the local chat demo.", UDim2.new(1, 0, 0, 18), UDim2.new(0, 2, 0, 23), 9, MUTED)
local StickerScroll = create("ScrollingFrame", {
    Position = UDim2.new(0, 0, 0, 48), Size = UDim2.new(1, 0, 1, -48),
    BackgroundColor3 = PANEL, BorderSizePixel = 0, ScrollBarThickness = 3,
    ScrollBarImageColor3 = ACCENT, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y
}, StickerPage)
round(StickerScroll, 12)
create("UIPadding", {PaddingTop=UDim.new(0,9), PaddingLeft=UDim.new(0,9), PaddingRight=UDim.new(0,9), PaddingBottom=UDim.new(0,9)}, StickerScroll)
local StickerGrid = create("UIGridLayout", {
    CellSize = UDim2.new(0, 78, 0, 82), CellPadding = UDim2.new(0, 8, 0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
}, StickerScroll)
for i, item in ipairs(FC_STICKERS) do
    local b = create("ImageButton", {
        Name = "Sticker_" .. i, BackgroundColor3 = PANEL_2, Image = item.url,
        ScaleType = Enum.ScaleType.Fit, AutoButtonColor = true, LayoutOrder = i
    }, StickerScroll)
    round(b, 9); outline(b, ACCENT, 1, 0.55)
    b.Activated:Connect(function()
        addMessage(Player.DisplayName .. " • You", item.url, true, false)
        notify(item.label .. " sent")
        switchPage("CHAT")
    end)
end

-- ========================= LOCAL MUSIC PLAYER =========================
local MusicTitle = makeLabel(MusicPage, "FC MUSIC PLAYER", UDim2.new(1,0,0,26), UDim2.new(0,2,0,0), 13, TEXT)
MusicTitle.Font = Enum.Font.GothamBold
makeLabel(MusicPage, "Enter a Roblox audio asset ID you are allowed to use.", UDim2.new(1,0,0,20), UDim2.new(0,2,0,25), 9, MUTED)
local MusicInput = create("TextBox", {
    Position=UDim2.new(0,0,0,55), Size=UDim2.new(1,0,0,40), BackgroundColor3=PANEL,
    Text="", PlaceholderText="Audio asset ID (numbers only)", PlaceholderColor3=MUTED,
    TextColor3=TEXT, TextSize=12, Font=Enum.Font.Gotham, ClearTextOnFocus=false
}, MusicPage)
round(MusicInput, 10); outline(MusicInput, ACCENT, 1, 0.5)
local NowPlaying = makeLabel(MusicPage, "Nothing playing", UDim2.new(1,0,0,24), UDim2.new(0,2,0,105), 11, MUTED)
NowPlaying.TextXAlignment = Enum.TextXAlignment.Center
local musicSound = Instance.new("Sound")
musicSound.Name = "FCRechatMusic"
musicSound.Volume = 0.55
musicSound.Looped = false
musicSound.Parent = game:GetService("SoundService")
local PlayMusic = makeButton(MusicPage, "▶ PLAY", UDim2.new(0.48,0,0,38), UDim2.new(0,0,0,140), ACCENT)
local StopMusic = makeButton(MusicPage, "■ STOP", UDim2.new(0.48,0,0,38), UDim2.new(0.52,0,0,140), PANEL_2)
local LoopMusic = makeButton(MusicPage, "LOOP: OFF", UDim2.new(1,0,0,34), UDim2.new(0,0,0,186), PANEL_2)
local VolumeLabel = makeLabel(MusicPage, "Volume: 55%", UDim2.new(1,0,0,18), UDim2.new(0,2,0,228), 10, MUTED)
local Volume = create("TextBox", {
    Position=UDim2.new(0,0,0,250), Size=UDim2.new(1,0,0,36), BackgroundColor3=PANEL,
    Text="55", PlaceholderText="0-100", TextColor3=TEXT, TextSize=12, Font=Enum.Font.Gotham,
    ClearTextOnFocus=false
}, MusicPage)
round(Volume, 9)
local loopOn = false
PlayMusic.Activated:Connect(function()
    local id = MusicInput.Text:match("%d+")
    if not id then notify("Enter a numeric audio ID"); return end
    musicSound:Stop()
    musicSound.SoundId = "rbxassetid://" .. id
    musicSound:Play()
    NowPlaying.Text = "Playing asset " .. id
    notify("Music playback requested")
end)
StopMusic.Activated:Connect(function()
    musicSound:Stop(); NowPlaying.Text = "Stopped"
end)
LoopMusic.Activated:Connect(function()
    loopOn = not loopOn; musicSound.Looped = loopOn
    LoopMusic.Text = loopOn and "LOOP: ON" or "LOOP: OFF"
end)
Volume.FocusLost:Connect(function()
    local n = tonumber(Volume.Text)
    if n then
        n = math.clamp(n, 0, 100); musicSound.Volume = n / 100
        Volume.Text = tostring(n); VolumeLabel.Text = "Volume: " .. n .. "%"
    end
end)

-- ========================= RANK DIRECTORY =========================
local RankTitle = makeLabel(RanksPage, "FC RECHAT • RANK DIRECTORY", UDim2.new(1,0,0,24), UDim2.new(0,2,0,0), 12, TEXT)
RankTitle.Font = Enum.Font.GothamBold
makeLabel(RanksPage, "Ranks shown here are the source file's preset username tags.", UDim2.new(1,0,0,18), UDim2.new(0,2,0,22), 9, MUTED)
local RankScroll = create("ScrollingFrame", {
    Position=UDim2.new(0,0,0,45), Size=UDim2.new(1,0,1,-45), BackgroundColor3=PANEL,
    BorderSizePixel=0, ScrollBarThickness=3, ScrollBarImageColor3=ACCENT,
    CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y
}, RanksPage)
round(RankScroll, 12)
create("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,9), PaddingRight=UDim.new(0,9)}, RankScroll)
create("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, RankScroll)
local rankNames = {}
for username, data in pairs(FC_RANKS) do table.insert(rankNames, {username=username, data=data}) end
table.sort(rankNames, function(a,b) return a.username < b.username end)
for _, entry in ipairs(rankNames) do
    local row = create("Frame", {Size=UDim2.new(1,0,0,34), BackgroundColor3=PANEL_2}, RankScroll)
    round(row, 8)
    local title = makeLabel(row, entry.data.title, UDim2.new(0.48,0,1,0), UDim2.new(0,9,0,0), 10,
        entry.data.color or ACCENT)
    title.Font = Enum.Font.GothamBold
    makeLabel(row, "@" .. entry.username, UDim2.new(0.48,0,1,0), UDim2.new(0.5,0,0,0), 10, TEXT)
end

\n-- ========================= WINDOW CONTROLS =========================
local minimized = false
local savedSize = Main.Size

Minimize.Activated:Connect(function()
    if not minimized then
        minimized = true
        tween(Main, 0.2, {Size = UDim2.fromOffset(250, 58)})
        TabBar.Visible = false
        Pages.Visible = false
        Version.Text = "TAP □ TO RESTORE"
        Minimize.Text = "□"
    else
        minimized = false
        tween(Main, 0.2, {Size = savedSize})
        TabBar.Visible = true
        Pages.Visible = true
        Version.Text = "PRIVATE CHAT EXPERIENCE  •  V1"
        Minimize.Text = "—"
    end
end)

Close.Activated:Connect(function()
    tween(Main, 0.18, {BackgroundTransparency = 1, Size = UDim2.fromOffset(180, 40)})
    task.wait(0.2)
    ScreenGui:Destroy()
end)

-- Drag window from header (mouse + touch)
local dragging = false
local dragInput, dragStart, startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

-- Keep the panel within the visible screen after resolution changes.
local function clampPanel()
    if not Main.Parent then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local pos = Main.AbsolutePosition
    local size = Main.AbsoluteSize
    local x = math.clamp(pos.X, 0, math.max(0, viewport.X - size.X))
    local y = math.clamp(pos.Y, 0, math.max(0, viewport.Y - size.Y))
    if math.abs(x - pos.X) > 1 or math.abs(y - pos.Y) > 1 then
        Main.Position = UDim2.fromOffset(x + size.X / 2, y + size.Y / 2)
        Main.AnchorPoint = Vector2.new(0.5, 0.5)
    end
end

switchPage("CHAT")
notify("FC RECHAT V1 loaded")
print("[FC RECHAT V1] Ready • Firebase-free demo")
