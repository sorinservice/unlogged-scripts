-- Aurexis Supported Games loader (informational only)
-- Shows a list of supported titles without bundling exploit code.

local LOCAL_ROOT = "Supported Games Script"

local REMOTE_LUNA = "https://raw.githubusercontent.com/sorinservice/luna-lib-remastered/refs/heads/main/LunaLight.lua"

local EMBEDDED_LUNA_SOURCE = [===[
-- LunaLight.lua
-- Sorin Loader • LunaLight UI Library (remastered)

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")

local player = Players.LocalPlayer

local Luna = {}
Luna.__index = Luna

-- ===== THEME =====
local Theme = {
    Background   = Color3.fromRGB(22, 22, 28),
    Header       = Color3.fromRGB(28, 28, 36),
    Accent       = Color3.fromRGB(145, 105, 255),
    Button       = Color3.fromRGB(44, 44, 56),
    Hover        = Color3.fromRGB(80, 80, 120),
    Text         = Color3.fromRGB(235, 235, 245),
    SubText      = Color3.fromRGB(170, 170, 200),
    Stroke       = Color3.fromRGB(255, 255, 255),
    Shadow       = Color3.fromRGB(0, 0, 0),
}

-- ===== UTIL =====
local function tween(inst, t, props, style, dir)
    return TweenService:Create(
        inst,
        TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    )
end

local function makeShadow(parent, radius, opacity)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084"
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24,24,276,276)
    shadow.ImageColor3 = Theme.Shadow
    shadow.ImageTransparency = 1 - (opacity or 0.25)
    shadow.Size = UDim2.new(1, radius or 24, 1, radius or 24)
    shadow.Position = UDim2.new(0, -((radius or 24)/2), 0, -((radius or 24)/2))
    shadow.ZIndex = 0
    shadow.Parent = parent
    return shadow
end

local function glassify(frame, corner)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1
    stroke.Transparency = 0.75
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local uiCorner = corner or Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = frame

    frame.BackgroundTransparency = 0.2
end

-- ===== PUBLIC: Setup theme overrides =====
function Luna:Setup(overrides)
    if typeof(overrides) ~= "table" then return end
    for k,v in pairs(overrides) do
        if Theme[k] ~= nil then Theme[k] = v end
    end
end

-- ===== INTRO (glass + blur + spinner) =====
function Luna:Intro(text, duration)
    duration = duration or 2.0
    text = text or "Loading..."

    local gui = Instance.new("ScreenGui")
    gui.Name = "LunaIntro"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Theme.Background
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.Parent = gui

    makeShadow(overlay, 80, 0.18)

    local blur = Instance.new("BlurEffect")
    blur.Name = "LunaIntroBlur"
    blur.Size = 0
    blur.Parent = Lighting
    tween(blur, 0.35, {Size = 15}):Play()

    local container = Instance.new("Frame")
    container.AnchorPoint = Vector2.new(0.5,0.5)
    container.Position = UDim2.new(0.5,0,0.5,0)
    container.Size = UDim2.new(0, 560, 0, 110)
    container.BackgroundColor3 = Theme.Header
    container.BorderSizePixel = 0
    container.BackgroundTransparency = 0.1
    container.Parent = overlay
    glassify(container)
    makeShadow(container, 36, 0.23)

    local spinner = Instance.new("ImageLabel")
    spinner.AnchorPoint = Vector2.new(0,0.5)
    spinner.Position = UDim2.new(0, 20, 0.5, 0)
    spinner.Size = UDim2.new(0, 56, 0, 56)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://3926307971"
    spinner.ImageRectOffset = Vector2.new(628, 420)
    spinner.ImageRectSize = Vector2.new(36, 36)
    spinner.ImageColor3 = Theme.Accent
    spinner.Parent = container

    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0,0.5)
    label.Position = UDim2.new(0, 96, 0.5, -12)
    label.Size = UDim2.new(1, -116, 0, 42)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = container

    local sub = Instance.new("TextLabel")
    sub.AnchorPoint = Vector2.new(0,0.5)
    sub.Position = UDim2.new(0, 96, 0.5, 24)
    sub.Size = UDim2.new(1, -116, 0, 22)
    sub.BackgroundTransparency = 1
    sub.Text = "Please wait…"
    sub.TextColor3 = Theme.SubText
    sub.Font = Enum.Font.Gotham
    sub.TextScaled = true
    sub.Parent = container

    container.BackgroundTransparency = 0.4
    label.TextTransparency, sub.TextTransparency, overlay.BackgroundTransparency = 1, 1, 1
    tween(container, 0.3, {BackgroundTransparency = 0.1}):Play()
    tween(label, 0.35, {TextTransparency = 0}):Play()
    tween(sub, 0.35, {TextTransparency = 0}):Play()
    tween(overlay, 0.35, {BackgroundTransparency = 0.3}):Play()

    task.spawn(function()
        while spinner.Parent do
            spinner.Rotation = spinner.Rotation + 10
            task.wait(0.03)
        end
    end)

    task.wait(duration)

    local t1 = tween(container, 0.25, {BackgroundTransparency = 1})
    local t2 = tween(label, 0.25, {TextTransparency = 1})
    local t3 = tween(sub, 0.25, {TextTransparency = 1})
    local t4 = tween(overlay, 0.25, {BackgroundTransparency = 1})
    t1:Play(); t2:Play(); t3:Play(); t4:Play()
    task.wait(0.26)

    pcall(function()
        if blur.Parent == Lighting then
            blur:Destroy()
        end
    end)

    gui:Destroy()
