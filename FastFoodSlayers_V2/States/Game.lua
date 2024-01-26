-- Game.lua

local Game = {}

function Game.new()
    local self = {
        state = {
            menu = false,
            paused = false,
            running = true,
            deathMenu = false,
            ended = false,
            victoryMenu = false,  -- New state for victory menu
            pauseMenu = false  -- New state for pause menu
        }
    }
    setmetatable(self, { __index = Game })
    return self
end

function Game:changeGameState(state)
    self.state.menu = state == "menu"
    self.state.deathMenu = state == "deathMenu"
    self.state.paused = state == "paused"
    self.state.running = state == "running"
    self.state.ended = state == "ended"
    self.state.victoryMenu = state == "victoryMenu"  -- Set state for victory menu
    self.state.pauseMenu = state == "pauseMenu"  -- Set state for pause menu
end

return Game
