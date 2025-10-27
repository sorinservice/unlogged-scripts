-- Aurexis Supported Games loader (informational only)
-- Shows a list of supported titles without bundling exploit code.

local LOCAL_ROOT = "Supported Games Script"

local REMOTE_LUNA = "https://raw.githubusercontent.com/sorinservice/luna-lib-remastered/refs/heads/main/LunaLight.lua"

local SUPABASE_PROJECT_URL = "https://udnvaneupscmrgwutamv.supabase.co"
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkbnZhbmV1cHNjbXJnd3V0YW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1NjEyMzAsImV4cCI6MjA3MDEzNzIzMH0.7duKofEtgRarIYDAoMfN7OEkOI_zgkG2WzAXZlxl5J0"
local SUPABASE_GAMES_ENDPOINT = "/rest/v1/games"
local SUPABASE_GAMES_QUERY = "?select=name,script_count,description,thumbnail_url,updated_at,is_active&is_active=eq.true&order=name.asc"

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
                local thumbnail = entry.thumbnail or entry.Thumbnail or entry.thumbnail_url or entry.thumbnailUrl or entry.thumbnailURL
                local updatedAt = entry.updated_at or entry.UpdatedAt or entry.updatedAt
                local updatedDisplay = formatTimestamp(updatedAt)
                table.insert(games, {
                    Name = tostring(name),
                    ScriptCount = scriptCount,
                    Notes = description,
                    Description = description,
                    UpdatedAt = updatedAt,
                    UpdatedAtDisplay = updatedDisplay,
                    Thumbnail = thumbnail,
                })
            end
        end
    end

    return games
end

return function()
    local Luna, LunaOrigin = loadModule("LunaLight.lua", "LunaLight.lua", REMOTE_LUNA)

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

    local games = normaliseGames(GamesRaw)
    table.sort(games, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)

    local introText = env.AurexisSupportedGamesIntroText or "Loading Aurexis Supported Games..."
    Luna:Intro(introText)

    local window = Luna:CreateWindow({
        Title = env.AurexisSupportedGamesWindowTitle or "Supported Games",
        Subtitle = env.AurexisSupportedGamesWindowSubtitle or "Sorin Loader v1.1",
        Count = #games,
    })

    for _, entry in ipairs(games) do
        window:AddGame(entry.Name, entry.ScriptCount or 0, entry.UpdatedAtDisplay, entry.Description)
    end

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
