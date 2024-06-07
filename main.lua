local vec2 = require("vec2");
local astarmod = require("astar");

local gridSize = 25;

local gridWidth, gridHeight;

local astar;
local grid;

math.randomseed(os.time())

function love.load()
    love.window.setTitle("pathfinding");
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1);
    

    local windowWidth, windowHeight = love.graphics.getDimensions();

    gridWidth = math.floor(windowWidth / gridSize);
    gridHeight = math.floor(windowHeight / gridSize);

    grid = {};
    for i = 1, gridWidth do
        grid[i] = {};
        for j = 1, gridHeight do
            grid[i][j] = false;
        end
    end

    local rand = math.random;
    local start, finish = vec2.new(rand(gridWidth), rand(gridHeight)), vec2.new(rand(gridWidth), rand(gridHeight));

    astar = astarmod.new(grid, start, finish);

    grid[start.x][start.y] = 2;
    grid[finish.x][finish.y] = 3;

    print("init")
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
            else
                love.graphics.setColor(0.75, 0.75, 0.75);
            end
            love.graphics.rectangle("fill", (i - 1) * gridSize, (j - 1) * gridSize, gridSize, gridSize);
            love.graphics.setColor(1, 1, 1);
            love.graphics.rectangle("line", (i - 1) * gridSize, (j - 1) * gridSize, gridSize, gridSize);
        end
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        local cellX = math.floor(x / gridSize) + 1;
        local cellY = math.floor(y / gridSize) + 1;

        if cellX >= 1 and cellX <= gridWidth and cellY >= 1 and cellY <= gridHeight then
            grid[cellX][cellY] = 1;
        end
    end
end

function love.keypressed(key)
    if key == "w" then
        astar:pushfronttier();
    elseif key == "e" then
        astar:resolvepath();
    end
end