local pd <const> = playdate
local gfx <const> = pd.graphics

-- Caching images for fade transition option
local fadedRects = {}
for i=0,1,0.01 do
    local fadedImage = gfx.image.new(400, 240)
    gfx.pushContext(fadedImage)
        local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
        filledRect:drawFaded(0, 0, i, gfx.image.kDitherTypeBayer8x8)
    gfx.popContext()
    fadedRects[math.floor(i * 100)] = fadedImage
end
fadedRects[100] = gfx.image.new(400, 240, gfx.kColorBlack) --the loop doesn't hit this image so he's setting it manually... can't we adjust the loop???

class('SceneManager').extends() --doesn't extend the sprite class.... this feels wrong yo!

function SceneManager:init()
    self.transitionTime = 1000
    self.transitioning = false
end

function SceneManager:switchScene(scene, ...) --the elipsees represent a variable number of arguments
    if self.transitioning then
        return
    end
    
    self.transitioning = true

    self.newScene = scene
    self.sceneArgs = ...

    self:startTransition()
end

function SceneManager:loadNewScene()
    self:cleanupScene()
    self.newScene(self.sceneArgs)
end

--THIS IS WHERE WE START THE TRANSITION ITSELF
function SceneManager:startTransition()
    local transitionTimer = self:fadeTransition(0, 1)

    transitionTimer.timerEndedCallback = function()
        self:loadNewScene()
        transitionTimer = self:fadeTransition(1, 0)
        transitionTimer.timerEndedCallback = function()
            self.transitioning = false
        end
    end
end

--WIPE TRANSITION
function SceneManager:wipeTransition(startValue, endValue)
    local transitionSprite = self:createTransitionSprite()
    transitionSprite:setClipRect(0, 0, startValue, 240)

    local transitionTimer = pd.timer.new(self.transitionTime, startValue, endValue, pd.easingFunctions.inOutCubic)
    transitionTimer.updateCallback = function(timer)
        transitionSprite:setClipRect(0, 0, timer.value, 240)
    end
    return transitionTimer
end

--FADE TRANSITION
function SceneManager:fadeTransition(startValue, endValue)
    local transitionSprite = self:createTransitionSprite()
    transitionSprite:setImage(self:getFadedImage(startValue))

    local transitionTimer = pd.timer.new(self.transitionTime, startValue, endValue, pd.easingFunctions.inOutCubic)
    transitionTimer.updateCallback = function(timer)
        transitionSprite:setImage(self:getFadedImage(timer.value))
    end
    return transitionTimer
end

function SceneManager:getFadedImage(alpha)
    return fadedRects[math.floor(alpha * 100)]
end

function SceneManager:createTransitionSprite()
    local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
    local transitionSprite = gfx.sprite.new(filledRect)
    transitionSprite:moveTo(200, 120)
    transitionSprite:setZIndex(10000) --ensure the transition is drawn over everything else 
    transitionSprite:setIgnoresDrawOffset(true)
    transitionSprite:add()
    return transitionSprite
end

function SceneManager:cleanupScene()
    gfx.sprite.removeAll() --clears the previous scene, since everything but this class is a sprite it makes clearing scenes super easy
    self:removeAllTimers() --clear all timers from room since these are not sprites
    gfx.setDrawOffset(0, 0) --reset any draw offsets that may have been active in scene
end

function SceneManager:removeAllTimers() --a small method to remove any timers that may be running in the current scene
    local allTimers = pd.timer.allTimers() --get all timers
    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end