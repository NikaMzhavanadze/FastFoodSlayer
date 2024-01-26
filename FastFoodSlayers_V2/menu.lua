-- menu.lua

local Menu = {}

function Menu.newNextLevelButton()
    local self = {}

    self.x = 700
    self.y = 300
    self.width = 150
    self.height = 50
    self.label = "Next Level"
    self.isHovered = false
    self.currentColor = { 0.5, 0.5, 0.5 }

    return self
end

function Menu.newRestartButton()
    local self = {}

    self.x = 700
    self.y = 400
    self.width = 150
    self.height = 50
    self.label = "Restart"
    self.isHovered = false
    self.currentColor = { 0.5, 0.5, 0.5 }

    return self
end

function Menu.newMainMenuButton()
    local self = {}

    self.x = 700
    self.y = 500
    self.width = 150
    self.height = 50
    self.label = "Main Menu"
    self.isHovered = false
    self.currentColor = { 0.5, 0.5, 0.5 }

    return self
end

function Menu.newPauseButton()
    local self = {}

    self.x = 700
    self.y = 600
    self.width = 150
    self.height = 50
    self.label = "Resume"
    self.isHovered = false
    self.currentColor = { 0.5, 0.5, 0.5 }

    return self
end

function Menu.newMainMenuButton()
    local self = {}

    self.x = 700
    self.y = 700
    self.width = 150
    self.height = 50
    self.label = "Main Menu"
    self.isHovered = false
    self.currentColor = { 0.5, 0.5, 0.5 }

    return self
end

function Menu.updateButtonColor(button)
    if button.isHovered then
        button.currentColor = { 0.7, 0.7, 0.7 }
    else
        button.currentColor = { 0.5, 0.5, 0.5 }
    end
end

return Menu
