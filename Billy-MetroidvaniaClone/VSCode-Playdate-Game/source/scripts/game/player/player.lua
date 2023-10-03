local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(AnimatedSprite)

function Player:init(x, y)
    -- State machine
    local playerImageTable = gfx.imagetable.new("images/player-table-16-16")
    Player.super.init(self, playerImageTable)

    self:addState("idle", 1, 1)
    self:addState("run", 1, 3, {tickStep = 4})
    self:addState("jump", 4, 4)
    self:playAnimation()

    --Sprite Properties
    self:moveTo(x, y)
    self:setZIndex(Z_INDEXES.Player)
    self:setTag(TAGS.Player)
    self:setCollideRect(3, 3, 10, 13)

    -- Physics Properties
    self.xVelocity = 0
    self.yVelocity = 0
    self.gravity = 0.125
    self.maxSpeed = 2
    self.jumpVelocity = -3
    self.drag = 0.1
    self.minimumAirSpeed = 0.5
    
    -- Player State
    self.touchingGround = false
    self.touchingCeiling = false
    self.touchingWall = false
end

function Player:collisionResponse()
    return gfx.sprite.kCollisionTypeSlide
end

function Player:update()
    self:updateAnimation()

    self:handleState()
    self:handleMovementAndCollisions()
end

function Player:handleState()
    if self.currentState == "idle" then
        self:applyGravity()
        self:handleGroundInput()
    elseif self.currentState == "run" then
        self:applyGravity()
        self:handleGroundInput()
    elseif self.currentState == "jump" then
        if self.touchingGround then
            self:changeToIdleState()
        end
        self:applyGravity()
        self:handleAirInput()
    end
end

function Player:handleMovementAndCollisions()
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

    self.touchingGround = false
    for i=1,length do
        local collision = collisions[i]
        if collision.normal.y == -1 then
            self.touchingGround = true
        end
    end

    if self.xVelocity < 0 then
        self.globalFlip = 1 -- this will flip horizontally
    elseif self.xVelocity > 0 then
        self.globalFlip = 0 -- reset to normal
    end
end

-- Input Helper Functions
function Player:handleGroundInput()
    if pd.buttonJustPressed(pd.kButtonA) then
        self:changeToJumpState()
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:changeToRunState("left")
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self:changeToRunState("right")
    else
        self:changeToIdleState()
    end
end

function Player:handleAirInput()
    if pd.buttonIsPressed(pd.kButtonLeft) then
        self.xVelocity = -self.maxSpeed
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.xVelocity = self.maxSpeed
    end
end

-- Handling State transitions
function Player:changeToRunState(direction)
    if direction == "left" then
        self.xVelocity = -self.maxSpeed
        self.globalFlip = 1 --why am I doing this in two places?? see if I can codnense this to one place
    elseif direction == "right" then
        self.xVelocity = self.maxSpeed
        self.globalFlip = 0 --why am I doing this in two places?? see if I can codnense this to one place
    end
    self:changeState("run")
end

function Player:changeToJumpState()
    self.yVelocity = self.jumpVelocity
    self:changeState("jump")
end

function Player:changeToIdleState()
    self.xVelocity = 0
    self:changeState("idle")
end

-- Physics Helper Functions
function Player:applyGravity()
    self.yVelocity += self.gravity
    if self.touchingGround then
        self.yVelocity = 0
    end    
end