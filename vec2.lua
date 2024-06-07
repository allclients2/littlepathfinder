local vec2 = {};
vec2.__index = vec2;

vec2.__eq = function(self, other)
    return other.x == self.x and other.y == self.y;
end


function vec2.new(x, y)
    return setmetatable({
        x = x,
        y = y,
    }, vec2);
end

function vec2:add(x, y)
    return setmetatable({
        x = self.x + x,
        y = self.y + y,
    }, vec2);
end

return vec2;