end

-- ===== MAIN WINDOW =====
function Luna:CreateWindow(cfg)
    cfg = cfg or {}
    local Title    = cfg.Title or "Loader"
    local Subtitle = cfg.Subtitle or ""
    local Count    = cfg.Count

    local gui = Instance.new("ScreenGui")
    gui.Name = "LunaLightUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 520, 0, 380)
    frame.Position = UDim2.new(0.5, -260, 0.5, -190)
    frame.BackgroundColor3 = Theme.Background
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.15
    frame.Parent = gui
    glassify(frame)
    makeShadow(frame, 30, 0.22)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 64)
    header.BackgroundColor3 = Theme.Header
    header.BorderSizePixel = 0
    header.Parent = frame
    glassify(header)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 0, 30)
    titleLabel.Position = UDim2.new(0, 16, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = Title .. (Count and ("  —  " .. tostring(Count)) or "")
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -60, 0, 22)
    subLabel.Position = UDim2.new(0, 16, 0, 36)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = Subtitle
    subLabel.TextColor3 = Theme.Accent
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 16
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = header

    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 18)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxassetid://3926305904"
    closeBtn.ImageRectOffset = Vector2.new(924, 724)
    closeBtn.ImageRectSize = Vector2.new(36, 36)
    closeBtn.ImageColor3 = Theme.Text
    closeBtn.Parent = header

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, 0.1, {ImageColor3 = Theme.Accent}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, 0.1, {ImageColor3 = Theme.Text}):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -24, 0, 34)
    searchBox.Position = UDim2.new(0, 12, 0, 76)
    searchBox.PlaceholderText = "Search…"
    searchBox.Text = ""
    searchBox.ClearTextOnFocus = false
    searchBox.TextColor3 = Theme.Text
    searchBox.PlaceholderColor3 = Theme.SubText
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 16
    searchBox.BackgroundColor3 = Theme.Button
    searchBox.BorderSizePixel = 0
    searchBox.Parent = frame
    glassify(searchBox)
    makeShadow(searchBox, 8, 0.12)

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -24, 1, -136)
    list.Position = UDim2.new(0, 12, 0, 120)
    list.CanvasSize = UDim2.new(0,0,0,0)
    list.BackgroundTransparency = 1
    list.ScrollBarThickness = 6
    list.Parent = frame

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -24, 0, 18)
    footer.Position = UDim2.new(0, 12, 1, -22)
    footer.BackgroundTransparency = 1
    footer.Text = ""
    footer.TextColor3 = Theme.SubText
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 13
    footer.TextXAlignment = Enum.TextXAlignment.Right
    footer.Parent = frame

    frame.Position = UDim2.new(0.5, -260, 0.5, -180)
    frame.BackgroundTransparency = 0.4
    tween(frame, 0.35, {Position = UDim2.new(0.5, -260, 0.5, -190), BackgroundTransparency = 0.15}):Play()

    do
        local dragging, dragStart, startPos
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end
        end)
    end

    local self = setmetatable({
        _gui = gui,
        _frame = frame,
        _header = header,
        _list = list,
        _searchBox = searchBox,
        _footer = footer,
        _games = {},
    }, Luna)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:Filter(searchBox.Text)
    end)

    return self
