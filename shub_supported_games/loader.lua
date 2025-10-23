-- Aurexis Supported Games loader (informational only)
-- Shows a list of supported titles without bundling exploit code.

local LOCAL_ROOT = "SupportedGamesScript"

local REMOTE_LUNA = "https://raw.githubusercontent.com/sorinservice/luna-lib-remastered/refs/heads/main/LunaLight.lua"
local REMOTE_GAMES = "https://raw.githubusercontent.com/sorinservice/unlogged-scripts/refs/heads/main/shub_supported_games/games.lua"

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
            local name = entry.Name or entry.Title or ("Game #" .. index)
            local scriptCount = tonumber(entry.ScriptCount) or 0
            table.insert(games, {
                Name = tostring(name),
                ScriptCount = scriptCount,
                Notes = entry.Notes,
            })
        end
    end

    return games
end

local Luna, LunaOrigin = loadModule("LunaLight.lua", "LunaLight.lua", REMOTE_LUNA)
local GamesRaw, GamesOrigin = loadModule("games.lua", "SupportedGames/games.lua", REMOTE_GAMES)

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
    },
    LoadedAt = os.time(),
}

return {
    Library = Luna,
    Games = games,
    UI = window,
}
