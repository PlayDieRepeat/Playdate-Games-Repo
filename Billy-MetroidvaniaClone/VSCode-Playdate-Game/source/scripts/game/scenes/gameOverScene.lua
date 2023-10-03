import "scripts/game/scenes/rooms/room1"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameOverScene').extends(gfx.sprite) --create a class that extends the sprite class

function GameOverScene:init(text)
    local gameOverImage = gfx.image.new(gfx.getTextSize(text))
    gfx.pushContext(gameOverImage)
        gfx.drawText(text, 0, 0)
    gfx.popContext()
    local gameOverSprite = gfx.sprite.new(gameOverImage)
    gameOverSprite:moveTo(200, 120)
    gameOverSprite:add()

    self:add()
end

function GameOverScene:update()
    if pd.buttonJustPressed(pd.kButtonA) then --shortcut to test scene manager
        SCENE_MANAGER:switchScene(Room1)
    end
end