end

function Luna:SetFooter(text)
    if self._footer then self._footer.Text = text or "" end
end

function Luna:_confirm(gameName, scriptCount, lastUpdated, description)
    local modal = Instance.new("Frame")
    modal.Size = UDim2.new(1,0,1,0)
    modal.BackgroundTransparency = 1
    modal.Parent = self._frame
    modal.ZIndex = 50

    local overlay = Instance.new("TextButton")
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Theme.Background
    overlay.BackgroundTransparency = 0.35
    overlay.Text = ""
    overlay.BorderSizePixel = 0
    overlay.AutoButtonColor = false
    overlay.ZIndex = 50
    overlay.Parent = modal

    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(0.5,0.5)
    box.Position = UDim2.new(0.5,0,0.5,0)
    box.Size = UDim2.new(0, 320, 0, 150)
    box.BackgroundColor3 = Theme.Header
    box.BorderSizePixel = 0
    box.ZIndex = 51
    box.Parent = modal
    glassify(box)
    makeShadow(box, 18, 0.22)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 110)
    lbl.Position = UDim2.new(0, 10, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Text = tostring(gameName) .. "\n\nScripts available: " .. tostring(scriptCount or 0)
    lbl.TextWrapped = true
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.ZIndex = 51
    lbl.Parent = box

    local lines = {
        tostring(gameName),
        "Scripts available: " .. tostring(scriptCount or 0),
    }

    if type(lastUpdated) == "string" and lastUpdated ~= "" then
        table.insert(lines, "Last updated: " .. lastUpdated)
    end

    if type(description) == "string" and description ~= "" then
        table.insert(lines, "Description:\n" .. description)
    end

    lbl.Text = table.concat(lines, "\n\n")

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 34)
    closeBtn.Position = UDim2.new(0, 10, 1, -44)
    closeBtn.Text = "Close"
    closeBtn.BackgroundColor3 = Theme.Accent
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 51
    closeBtn.Parent = box
    glassify(closeBtn)

    overlay.MouseButton1Click:Connect(function() modal:Destroy() end)
    closeBtn.MouseButton1Click:Connect(function() modal:Destroy() end)

    local baseHeight = 120
    local extraHeight = 0
    if type(description) == "string" and description ~= "" then
        extraHeight = extraHeight + 40
    end
    if type(lastUpdated) == "string" and lastUpdated ~= "" then
        extraHeight = extraHeight + 20
    end

    box.Size = UDim2.new(0, 320, 0, baseHeight)
    tween(box, 0.18, {Size = UDim2.new(0, 320, 0, baseHeight + extraHeight)}):Play()
end

function Luna:AddGame(name, scriptCount, lastUpdated, description)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 36)
    btn.Position = UDim2.new(0, 6, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = Theme.Button
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.BorderSizePixel = 0
    btn.Parent = self._list
    glassify(btn)

    btn.MouseEnter:Connect(function()
        tween(btn, 0.12, {BackgroundColor3 = Theme.Hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.12, {BackgroundColor3 = Theme.Button}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        self:_confirm(name, scriptCount, lastUpdated, description)
    end)

    table.insert(self._games, {
        Name = name,
        Button = btn,
        ScriptCount = scriptCount,
        LastUpdated = lastUpdated,
        Description = description
    })
    self:UpdateLayout()
end

function Luna:UpdateLayout()
    local y = 0
    for _, g in ipairs(self._games) do
        g.Button.Position = UDim2.new(0, 6, 0, y)
        y = y + 40
    end
    self._list.CanvasSize = UDim2.new(0,0,0,y)
end

function Luna:Filter(query)
    query = string.lower(query or "")
    local y = 0
    for _, g in ipairs(self._games) do
        local match = (query == "") or string.find(string.lower(g.Name), query, 1, true)
        g.Button.Visible = match
        if match then
            g.Button.Position = UDim2.new(0, 6, 0, y)
            y = y + 40
        end
    end
    self._list.CanvasSize = UDim2.new(0,0,0,y)
end

return setmetatable({}, Luna)
]===]

local SUPABASE_PROJECT_URL = "https://udnvaneupscmrgwutamv.supabase.co"
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkbnZhbmV1cHNjbXJnd3V0YW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1NjEyMzAsImV4cCI6MjA3MDEzNzIzMH0.7duKofEtgRarIYDAoMfN7OEkOI_zgkG2WzAXZlxl5J0"
local SUPABASE_GAMES_ENDPOINT = "/rest/v1/games"
local SUPABASE_GAMES_QUERY = "?select=name,script_count,description,updated_at,is_active&is_active=eq.true&order=name.asc"

local function log(...)
    if typeof(print) == "function" then
        print("[SupportedGamesScript]", ...)
    end
end

local function formatTimestamp(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end

    local year, month, day, hour, minute, second = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)")
    if not year then
        year, month, day = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)")
        if not year then
            return value
        end
    end

    local months = {
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    }

    local monthIndex = tonumber(month)
    local monthLabel = monthIndex and months[monthIndex] or month
    if hour then
        return ("%s %s %s %s:%s"):format(day, monthLabel, year, hour, minute)
    else
        return ("%s %s %s"):format(day, monthLabel, year)
    end
