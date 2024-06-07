local vec2 = {};
vec2.__index = vec2;
vec2.type = "vector2";

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

function vec2:mag()
    return math.sqrt(self.x ^ 2 + self.y ^ 2);
end

--dist = (a - b).mag
function vec2:dist(other)
    return (self + other):mag();
end

-- metamethods
function vec2:__eq(other)
    return other.x == self.x and other.y == self.y;
end

function vec2:__add(other)
    return setmetatable({
        x = self.x + other.x,
        y = self.y + other.y,
    }, vec2);
end

return vec2;