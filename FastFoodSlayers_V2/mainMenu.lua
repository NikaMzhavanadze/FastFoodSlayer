screenWidth = 1240
screenHeight = 720

function love.load()
    love.window.setTitle("Game Start Menu")
    love.window.setMode(screenWidth, screenHeight)
    titleFont = love.graphics.newFont("titleFont.ttf", 48)
    font = love.graphics.newFont("titleFont.ttf", 24)
    
    backgroundImage = love.graphics.newImage("backgroundImage.png")
    
    imageX = (screenWidth - backgroundImage:getWidth()) / 2
    imageY = (screenHeight - backgroundImage:getHeight()) / 2
end

function love.update(dt)
    if love.keyboard.isDown("space") then
        print("Starting the game!")
        -- aq gadaviyvaant personajis archevis statshi.
    end
end

function love.draw()
    love.graphics.setColor(255, 0, 0)
    love.graphics.draw(backgroundImage, imageX, imageY)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(titleFont)
    local text = "Fast Food Slayers"
    local textWidth = titleFont:getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, 180)

    love.graphics.setFont(font)
    local startText = "Press Space to Start Game"
    local startTextWidth = font:getWidth(startText)
    love.graphics.print(startText, (screenWidth - startTextWidth) / 2, screenHeight - 100)
end