end

local function getEnv()
    local ok, result = pcall(function()
        return (getgenv and getgenv()) or _G
    end)
    return ok and result or _G
end

local env = getEnv()

if type(env.AurexisSupportedGamesLocalRoot) == "string" and env.AurexisSupportedGamesLocalRoot ~= "" then
    LOCAL_ROOT = env.AurexisSupportedGamesLocalRoot
end

local function readLocal(relativePath)
    if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then
        return nil
    end

    local normalised = (relativePath or ""):gsub("\\", "/")
    local fullPath = LOCAL_ROOT .. "/" .. normalised
    if not isfile(fullPath) then
        return nil
    end

    local ok, contents = pcall(readfile, fullPath)
    if not ok or type(contents) ~= "string" or contents == "" then
        return nil
    end
    return contents
end

local function fetchRemote(url)
    if typeof(game) ~= "Instance" or typeof(game.HttpGet) ~= "function" then
        return nil
    end

    local ok, response = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or type(response) ~= "string" or response == "" then
        return nil
    end
    return response
end

local function getHttpService()
    if typeof(game) ~= "Instance" or typeof(game.GetService) ~= "function" then
        return nil
    end

    local ok, service = pcall(function()
        return game:GetService("HttpService")
    end)

    if not ok or typeof(service) ~= "Instance" then
        return nil
    end

    return service
end

local function buildSupabaseRequest()
    local url = env.AurexisSupabaseProjectUrl or SUPABASE_PROJECT_URL
    local key = env.AurexisSupabaseAnonKey or SUPABASE_ANON_KEY
    local endpoint = env.AurexisSupabaseGamesEndpoint or SUPABASE_GAMES_ENDPOINT
    local query = env.AurexisSupabaseGamesQuery or SUPABASE_GAMES_QUERY

    if type(url) ~= "string" or url == "" then
        log("Missing Supabase project URL")
        return nil
    end

    if type(key) ~= "string" or key == "" then
        log("Missing Supabase anon key")
        return nil
    end

    endpoint = type(endpoint) == "string" and endpoint or SUPABASE_GAMES_ENDPOINT
    query = type(query) == "string" and query or ""

    local trimmedUrl = url:gsub("/+$", "")
    local fullUrl = trimmedUrl .. "/" .. endpoint:gsub("^/+", "")

    if query ~= "" then
        if query:sub(1, 1) ~= "?" then
            fullUrl = fullUrl .. "?" .. query
        else
            fullUrl = fullUrl .. query
        end
    end

    return {
        Url = fullUrl,
        Key = key,
    }
end

