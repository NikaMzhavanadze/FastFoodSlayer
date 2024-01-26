local bullet = require("bullet")
local anim8 = require("anim8")


local tank = {
    width = 80,                                         -- Change the size of the tank
    height = 80,                                        -- Change the size of the tank
    hitbox = { x = 0, y = 0, width = 80, height = 80 }, -- Adjust hitbox size
    speed = 50,
    hp = 5,
    maxHp = 5,
    cooldown = 0,
    isDead = false,
    deathCooldown = 1,
    moving = false,
    targetX = 0,
    targetY = 0,
}

function tank.newTank(x, y)
    local newTank = {
        x = x,
        y = y,
        width = tank.width,
        height = tank.height,
        hitbox = { x = x, y = y, width = tank.width, height = tank.height },
        speed = tank.speed,
        hp = tank.hp,
        maxHp = tank.maxHp,
        cooldown = 0,
        isDead = false,
        deathCooldown = tank.deathCooldown,
        moving = false,
        targetX = 0,
        targetY = 0,
    }
    return newTank
end

function tank.load(t)
    t.x = love.math.random(0, 1920 - t.width)
    t.y = love.math.random(400, 730 - t.height)
    setRandomPosition(t)
end

-- Override the update function to add tank-specific behavior
function tank.update(t, dt, otherEnemies)
    if t.hp <= 0 then
        t.isDead = true
        t.deathCooldown = t.deathCooldown - dt
        if t.deathCooldown <= 0 then
            respawnTank(t, otherEnemies)
        end
        return
    end

    t.cooldown = t.cooldown - dt
    if t.cooldown <= 0 then
        bullet.shoot('down', t.x + t.width / 2, t.y + t.height) -- Shoot from the center bottom
        t.cooldown = love.math.random(1, 3)
    end

    if t.moving then
        moveTank(t, dt)
        t.currentAnimation:update(dt)
    else
        t.moveCooldown = t.moveCooldown or t.moveDuration
        t.moveCooldown = t.moveCooldown - dt
        if t.moveCooldown <= 0 then
            setRandomPosition(t)
        end
    end


    -- Check for collision with other enemies
    for _, otherEnemy in ipairs(otherEnemies) do
        if otherEnemy ~= t and checkCollision(t, otherEnemy) then
            setRandomPosition(t)
            break
        end
    end

    bullet.update(dt, player, t)
end

-- Override the draw function to add tank-specific drawing
function tank.draw(t)
    if not t.isDead then
        if t.moving then
            t.currentAnimation:draw(tankImage, t.x, t.y)
        else
            t.currentAnimation:gotoFrame(1)
            t.currentAnimation:draw(tankImage, t.x, t.y)
        end


    end
end

function moveTank(t, dt)
    local dx = t.targetX - t.x
    local dy = t.targetY - t.y
    local distance = math.sqrt(dx ^ 2 + dy ^ 2)

    if distance > 1 then
        local moveAmount = t.speed * dt
        local angle = math.atan2(dy, dx)
        t.x = t.x + moveAmount * math.cos(angle)
        t.y = t.y + moveAmount * math.sin(angle)
        updateHitbox(t) -- Update hitbox along with position
    else
        t.x = t.targetX
        t.y = t.targetY
        t.moving = false
        t.moveCooldown = t.moveDuration
        updateHitbox(t) -- Update hitbox for the final position
    end
end

-- Set a new random position for the tank to move towards
function setRandomPosition(t)
    t.targetX = love.math.random(0, 1920 - t.width)
    t.targetY = love.math.random(400, 730 - t.height)
    t.moving = true
end

return tank
