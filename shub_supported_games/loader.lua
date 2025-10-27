-- Aurexis Supported Games loader (informational only)
-- Shows a list of supported titles without bundling exploit code.

local LOCAL_ROOT = "Supported Games Script"

local REMOTE_LUNA = "https://raw.githubusercontent.com/sorinservice/luna-lib-remastered/refs/heads/main/LunaLight.lua"
local REMOTE_GAMES = "https://raw.githubusercontent.com/sorinservice/unlogged-scripts/refs/heads/main/shub_supported_games/games.lua"

local SUPABASE_PROJECT_URL = "https://udnvaneupscmrgwutamv.supabase.co"
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkbnZhbmV1cHNjbXJnd3V0YW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1NjEyMzAsImV4cCI6MjA3MDEzNzIzMH0.7duKofEtgRarIYDAoMfN7OEkOI_zgkG2WzAXZlxl5J0"
local SUPABASE_GAMES_ENDPOINT = "/rest/v1/games"
local SUPABASE_GAMES_QUERY = "?select=name,script_count,notes,is_active&is_active=eq.true&order=name.asc"

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
        return nil
    end

    if type(key) ~= "string" or key == "" then
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

    if not httpService or typeof(httpService.RequestAsync) ~= "function" or typeof(httpService.JSONDecode) ~= "function" then
        return nil, request and request.Url or nil
    end

    if not request then
        return nil, nil
    end

    local ok, response = pcall(function()
        return httpService:RequestAsync({
            Url = request.Url,
            Method = "GET",
            Headers = {
                apikey = request.Key,
                Authorization = "Bearer " .. request.Key,
            },
        })
    end)

    if not ok or type(response) ~= "table" or response.Success ~= true or type(response.Body) ~= "string" then
        return nil, request.Url
    end

    local decodeOk, data = pcall(function()
        return httpService:JSONDecode(response.Body)
    end)

    if not decodeOk or type(data) ~= "table" then
        return nil, request.Url
    end

    return data, request.Url
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
                table.insert(games, {
                    Name = tostring(name),
                    ScriptCount = scriptCount,
                    Notes = entry.Notes or entry.notes or entry.description,
                })
            end
        end
    end

    return games
end

return function()
    local Luna, LunaOrigin = loadModule("LunaLight.lua", "LunaLight.lua", REMOTE_LUNA)

    local GamesRaw, GamesOrigin
    local SupabaseUrl

    local SupabaseRaw, SupabaseSource = fetchSupabaseGames()
    if type(SupabaseRaw) == "table" and #SupabaseRaw > 0 then
        GamesRaw = SupabaseRaw
        GamesOrigin = "supabase"
        SupabaseUrl = SupabaseSource
    else
        GamesRaw, GamesOrigin = loadModule("games.lua", "SupportedGames/games.lua", REMOTE_GAMES)
        SupabaseUrl = SupabaseSource
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
        window:AddGame(entry.Name, entry.ScriptCount or 0)
    end

    env.AurexisSupportedGamesData = {
        Games = games,
        Sources = {
            Luna = LunaOrigin,
            Games = GamesOrigin,
            SupabaseUrl = SupabaseUrl,
        },
        LoadedAt = os.time(),
    }

    return {
        Library = Luna,
        Games = games,
        UI = window,
    }
end
