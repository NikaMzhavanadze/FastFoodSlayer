-- bullet.lua

local bulletImages = {
    player = love.graphics.newImage("sprites/player_bullet.png"),
    enemy = love.graphics.newImage("sprites/enemy_bullet.png"),
}

local bullet = {
    speed = 300,
    bulletWidth = 40,  -- Adjust the width of the bullets
    bulletHeight = 40, -- Adjust the height of the bullets
    bullets = {},
}

local hitSound

function bullet.load()
    hitSound = love.audio.newSource("Sounds/hitHurt.wav", "static")
    shootSound = love.audio.newSource("Sounds/laserShoot.wav", "static")
end

function bullet.update(dt, player, enemy)
    for i = #bullet.bullets, 1, -1 do
        local b = bullet.bullets[i]

        if b.direction == 'up' then
            b.y = b.y - bullet.speed * dt
        elseif b.direction == 'down' then
            b.y = b.y + bullet.speed * dt
        end

        -- Check for collisions with player
        if player and player.hp and checkCollision(b, player) then
            table.remove(bullet.bullets, i)
            player.hp = player.hp - 1
            hitSound:play()
        end

        -- Check for collisions with enemy
        if enemy and enemy.hp and checkCollision(b, enemy) then
            table.remove(bullet.bullets, i)
            enemy.hp = enemy.hp - 1
            hitSound:play()
        end

        -- Remove bullets that go off-screen
        if b.y > 1080 or b.y < 0 then
            table.remove(bullet.bullets, i)
        end
    end
end

function bullet.draw()
    love.graphics.setColor(1, 1, 1)
    for _, b in ipairs(bullet.bullets) do
        -- Draw bullets with adjusted width and height
        love.graphics.draw(bulletImages[b.type], b.x, b.y, 0, bullet.bulletWidth / bulletImages[b.type]:getWidth(), bullet.bulletHeight / bulletImages[b.type]:getHeight())
    end
    love.graphics.setColor(1, 1, 1)
end

function bullet.shoot(type, direction, x, y)
    local bulletWidth = bullet.bulletWidth
    local bulletHeight = bullet.bulletHeight

    -- Adjust the x position to center the bullet
    local bulletX = x - bulletWidth / 2

    table.insert(bullet.bullets, { x = bulletX, y = y, direction = direction, type = type })
    shootSound:play()
end
-- Function to check for collision between two rectangles
function checkCollision(a, b)
    return a.x < b.hitbox.x + b.hitbox.width and
        a.x + bullet.bulletWidth > b.hitbox.x and
        a.y < b.hitbox.y + b.hitbox.height and
        a.y + bullet.bulletHeight > b.hitbox.y
end

return bullet
