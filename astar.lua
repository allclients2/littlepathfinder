local astar = {};
astar.__index = astar;

local function isstatemap(map, x, y, state)
    if map[x] then
        return map[x][y] == state;
    end
end

local function mhdist(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2);
end

function astar.new(grid, start, finish, heuristicfactor)
    local self = setmetatable({
        pathfound = false;
        pathfailed = false;
        heuristicfactor = heuristicfactor;
        bestnode = nil;
        grid = grid;
        start = start;
        finish = finish;
        frontier = {{start, mhdist(start.x, start.y, finish.x, finish.y), 0}},
    }, astar)
    self:makeexploredmap();
    return self;
end

function astar:makeexploredmap()
    local x, y = #self.grid, #self.grid[1];
    local exploredmap = {};
    for i = 1, x do
        exploredmap[i] = {};
        for j = 1, y do
            exploredmap[i][j] = false;
        end
    end
    self.exploredmap = exploredmap;
end

function astar:pushnode(node)
    local pos, diststart = node[1], node[3];
    for _, check in ipairs({pos:add(-1, 0), pos:add(1, 0), pos:add(0, 1), pos:add(0, -1)}) do
        local x, y = check.x, check.y;
        if isstatemap(self.exploredmap, x, y, false) and (isstatemap(self.grid, x, y, 0) or check == self.finish) then
            self.exploredmap[x][y] = pos;
            self.grid[x][y] = 6; --indicate its checked

            local distend = mhdist(x, y, self.finish.x, self.finish.y);
            self.frontier[#self.frontier + 1] = {check, distend, diststart + self.heuristicfactor}; --push new node

            if check == self.finish then
                self.pathfound = true;
                print("found path!");
                break
            end
        end
    end
end

function astar:pushfrontier()
    if not self.pathfailed then
        table.sort(self.frontier, function(node1, node2)
            return (node1[2] + node1[3]) < (node2[2] + node2[3]);
        end);
    
        local currentnode = table.remove(self.frontier, 1);
        self.bestnode = currentnode;

        if not currentnode then
            self.pathfailed = true;
        else
            self.grid[currentnode[1].x][currentnode[1].y] = 4; --remove its frontier status
            self:pushnode(currentnode);
        end
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