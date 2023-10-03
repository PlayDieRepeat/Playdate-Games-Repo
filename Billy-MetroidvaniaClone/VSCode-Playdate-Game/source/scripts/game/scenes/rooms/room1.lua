import "scripts/game/scenes/gameOverScene"

local pd <const> = playdate
local gfx <const> = pd.graphics
local ldtk <const> = LDtk

TAGS = {
    Player = 1
}

Z_INDEXES = {
    Player = 100
}

-- load the level
ldtk.load("levels/metro.ldtk", false)

class('Room1').extends()

function Room1:init()
    self:goToLevel("Level_0")
    self.spawnX = 6 * 16
    self.spawnY = 10 * 16

    self.player = Player(self.spawnX, self.spawnY)
end

function Room1:goToLevel(levelName)
    gfx.sprite.removeAll() --clears the level

    for layerName, layer in pairs(ldtk.get_layers(levelName)) do
        if layer.tiles then
            local tilemap = ldtk.create_tilemap(levelName, layerName)

            local layerSprite = gfx.sprite.new()
            layerSprite:setTilemap(tilemap)
            layerSprite:moveTo(0, 0)
            layerSprite:setCenter(0, 0)
            layerSprite:setZIndex(layer.zIndex)
            layerSprite:add()

            local emptyTiles = ldtk.get_empty_tileIDs(levelName, "Solid", layerName)
            if emptyTiles then
                gfx.sprite.addWallSprites(tilemap, emptyTiles)
            end
        end
    end
end
