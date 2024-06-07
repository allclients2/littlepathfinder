local astar = {};
astar.__index = astar;

local function clone(t)
    local t2 = {};
    for i, v in pairs(t) do
        t2[i] = v;
    end
    return t2;
end

local function isnullmap(map, x, y)
    if map[x] then
        return not map[x][y];
    end
end

function astar.new(grid, start, finish)
    local self = {
        pathfound = false;
        grid = grid;
        start = start,
        finish = finish,
        fronttier = {start},
    }

    local x, y = #grid, #grid[1];
    local exploredmap = {};
    for i = 1, x do
        exploredmap[i] = {};
        for j = 1, y do
            exploredmap[i][j] = false;
        end
    end
    self.exploredmap = exploredmap;

    return setmetatable(self, astar);
end

function astar:pushpos(pos)
    for _, check in ipairs({pos:add(-1, 0), pos:add(1, 0), pos:add(0, 1), pos:add(0, -1)}) do
        local x, y = check.x, check.y;
        if isnullmap(self.exploredmap, x, y) and (isnullmap(self.grid, x, y) or check == self.finish) then
            self.exploredmap[x][y] = pos;
            self.grid[x][y] = 4; --indicate its checked
            self.fronttier[#self.fronttier + 1] = check;

            if check == self.finish then
                self.pathfound = true;
                print("found path!");
                break
            end
        end
    end
end

function astar:pushfronttier()
    local fronttier2 = clone(self.fronttier);
    self.fronttier = {}

    for _, fronttierpos in ipairs(fronttier2) do
        self:pushpos(fronttierpos);
    end
end

function astar:resolvepath()
    if self.pathfound then
        local pos = self.exploredmap[self.finish.x][self.finish.y];
        repeat
            self.grid[pos.x][pos.y] = 5;
            pos = self.exploredmap[pos.x][pos.y];
        until pos == self.start;
    end
end


return astar;