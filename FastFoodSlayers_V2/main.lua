-- main.lua

local enemy = require "enemy"
local tank = require "tank" -- Include the tank module
local player = require "player"
local bullet = require "bullet"
local Game = require "States/Game"
local Menu = require "menu"
local anim8 = require "anim8"

local enemies = {}
local tanks = {}     -- New table to store tank instances
local numEnemies = 3 -- Initial number of enemies
local numTanks = 2   -- Initial number of tanks
local initialEnemyCount = numEnemies
local currentEnemyCount = initialEnemyCount
local enemySpeedIncrease = 50
local enemyHpIncrease = 1
local enemyCountIncrease = 2
local needToResetGame = false
local allEnemiesDead = false
local game
local clickSound
local hoverSound
local explosionSound
local hitHurtSound
local restartButton = Menu.newRestartButton()
local mainMenuButton = Menu.newMainMenuButton()
local nextLevelButton = Menu.newNextLevelButton()
local resumeButton = Menu.newPauseButton()

function love.load()
    background = love.graphics.newImage("sprites/backgroundImage.png")
    love.window.setTitle("Shooter Game")
    love.window.setMode(1920, 1080)
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)

    local screenWidth, screenHeight = love.graphics.getDimensions()

    -- Centered button positions
    restartButton.x = (screenWidth - restartButton.width) / 2
    restartButton.y = (screenHeight - restartButton.height) / 2

    mainMenuButton.x = (screenWidth - mainMenuButton.width) / 2
    mainMenuButton.y = restartButton.y + restartButton.height + 20 -- Adjust the vertical spacing

    nextLevelButton.x = (screenWidth - nextLevelButton.width) / 2
    nextLevelButton.y = mainMenuButton.y + mainMenuButton.height + 20 -- Adjust the vertical spacing

    resumeButton.x = (screenWidth - resumeButton.width) / 2
    resumeButton.y = (screenHeight - resumeButton.height) / 2

    game = Game.new()

    clickSound = love.audio.newSource("Sounds/click.wav", "static")
    hoverSound = love.audio.newSource("Sounds/hover.wav", "static")
    explosionSound = love.audio.newSource("Sounds/explosion.wav", "static")
    hitHurtSound = love.audio.newSource("Sounds/hitHurt.wav", "static")

    clickSound:setVolume(1.5)
    hoverSound:setVolume(1.5)
    explosionSound:setVolume(1.5)
    hitHurtSound:setVolume(1.5)

    -- Spawn both normal enemies and tanks
    numEnemies = initialEnemyCount
    for i = 1, numEnemies do
        local randomX = love.math.random(0, 1920)
        local randomY = love.math.random(0, 700)

        local newEnemy = enemy.newEnemy(randomX, randomY, 50)
        table.insert(enemies, newEnemy)
    end

    numTanks = 2

    for i = 1, numTanks do
        local randomX = love.math.random(0, 1920)
        local randomY = love.math.random(0, 700)

        local newTank = enemy.newEnemy(randomX, randomY, 80) -- Assuming 80 is the size for tanks
        newTank.isTank = true                                -- Set a flag to identify tanks
        table.insert(enemies, newTank)
    end

    player.load()
    bullet.load()
end

