-- enemy.lua

local bullet = require("bullet")
local anim8 = require("anim8")
local enemyImage = love.graphics.newImage("sprites/burger-Sheet.png")
local grid = anim8.newGrid(62, 74, enemyImage:getWidth(), enemyImage:getHeight())
local animations = {
    idle = anim8.newAnimation(grid('1-1', 1), 0.8),    -- 4 frames for moving
    moving = anim8.newAnimation(grid('1-4', 1), 0.8),    -- 4 frames for moving
    shooting = anim8.newAnimation(grid('1-3', 2), 0.1), -- 3 frames for shooting
    damaged = anim8.newAnimation(grid('1-1', 3), 0.1), -- 1 frame for getting damaged
    dying = anim8.newAnimation(grid('1-4', 4), 0.1),     -- 4 frames for dying
    
}

local enemy = {
    width = 50,
    height = 50,
    hitbox = { x = 0, y = 0, width = 50, height = 50 },
    speed = 100,
    hp = 3,
    maxHp = 3,
    cooldown = 0,
    moveCooldown = 0,
    moveDuration = 1,
    moveSpeed = 200,
    maxY = 730,
    isDead = false,
    deathCooldown = 1,
    currentAnimation = animations.moving,
}

function enemy.newEnemy(x, y, size)
    local newEnemy = {
        x = x,
        y = y,
        width = size,
        height = size,
        hitbox = { x = x, y = y, width = size, height = size },
        speed = 100,
        hp = 3,
        maxHp = 3,
        cooldown = 0,
        moveCooldown = 0,
        moveDuration = 1,
        moveSpeed = 200,
        maxY = 730,
        isDead = false,
        deathCooldown = 1,
        currentAnimation = animations.moving,
    }
    return newEnemy
end

function enemy.load(e)
    e.x = love.math.random(0, 1920 - e.width)
    e.y = love.math.random(400, 730 - e.height)
    setRandomPosition(e)
end

function setRandomPosition(e)
    e.targetX = love.math.random(0, 1920 - e.width)
    e.targetY = love.math.random(400, 730 - e.height)
    e.moving = true
end

function enemy.update(e, dt, otherEnemies)
    if e.hp <= 0 then
        e.isDead = true
        e.deathCooldown = e.deathCooldown - dt
        if e.deathCooldown <= 0 then
            respawnEnemy(e, otherEnemies)
        end
        return
    end

    e.cooldown = e.cooldown - dt
    if e.cooldown <= 0 then
        bullet.shoot('enemy', 'down', e.x + e.width / 2, e.y + e.height)
        e.cooldown = love.math.random(1, 3)
    end

    if e.moving then
        local dx = e.targetX - e.x
        local dy = e.targetY - e.y
        distance = math.sqrt(dx ^ 2 + dy ^ 2)

        if distance > 1 then
            local moveAmount = 200 * dt
            local angle = math.atan2(dy, dx)
            e.x = e.x + moveAmount * math.cos(angle)
            e.y = e.y + moveAmount * math.sin(angle)
            updateHitbox(e)
            e.currentAnimation = animations.moving  -- Switch to "moving" animation when moving
        else
            e.x = e.targetX
            e.y = e.targetY
            e.moving = false
            e.moveCooldown = e.moveDuration
            updateHitbox(e)
            e.currentAnimation = animations.idle  -- Switch to "idle" animation when not moving
        end
    else
        e.moveCooldown = e.moveCooldown - dt
        e.currentAnimation = animations.idle  -- Switch to "idle" animation when not moving

        if e.moveCooldown <= 0 then
            setRandomPosition(e)
        end
    end

    for _, otherEnemy in ipairs(otherEnemies) do
        if otherEnemy ~= e and checkCollision(e, otherEnemy) then
            setRandomPosition(e)
            break
        end
    end

    e.currentAnimation:update(0.001)  -- Update the animation

    bullet.update(dt, player, e)
end

function respawnEnemy(e, otherEnemies)
    -- Reset damaged cooldown when respawning
    e.damagedCooldown = 0
    e.isDead = false
    e.deathCooldown = 1
    repeat
        e.x = love.math.random(0, 1920 - e.width)
        e.y = love.math.random(400, 730 - e.height)
    until not checkCollisionWithOtherEnemies(e, otherEnemies)
    setRandomPosition(e)
end

function checkCollisionWithOtherEnemies(e, otherEnemies)
    for _, otherEnemy in ipairs(otherEnemies) do
        if otherEnemy ~= e and checkCollision(e.hitbox, otherEnemy.hitbox) then
            return true
        end
    end
    return false
end

function updateHitbox(e)
    e.hitbox.x = e.x
    e.hitbox.y = e.y
end

function enemy.draw(e)
    if not e.isDead then
        e.currentAnimation:update(love.timer.getDelta())

        if e.moving then
            -- If moving, draw the animated sprite
            animations.moving:draw(enemyImage, e.x, e.y)
        else
            -- If not moving, check if moveCooldown is zero to play the first frame
            if e.moveCooldown <= 0 then
                animations.moving:gotoFrame(1)
            end
            -- Draw the current frame of the animation
            animations.moving:draw(enemyImage, e.x, e.y)
        end
    end
end

return enemy