local function fetchSupabaseGames()
    local httpService = getHttpService()
    local request = buildSupabaseRequest()

    if not httpService or typeof(httpService.JSONDecode) ~= "function" then
        log("HttpService unavailable or JSONDecode missing")
        return nil, request and request.Url or nil, "HttpService unavailable for JSON decoding"
    end

    if not request then
        log("Supabase request configuration invalid")
        return nil, nil, "Invalid Supabase configuration"
    end

    log("Requesting Supabase games from:", request.Url)

    local headers = {
        apikey = request.Key,
        Authorization = "Bearer " .. request.Key,
        ["Content-Type"] = "application/json",
        Accept = "application/json",
    }

    local requestPayload = {
        Url = request.Url,
        Method = "GET",
        Headers = headers,
    }

    local failureReason

    local function tryHttpService()
        if typeof(httpService.RequestAsync) ~= "function" then
            return nil
        end

        local ok, response = pcall(function()
            return httpService:RequestAsync(requestPayload)
        end)
        log("Trying HttpService.RequestAsync")

        if not ok or type(response) ~= "table" then
            failureReason = failureReason or ("HttpService.RequestAsync failed: " .. tostring(response))
            log("HttpService.RequestAsync call failed:", failureReason)
            return nil
        end

        if response.Success ~= true then
            local code = response.StatusCode or response.Status or "unknown"
            failureReason = ("HttpService.RequestAsync returned HTTP " .. tostring(code))
            log("HttpService.RequestAsync returned non-success:", code)
            return nil
        end

        if type(response.Body) ~= "string" or response.Body == "" then
            failureReason = "HttpService.RequestAsync returned empty body"
            log("HttpService.RequestAsync returned empty body")
            return nil
        end

        log("HttpService.RequestAsync succeeded, body length:", #response.Body)
        return response.Body
    end

    local function coerceRequester(candidate)
        if type(candidate) == "function" then
            return candidate
        end

        if type(candidate) == "table" then
            local inner = candidate.request or candidate.Request or candidate.http_request or candidate.HttpRequest
            if type(inner) == "function" then
                return inner
            end
        end

        return nil
    end

    local function tryExploitRequest()
        local candidates = {}

        local function push(value)
            local fn = coerceRequester(value)
            if fn then
                table.insert(candidates, fn)
            end
        end

        push(env.AurexisSupabaseRequest)
        push(rawget(env, "http_request"))
        push(rawget(env, "request"))
        push(rawget(env, "HttpRequest"))
        push(rawget(env, "PerformHttpRequest"))
        push(rawget(env, "HttpPost"))

        local compoundNames = { "syn", "http", "fluxus", "krnl", "wrm", "oxygen", "Delta" }
        for _, name in ipairs(compoundNames) do
            push(rawget(env, name))
        end

        for index, candidate in ipairs(candidates) do
            log("Trying custom request candidate", index)
            local ok, response = pcall(candidate, {
                Url = requestPayload.Url,
                Method = requestPayload.Method,
                Headers = requestPayload.Headers,
            })

            if ok and type(response) == "table" then
                local success = response.Success
                if success == nil then
                    local status = response.StatusCode or response.Status or response.status
                    if tonumber(status) then
                        success = tonumber(status) >= 200 and tonumber(status) < 300
                    end
                end

                local body = response.Body or response.body or response.Data or response.data

                if success and type(body) == "string" and body ~= "" then
                    log("Custom request candidate", index, "succeeded, body length:", #body)
                    return body
                else
                    failureReason = failureReason or ("Custom request failed: status=" .. tostring(response.StatusCode or response.Status or "unknown"))
                    log("Custom request candidate", index, "failed:", failureReason)
                end
            elseif not ok then
                failureReason = failureReason or ("Custom request errored: " .. tostring(response))
                log("Custom request candidate", index, "errored:", response)
            end
        end

        return nil
    end

    local body = tryHttpService() or tryExploitRequest()
    if not body then
        log("All Supabase request methods failed:", failureReason or "unknown")
        return nil, request.Url, failureReason or "All request methods failed"
    end

    local decodeOk, data = pcall(function()
        return httpService:JSONDecode(body)
    end)

    if not decodeOk or type(data) ~= "table" then
        log("JSON decode failed:", data)
        return nil, request.Url, "JSON decode failed: " .. tostring(data)
    end

    log("Supabase returned", #data, "rows")

    return data, request.Url, nil
end

local function loadModule(label, localPath, remoteUrl)
    local source = readLocal(localPath)
    local origin = source and "local" or nil

    if not source and remoteUrl then
        source = fetchRemote(remoteUrl)
        origin = source and "remote" or origin
    end

    if not source then
        error(("[SupportedGamesScript] Failed to load %s (local path: %s)"):format(label, tostring(localPath)))
    end

    local chunk, compileErr = loadstring(source, "=" .. label)
    if not chunk then
        error(("[SupportedGamesScript] Compilation error in %s: %s"):format(label, tostring(compileErr)))
    end

    local ok, result = pcall(chunk)
    if not ok then
        error(("[SupportedGamesScript] Runtime error in %s: %s"):format(label, tostring(result)))
    end

    return result, origin or "unknown"
end

local function validateLuna(candidate)
    return type(candidate) == "table"
        and type(candidate.Intro) == "function"
        and type(candidate.CreateWindow) == "function"
end

local function loadLunaLibrary()
    if type(env.AurexisLunaSource) == "string" and env.AurexisLunaSource ~= "" then
        local chunk, overrideErr = loadstring(env.AurexisLunaSource, "=AurexisLunaOverride")
        if chunk then
            local ok, overrideModule = pcall(chunk)
            if ok and validateLuna(overrideModule) then
                return overrideModule, "override"
            end
        end
    end

    local ok, module, origin = pcall(loadModule, "LunaLight.lua", "LunaLight.lua", REMOTE_LUNA)
    if ok and validateLuna(module) then
        return module, origin
    end

    local chunk, embedErr = loadstring(EMBEDDED_LUNA_SOURCE, "=EmbeddedLunaLight")
    if not chunk then
        error("[SupportedGamesScript] Failed to prepare embedded Luna library: " .. tostring(embedErr))
    end

    local embedOk, embeddedModule = pcall(chunk)
    if not embedOk then
        error("[SupportedGamesScript] Embedded Luna library runtime error: " .. tostring(embeddedModule))
    end

    if not validateLuna(embeddedModule) then
        error("[SupportedGamesScript] Embedded Luna library missing required methods")
    end

    return embeddedModule, "embedded"
end

local function normaliseGames(rawGames)
    local games = {}
    if type(rawGames) ~= "table" then
        return games
    end

    for index, entry in ipairs(rawGames) do
        if type(entry) == "table" then
            if entry.is_active ~= nil and entry.is_active ~= true then
                -- Explicitly skipped by backend filter.
            else
                local name = entry.Name or entry.name or entry.Title or entry.title or ("Game #" .. index)
                local scriptCount = tonumber(entry.ScriptCount or entry.script_count or entry.scripts or entry.scriptcount) or 0
                local description = entry.Notes or entry.notes or entry.description or entry.Description
                local updatedAt = entry.updated_at or entry.UpdatedAt or entry.updatedAt
                local updatedDisplay = formatTimestamp(updatedAt)
                table.insert(games, {
                    Name = tostring(name),
                    ScriptCount = scriptCount,
                    Notes = description,
                    Description = description,
                    UpdatedAt = updatedAt,
                    UpdatedAtDisplay = updatedDisplay,
                })
            end
        end
    end

    return games
end

local function enhanceWindow(window)
    if type(window) ~= "table" or type(window._confirm) ~= "function" or window.__AurexisEnhanced then
        return
    end

    window.__AurexisEnhanced = true

    local originalConfirm = window._confirm

    window._confirm = function(self, gameName, scriptCount)
        local before = {}
        if typeof(self._frame) == "Instance" then
            for _, child in ipairs(self._frame:GetChildren()) do
                before[child] = true
            end
        end

        local ok, err = pcall(originalConfirm, self, gameName, scriptCount)
        if not ok then
            log("Error in Luna confirm:", err)
            return
        end

        if typeof(self._frame) ~= "Instance" then
            return
        end

        local modal
        for _, child in ipairs(self._frame:GetChildren()) do
            if not before[child] and child:IsA("Frame") then
                modal = child
                break
            end
        end

        if not modal then
            return
        end

        local metadata
        if type(self._games) == "table" then
            for _, record in ipairs(self._games) do
                if type(record) == "table" and record.Name == gameName then
                    metadata = record
                    break
                end
            end
        end

        if not metadata then
            return
        end

        local box
        for _, child in ipairs(modal:GetChildren()) do
            if child:IsA("Frame") then
                box = child
                break
            end
        end

        if not box then
            return
        end

        local label
        for _, child in ipairs(box:GetChildren()) do
            if child:IsA("TextLabel") then
                label = child
                break
            end
        end

        if not label then
            return
        end

        local lines = {
            tostring(metadata.Name or gameName),
            "Scripts available: " .. tostring(metadata.ScriptCount or scriptCount or 0),
        }

        if type(metadata.UpdatedAtDisplay) == "string" and metadata.UpdatedAtDisplay ~= "" then
            table.insert(lines, "Last updated: " .. metadata.UpdatedAtDisplay)
        end

        if type(metadata.Description) == "string" and metadata.Description ~= "" then
            table.insert(lines, "Description:\n" .. metadata.Description)
        end

        label.Text = table.concat(lines, "\n\n")

        local extraHeight = 0
        if type(metadata.Description) == "string" and metadata.Description ~= "" then
            extraHeight = extraHeight + 40
        end
        if type(metadata.UpdatedAtDisplay) == "string" and metadata.UpdatedAtDisplay ~= "" then
            extraHeight = extraHeight + 20
        end

        label.Size = UDim2.new(1, -20, 0, 110 + extraHeight)
        box.Size = UDim2.new(0, 320, 0, 150 + extraHeight)
    end
end

return function()
    local function core()
        local Luna, LunaOrigin = loadLunaLibrary()

        local GamesRaw, SupabaseUrl, SupabaseError = fetchSupabaseGames()
        local GamesOrigin = "supabase"

        if type(GamesRaw) ~= "table" then
            GamesRaw = {}
            GamesOrigin = "supabase:error"
            if typeof(warn) == "function" then
                warn("[SupportedGamesScript] Supabase fetch failed: " .. tostring(SupabaseError or "unknown error"))
            end
            log("Supabase fetch failed, error:", SupabaseError)
        end

        if type(Luna) ~= "table" or type(Luna.Intro) ~= "function" or type(Luna.CreateWindow) ~= "function" then
            error("[SupportedGamesScript] Luna library missing required methods")
        end

        local normaliseOk, gamesOrError = pcall(normaliseGames, GamesRaw)
        if not normaliseOk then
            error("[SupportedGamesScript] Failed to normalise games: " .. tostring(gamesOrError))
        end
        local games = gamesOrError
        if type(games) ~= "table" then
            error("[SupportedGamesScript] Normalised games returned unexpected value: " .. typeof(games))
        end
        local sortOk, sortErr = pcall(function()
            table.sort(games, function(a, b)
                return a.Name:lower() < b.Name:lower()
            end)
        end)
        if not sortOk then
            error("[SupportedGamesScript] Failed to sort games: " .. tostring(sortErr))
        end
        log("Normalised", #games, "games")

        local introText = env.AurexisSupportedGamesIntroText or "Loading Aurexis Supported Games..."
        local introOk, introErr = pcall(function()
            Luna:Intro(introText)
        end)
        if not introOk then
            error("[SupportedGamesScript] Luna intro failed: " .. tostring(introErr))
        end
        log("Intro complete")

        local windowResult
        local windowOk, windowErr = pcall(function()
            windowResult = Luna:CreateWindow({
                Title = env.AurexisSupportedGamesWindowTitle or "Supported Games",
                Subtitle = env.AurexisSupportedGamesWindowSubtitle or "Sorin Loader v1.1",
                Count = #games,
            })
        end)
        if not windowOk then
            error("[SupportedGamesScript] Luna window creation failed: " .. tostring(windowErr))
        end

        local window = windowResult
        if type(window) ~= "table" then
            error("[SupportedGamesScript] Luna window returned unexpected value: " .. typeof(window))
        end
        log("Window created")

        enhanceWindow(window)
        log("Window enhanced")

        for _, entry in ipairs(games) do
            log("Adding game:", entry.Name, entry.ScriptCount or 0)
            local addOk, addErr = pcall(function()
                window:AddGame(entry.Name, entry.ScriptCount or 0)
            end)
            if not addOk then
                error(("[SupportedGamesScript] Failed to add game '%s': %s"):format(entry.Name, tostring(addErr)))
            end

            if type(window._games) == "table" then
                local record = window._games[#window._games]
                if type(record) == "table" then
                    record.ScriptCount = entry.ScriptCount or 0
                    record.UpdatedAtDisplay = entry.UpdatedAtDisplay
                    record.Description = entry.Description
                end
            end
        end
        log("All games added")

        env.AurexisSupportedGamesData = {
            Games = games,
            Sources = {
                Luna = LunaOrigin,
                Games = GamesOrigin,
                SupabaseUrl = SupabaseUrl,
                SupabaseError = SupabaseError,
            },
            LoadedAt = os.time(),
        }

        return {
            Library = Luna,
            Games = games,
            UI = window,
        }
    end

    local ok, result = pcall(core)
    if not ok then
        env.AurexisSupportedGamesLastError = result
        if typeof(warn) == "function" then
            warn("[SupportedGamesScript] Loader failed: " .. tostring(result))
        end
        error(result)
    end

    env.AurexisSupportedGamesLastError = nil
    return result
end
