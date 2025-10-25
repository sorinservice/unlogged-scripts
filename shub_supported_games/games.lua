--unlogged-scripts/shub_supported_games/games.lua
local games = {
    {Name = "3008 [2.73]", ScriptCount = 2},
    {Name = "Emergency Hamburg", ScriptCount = 3},
    {Name = "99 Nights in the Forest", ScriptCount = 2},
    {Name = "RealisticCarDriving", ScriptCount = 1},
    {Name = "Break your Bones", ScriptCount = 1},
    {Name = "Steal a Brainrot", ScriptCount = 3},
}



for _, game in ipairs(games) do
    local scriptCount = tonumber(game.ScriptCount)
    if not scriptCount then
        scriptCount = 0
    end
    game.ScriptCount = scriptCount
end

return games

