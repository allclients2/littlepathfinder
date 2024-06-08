local vec2 = require("vec2");
local astarmod = require("astar");
local timer = require("timer");

local gridSize = 10;
local heuristic = 0.3;

local gridWidth, gridHeight;

local astar;
local grid;
local reset;
local start, finish;

local colormap = {
    [1] = {0.55, 0.55, 0.55},
    [2] = {0.1, 0.8, 0.1},
    [3] = {0.8, 0.1, 0.1},
    [4] = {0.7, 0.7, 0.7},
    [5] = {0.3, 0.8, 0.3},
    [6] = {0.5, 0.5, 0.8},
}

math.randomseed(os.time())

local function mhdist(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2);
end

local rand = math.random;

local function timedsolve()
	local sound = love.audio.newSource("beep.wav", "static");
    sound:setVolume(0.1);
    sound:setLooping(false);

    local maxcostbestdiff = math.sqrt(gridWidth * gridHeight) * 2;
    local alltimebest = nil;
    local maxpitch = 1.5;
    local steps = 0;
    local timercurrent = timer.new(0.02); --upvalue
    return function ()
        if timercurrent:elapsed() then
            steps = steps + 0.05;

            local costratio = astar.bestnode and (astar.bestnode[2] / mhdist(start.x, start.y, finish.x, finish.y)) or 0.5;
            if astar.pathfound then
                astar:resolvepath();
                sound:setPitch(0.6);
                sound:play();
                return true;
            elseif astar.pathfailed or (alltimebest and astar.bestnode and ((astar.bestnode[2] - alltimebest) > maxcostbestdiff)) then
                sound:setPitch(0.1);
                sound:play();
                return true;
            end

            if astar.bestnode and (not alltimebest or alltimebest > astar.bestnode[2]) then
                alltimebest = astar.bestnode[2];
            end

            astar:pushfrontier();
            timercurrent:reset();
            sound:setPitch(maxpitch - (math.min(costratio, 1) * maxpitch) + 0.05);
            sound:play();
        end
    end
end

function reset(randomobstacules)
    grid = {};
    for i = 1, gridWidth do
        grid[i] = {};
        for j = 1, gridHeight do
            grid[i][j] = (randomobstacules and math.random() > 0.6) and 1 or 0;
        end
    end

    start, finish = vec2.new(rand(gridWidth), rand(gridHeight)), vec2.new(rand(gridWidth), rand(gridHeight));

    astar = astarmod.new(grid, start, finish, heuristic);

    grid[start.x][start.y] = 2;
    grid[finish.x][finish.y] = 3;
end

local function automaticlooped()
    local timed = timedsolve();
    local timer, running = timer.new(1.8), false; --upvalue
    love.update = function ()
        if timed() then
            if running then
                if timer:elapsed() then
                    reset(true);
                    timed = timedsolve();
                    running = false;
                end
            else
                running = true;
                timer:reset();
            end
        end
    end
end

local function automatic()
    local timed = timedsolve();
    love.update = function ()
        if timed() then
            love.update = nil;
        end
    end
end

-- love methods

function love.keypressed(key)
    if key == "w" then
        astar:pushfrontier();
    elseif key == "e" then
        astar:resolvepath();
    elseif key == "space" then
        automatic();
    elseif key == "q" then
        reset(false);
    elseif key == "a" then
        reset(true);
    elseif key == "d" then
        automaticlooped();
    elseif key == "x" then
        love.update = nil;
    end
end

local drawing = false
local erasing = false

function love.mousepressed(x, y, button, istouch, presses)
    local cellX = math.floor(x / gridSize) + 1;
    local cellY = math.floor(y / gridSize) + 1;

    if cellX >= 1 and cellX <= gridWidth and cellY >= 1 and cellY <= gridHeight then
        if button == 1 then
            drawing = true;
            grid[cellX][cellY] = 1;
        elseif button == 2 then
            erasing = true;
            grid[cellX][cellY] = 0;
        end
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        drawing = false;
    elseif button == 2 then
        erasing = false;
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    local cellX = math.floor(x / gridSize) + 1;
    local cellY = math.floor(y / gridSize) + 1;

    if cellX >= 1 and cellX <= gridWidth and cellY >= 1 and cellY <= gridHeight then
        if drawing then
            grid[cellX][cellY] = 1;
        elseif erasing then
            grid[cellX][cellY] = 0;
        end
    end
end

function love.draw()
    for i = 1, gridWidth do
        for j = 1, gridHeight do
            if colormap[grid[i][j]] then
                local color = colormap[grid[i][j]];
                love.graphics.setColor(color[1], color[2], color[3]);
            else
                love.graphics.setColor(0.15, 0.15, 0.15);
            end
            love.graphics.rectangle("fill", (i - 1) * gridSize, (j - 1) * gridSize, gridSize, gridSize);
            love.graphics.setColor(.2, .2, .2);
            love.graphics.rectangle("line", (i - 1) * gridSize, (j - 1) * gridSize, gridSize, gridSize);
        end
    end
end

function love.load()
    love.window.setMode(1920, 900)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1);
    

    local windowWidth, windowHeight = love.graphics.getDimensions();

    gridWidth = math.floor(windowWidth / gridSize);
    gridHeight = math.floor(windowHeight / gridSize);

    love.window.setTitle("A* Pathfinding Algorithm ("..gridWidth.." x "..gridHeight..")");

    reset(true);

    print("init")
end
