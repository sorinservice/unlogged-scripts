-- loader.lua
-- Main entry point for Sorin Loader

-- load library
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/sorinservice/luna-lib-remastered/refs/heads/main/LunaLight.lua"))()

-- load games
local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/sorinservice/unlogged-scripts/refs/heads/main/games.lua"))()

-- intro
Luna:Intro("Loading Sorin Loader...")

-- create window
local ui = Luna:CreateWindow({
    Title = "Supported Games",
    Subtitle = "Sorin Loader v1.0",
    Count = #Games
})

-- add games
for _, g in ipairs(Games) do
    ui:AddGame(g.Name, g.PlaceId)
end