function love.update(dt)
    if game.state.running then
        player.update(dt)

        allEnemiesDead = true
        for i = #enemies, 1, -1 do
            local e = enemies[i]
            enemy.update(e, dt, enemies)
            if e.isDead then
                table.remove(enemies, i)
                explosionSound:play()
            else
                allEnemiesDead = false
            end
        end

        bullet.update(dt, player, enemies)

        if allEnemiesDead and not needToResetGame then
            game:changeGameState("victoryMenu")
            needToResetGame = true
        elseif player.hp <= 0 and not needToResetGame then
            game:changeGameState("menu")
            needToResetGame = true
            explosionSound:play()
        end
    elseif game.state.menu then
        if love.mouse.getX() >= restartButton.x and love.mouse.getX() <= restartButton.x + restartButton.width and
            love.mouse.getY() >= restartButton.y and love.mouse.getY() <= restartButton.y + restartButton.height then
            if not restartButton.isHovered then
                hoverSound:play()
            end
            restartButton.isHovered = true
            if love.mouse.isDown(1) then
                clickSound:play()
                resetGame()
                game:changeGameState("running")
            end
        else
            restartButton.isHovered = false
        end

        if love.mouse.getX() >= mainMenuButton.x and love.mouse.getX() <= mainMenuButton.x + mainMenuButton.width and
            love.mouse.getY() >= mainMenuButton.y and love.mouse.getY() <= mainMenuButton.y + mainMenuButton.height then
            if not mainMenuButton.isHovered then
                hoverSound:play()
            end
            mainMenuButton.isHovered = true
            if love.mouse.isDown(1) then
                clickSound:play()
                love.event.quit()
            end
        else
            mainMenuButton.isHovered = false
        end

        Menu.updateButtonColor(restartButton)
        Menu.updateButtonColor(mainMenuButton)
    elseif game.state.victoryMenu then
        if love.mouse.getX() >= nextLevelButton.x and love.mouse.getX() <= nextLevelButton.x + nextLevelButton.width and
            love.mouse.getY() >= nextLevelButton.y and love.mouse.getY() <= nextLevelButton.y + nextLevelButton.height then
            if not nextLevelButton.isHovered then
                hoverSound:play()
            end
            nextLevelButton.isHovered = true
            if love.mouse.isDown(1) then
                clickSound:play()
                nextLevel()
                game:changeGameState("running")
            end
        else
            nextLevelButton.isHovered = false
        end

        if love.mouse.getX() >= restartButton.x and love.mouse.getX() <= restartButton.x + restartButton.width and
            love.mouse.getY() >= restartButton.y and love.mouse.getY() <= restartButton.y + restartButton.height then
            if not restartButton.isHovered then
                hoverSound:play()
            end
            restartButton.isHovered = true
            if love.mouse.isDown(1) then
                clickSound:play()
                resetGame()
                game:changeGameState("running")
            end
        else
            restartButton.isHovered = false
        end

        if love.mouse.getX() >= mainMenuButton.x and love.mouse.getX() <= mainMenuButton.x + mainMenuButton.width and
            love.mouse.getY() >= mainMenuButton.y and love.mouse.getY() <= mainMenuButton.y + mainMenuButton.height then
            if not mainMenuButton.isHovered then
                hoverSound:play()
            end
            mainMenuButton.isHovered = true
            if love.mouse.isDown(1) then
                clickSound:play()
                love.event.quit()
            end
        else
            mainMenuButton.isHovered = false
        end

        Menu.updateButtonColor(nextLevelButton)
        Menu.updateButtonColor(restartButton)
        Menu.updateButtonColor(mainMenuButton)
    elseif game.state.pauseMenu then
        if love.mouse.getX() >= resumeButton.x and love.mouse.getX() <= resumeButton.x + resumeButton.width and
            love.mouse.getY() >= resumeButton.y and love.mouse.getY() <= resumeButton.y + resumeButton.height then
            if not resumeButton.isHovered then
                hoverSound:play()
            end
            resumeButton.isHovered = true
            if love.mouse.isDown(1) then
                clickSound:play()
                game:changeGameState("running")
            end
        else
            resumeButton.isHovered = false
        end

        if love.mouse.getX() >= mainMenuButton.x and love.mouse.getX() <= mainMenuButton.x + mainMenuButton.width and
            love.mouse.getY() >= mainMenuButton.y and love.mouse.getY() <= mainMenuButton.y + mainMenuButton.height then
            if not mainMenuButton.isHovered then
                hoverSound:play()
            end
            mainMenuButton.isHovered = true
            if love.mouse.isDown(1) then
                clickSound:play()
                resetGame()
                game:changeGameState("menu")
            end
        else
            mainMenuButton.isHovered = false
        end

        Menu.updateButtonColor(resumeButton)
        Menu.updateButtonColor(mainMenuButton)
    elseif game.state.pauseMenu then
        if love.mouse.getX() >= resumeButton.x and love.mouse.getX() <= resumeButton.x + resumeButton.width and
            love.mouse.getY() >= resumeButton.y and love.mouse.getY() <= resumeButton.y + resumeButton.height then
            if not resumeButton.isHovered then
                hoverSound:play()
            end
            resumeButton.isHovered = true
            if love.mouse.isDown(1) then
                clickSound:play()
                game:changeGameState("running")
            end
        else
            resumeButton.isHovered = false
        end

        if love.mouse.getX() >= mainMenuButton.x and love.mouse.getX() <= mainMenuButton.x + mainMenuButton.width and
            love.mouse.getY() >= mainMenuButton.y and love.mouse.getY() <= mainMenuButton.y + mainMenuButton.height then
            if not mainMenuButton.isHovered then
                hoverSound:play()
            end
            mainMenuButton.isHovered = true
            if love.mouse.isDown(1) then
                clickSound:play()
                resetGame()
                game:changeGameState("menu")
            end
        else
            mainMenuButton.isHovered = false
        end

        Menu.updateButtonColor(resumeButton)
        Menu.updateButtonColor(mainMenuButton)
    end
end

