--[=[
local file = "examples.simpleDrawing"
-- local file = "examples.baseLayout.main"

require(file)
]=]--

local Concord = require("src")
local Component = require("src.component")

local test_comp_1 = Concord.component("test_comp_1", function(e, x, y)
    e.x = x
    e.y = y
end)

local test_comp_2 = Concord.component("test_comp_2", function(e, a)
    e.a = a
end)

local test_comp_3 = Concord.component("test_comp_3", function(e, b)
    e.b = b
end)

local test_system = Concord.system({Component.test_comp_1})

function onEntityAdded(e)
    print("Added")
end

function onEntityRemoved(e)
    print("Removed")
end

function test_system:init()
    self.pool.onEntityAdded = onEntityAdded
    self.pool.onEntityRemoved = onEntityRemoved
end

function test_system:update(dt)
    --print(#self.pool)
end



local world = Concord.world()

local entity = Concord.entity()
entity:give(Component.test_comp_1, 100, 100)

world:addEntity(entity)

world:addSystem(test_system(), "update")

function love.update(dt)
    world:flush()

    world:emit("update", dt)
end

function love.keypressed(key)
    if key == "q" then
        entity:remove(Component.test_comp_1)
    end
    if key == "w" then
        entity:give(Component.test_comp_1)
    end
    if key == "e" then
        world:removeEntity(entity)
    end
end