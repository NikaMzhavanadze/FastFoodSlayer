-- player.lua

local bullet = require("bullet")
local anim8 = require("anim8")

local playerImage = love.graphics.newImage("sprites/player.png")
local playerGrid = anim8.newGrid(59, 80, playerImage:getWidth(), playerImage:getHeight())
local animations = {
    moving = anim8.newAnimation(playerGrid('1-4', 1), 0.2), -- 4 frames for moving animation
    idle = anim8.newAnimation(playerGrid('2-2', 1), 0.5)    -- 4 frames for moving animation
}

local player = {
    x = 960,
    y = 1080 - 50,
    width = 50,                                                   -- Updated width
    height = 50,                                                  -- Updated height
    hitbox = { x = 960, y = 1080 - 50, width = 24, height = 32 }, -- Updated hitbox
    speed = 400,
    hp = 3,
    maxHp = 3,
    cooldown = 0,
    currentAnimation = animations.moving,
    broccoliCount = 3,
}

local playerShootSound

function player.load()
    playerShootSound = love.audio.newSource("Sounds/laserShoot.wav", "static")
    broccoliWidth, broccoliHeight = 100, 100                       -- Set the desired width and height for broccoli
    broccoliSpacing = 30        
end

function player.update(dt)
    local isMoving = false -- Flag to check if the player is moving

    -- Check movement keys
    if love.keyboard.isDown("w") and player.y > 730 then
        player.y = player.y - player.speed * dt
        isMoving = true
    end
    if love.keyboard.isDown("s") and player.y < 1025 then
        player.y = player.y + player.speed * dt
        isMoving = true
    end
    if love.keyboard.isDown("a") and player.x > 0 then
        player.x = player.x - player.speed * dt
        isMoving = true
    end
    if love.keyboard.isDown("d") and player.x < 1868 then
        player.x = player.x + player.speed * dt
        isMoving = true
    end

    -- Set the current animation based on player movement
    if isMoving then
        player.currentAnimation = animations.moving
    else
        player.currentAnimation = animations.idle
    end

    player.cooldown = player.cooldown - dt
    if love.keyboard.isDown("space") and player.cooldown <= 0 then
        bullet.shoot('player', 'up', player.x + player.width / 2, player.y - player.height)
        player.cooldown = 0.5
        playerShootSound:play()
    end

    player.currentAnimation:update(dt)

    player.hitbox.x = player.x
    player.hitbox.y = player.y

    -- player.currentAnimation:update(dt)
    bullet.update(dt, player, enemies)
end

function player.draw()
    -- Draw player
    player.currentAnimation:draw(playerImage, player.x, player.y, 0, 1, 1) -- Scale up the player by a factor of 4

    -- Draw health bar
    local healthBarWidth = 50
    local healthBarHeight = 10
    local healthBarX = player.x + (player.width - healthBarWidth) / 2
    local healthBarY = player.y - healthBarHeight - 5

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", healthBarX, healthBarY, healthBarWidth * (player.hp / player.maxHp), healthBarHeight)
    love.graphics.setColor(1, 1, 1)
end

return player