function love.draw()
    love.graphics.draw(background, 0, 0, 0, love.graphics.getWidth() / background:getWidth(),
        love.graphics.getHeight() / background:getHeight())


    if game.state.running then
        player.draw()

        for _, e in ipairs(enemies) do
            enemy.draw(e)
        end

        for _, t in ipairs(tanks) do
            tank.draw(t)
        end

        bullet.draw()
    elseif game.state.menu then
        love.graphics.setColor(restartButton.currentColor)
        love.graphics.rectangle("fill", restartButton.x, restartButton.y, restartButton.width, restartButton.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(restartButton.label, restartButton.x + 10, restartButton.y + 10)

        love.graphics.setColor(mainMenuButton.currentColor)
        love.graphics.rectangle("fill", mainMenuButton.x, mainMenuButton.y, mainMenuButton.width,
            mainMenuButton.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(mainMenuButton.label, mainMenuButton.x + 10, mainMenuButton.y + 10)
    elseif game.state.victoryMenu then
        -- Draw "Next Level" button first
        love.graphics.setColor(nextLevelButton.currentColor)
        love.graphics.rectangle("fill", nextLevelButton.x, nextLevelButton.y, nextLevelButton.width,
            nextLevelButton.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(nextLevelButton.label, nextLevelButton.x + 15, nextLevelButton.y + 15)

        -- Draw "Restart" button second
        love.graphics.setColor(restartButton.currentColor)
        love.graphics.rectangle("fill", restartButton.x, restartButton.y, restartButton.width, restartButton.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(restartButton.label, restartButton.x + 15, restartButton.y + 15)

        -- Draw "Main Menu" button third
        love.graphics.setColor(mainMenuButton.currentColor)
        love.graphics.rectangle("fill", mainMenuButton.x, mainMenuButton.y, mainMenuButton.width, mainMenuButton.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(mainMenuButton.label, mainMenuButton.x + 15, mainMenuButton.y + 15)
    elseif game.state.gameOver then
        for _, button in ipairs(gameOverButtons) do
            GameOverMenu.updateButtonColor(button)
        end
    elseif game.state.pauseMenu then
        -- Draw buttons for the pauseMenu state
        love.graphics.setColor(resumeButton.currentColor)
        love.graphics.rectangle("fill", resumeButton.x, resumeButton.y, resumeButton.width, resumeButton.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(resumeButton.label, resumeButton.x + 10, resumeButton.y + 10)

        love.graphics.setColor(mainMenuButton.currentColor)
        love.graphics.rectangle("fill", mainMenuButton.x, mainMenuButton.y, mainMenuButton.width,
            mainMenuButton.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(mainMenuButton.label, mainMenuButton.x + 10, mainMenuButton.y + 10)
    end
end

function love.keypressed(key)
    if key == "escape" and game.state.running then
        game:changeGameState("pauseMenu")
    end
end

-- Modify the resetGame function
function resetGame()
    for i = #enemies, 1, -1 do
        table.remove(enemies, i)
    end

    -- Reinitialize both normal enemies and tanks
    numEnemies = initialEnemyCount
    for i = 1, numEnemies do
        local randomX = love.math.random(0, 1920)
        local randomY = love.math.random(0, 700)

        local newEnemy = enemy.newEnemy(randomX, randomY, 50)
        table.insert(enemies, newEnemy)
    end

    numTanks = numTanks
    for i = 1, numTanks do
        local randomX = love.math.random(0, 1920)
        local randomY = love.math.random(0, 700)

        local newTank = enemy.newEnemy(randomX, randomY, 80)
        newTank.isTank = true
        newTank.hp = (game.level == 1) and 3 or 5 -- Set tank's HP based on the level
        table.insert(enemies, newTank)
    end

    bullet.load()

    allEnemiesDead = false
    needToResetGame = false
    player.hp = 3
end

function nextLevel()
    numEnemies = numEnemies + enemyCountIncrease
    enemySpeedIncrease = enemySpeedIncrease + 50
    enemyHpIncrease = enemyHpIncrease + 1

    -- Increase the number of tanks by one
    numTanks = numTanks + 1

    for i = 1, numEnemies do
        local randomX = love.math.random(0, 1920)
        local randomY = love.math.random(0, 700)

        local newEnemy = enemy.newEnemy(randomX, randomY, 50 + (enemyHpIncrease * 1))
        newEnemy.speed = newEnemy.speed + enemySpeedIncrease
        table.insert(enemies, newEnemy)
    end

    for i = 1, numTanks do
        local randomX = love.math.random(0, 1920)
        local randomY = love.math.random(0, 700)

        local newTank = enemy.newEnemy(randomX, randomY, 80)
        newTank.isTank = true
        newTank.hp = 5 -- Set tank's HP to 5
        table.insert(enemies, newTank)
    end

    player.hp = 3
    bullet.load()

    allEnemiesDead = false
    needToResetGame = false
end
