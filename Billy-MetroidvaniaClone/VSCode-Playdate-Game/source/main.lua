--IMPORT LIBRARIES
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/object"

--Custom Libraries
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/LDtk.lua"

--IMPORT CLASSSES
import "scripts/game/scenes/rooms/Room1"
import "scripts/game/player/player"

Room1()

--DECLARE CONSTANTS
local pd <const> = playdate
local gfx <const> = pd.graphics

--GLOBAL VARS eventually move these to the globals CLASSSES

function pd.update()
	gfx.sprite.update()
	pd.timer.updateTimers()
end
