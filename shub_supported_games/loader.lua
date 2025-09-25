-- /unlogged-scripts/shub_supported_games/loader.lua
-- Main entry point for Sorin Loader

-- load library
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/sorinservice/luna-lib-remastered/refs/heads/main/LunaLight.lua"))()

-- load games (moved path)
local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/sorinservice/unlogged-scripts/refs/heads/main/shub_supported_games/games.lua"))()

-- intro
Luna:Intro("Loading Sorin Supported Games...")

-- create window
local ui = Luna:CreateWindow({
    Title = "Supported Games",
    Subtitle = "Sorin Loader v1.1",
    Count = #Games
})

-- optional: sort games alphabetically
table.sort(Games, function(a, b) return a.Name:lower() < b.Name:lower() end)

-- add games (pass ScriptCount instead of PlaceId)
for _, g in ipairs(Games) do
    ui:AddGame(g.Name, g.ScriptCount or 0)
end
