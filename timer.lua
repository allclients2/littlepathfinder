local timer = {}
timer.__index = timer

function timer.new(duration)
    local self = setmetatable({}, timer)
    self.startTime = love.timer.getTime()
    self.duration = duration
    return self
end

function timer:reset()
    self.startTime = love.timer.getTime()
end

function timer:elapsed()
    return love.timer.getTime() - self.startTime >= self.duration
end

return timer;