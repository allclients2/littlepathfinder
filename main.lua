local vec2 = require("vec2");
local astarmod = require("astar");
local timer = require("timer");

local gridSize = 15;
local heuristic = 0.1;

local gridWidth, gridHeight;

local astar;
local grid;
local reset;

math.randomseed(os.time())

local function timedalgorithm()
	local sound = love.audio.newSource("beep.wav", "static");
    sound:setVolume(0.1);
    sound:setLooping(false);

    local steps = 0;
    local timercurrent = timer.new(0.02); --upvalue
    return function ()
        if timercurrent:elapsed() then
            steps = steps + 0.05;
            if astar.pathfound then
                astar:resolvepath();
                sound:setPitch(0.6);
                sound:play();
                return true;
            elseif astar.pathfailed then
                sound:setPitch(0.1);
                sound:play();
                return true;
            end
            astar:pushfrontier();
            timercurrent:reset();
            sound:setPitch(steps);
            sound:play();
        end
    end
end

function reset(randomobstacules)
    grid = {};
    for i = 1, gridWidth do
        grid[i] = {};
        for j = 1, gridHeight do
            grid[i][j] = (randomobstacules and math.random() > 0.7) and 1 or 0;
        end
    end

    local rand = math.random;
    local start, finish = vec2.new(rand(gridWidth), rand(gridHeight)), vec2.new(rand(gridWidth), rand(gridHeight));

    astar = astarmod.new(grid, start, finish, heuristic);

    grid[start.x][start.y] = 2;
    grid[finish.x][finish.y] = 3;
end

local function automaticlooped()
    local timed = timedalgorithm();
    local timer, running = timer.new(1.8), false; --upvalue
    love.update = function ()
        if timed() then
            if running then
                if timer:elapsed() then
                    reset(true);
                    timed = timedalgorithm();
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
    local timed = timedalgorithm();
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
            if grid[i][j] == 1 then
                love.graphics.setColor(0.1, 0.1, 0.1);
            elseif grid[i][j] == 2 then
                love.graphics.setColor(0.1, 0.8, 0.1);
            elseif grid[i][j] == 3 then
                love.graphics.setColor(0.8, 0.1, 0.1);
            elseif grid[i][j] == 4 then
                love.graphics.setColor(0.5, 0.5, 0.5);
            elseif grid[i][j] == 5 then
                love.graphics.setColor(0.3, 0.8, 0.3);
            elseif grid[i][j] == 6 then
                love.graphics.setColor(0.5, 0.5, 0.8);
            else
                love.graphics.setColor(0.75, 0.75, 0.75);
            end
            love.graphics.rectangle("fill", (i - 1) * gridSize, (j - 1) * gridSize, gridSize, gridSize);
            love.graphics.setColor(1, 1, 1);
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
