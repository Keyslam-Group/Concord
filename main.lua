--[=[
local file = "examples.simpleDrawing"
-- local file = "examples.baseLayout.main"

require(file)
]=]--

local Concord = require("src")

local Component  = require("src.component")
local Components = require("src.components")

local System  = Concord.system
local Systems = Concord.systems

local Entity = Concord.entity

local World = Concord.world

Component("test_comp_1", function(e, x, y)
    e.x = x
    e.y = y
end)

Component("test_comp_2", function(e, a)
    e.a = a
end)

Component("test_comp_3", function(e, b)
    e.b = b
end)

local test_system = System("test_system", {Components.test_comp_1})

local function onEntityAdded(e) -- luacheck: ignore
    print("Added")
end

local function onEntityRemoved(e) -- luacheck: ignore
    print("Removed")
end

function test_system:init()
    self.pool.onEntityAdded   = onEntityAdded
    self.pool.onEntityRemoved = onEntityRemoved
end

function test_system:update(dt) -- luacheck: ignore
    --print(#self.pool)
end

function test_system:update2(dt) -- luacheck: ignore
    --print(#self.pool)
end


local world = World()

local entity = Entity()
entity:give(Components.test_comp_1, 100, 100)

world:addEntity(entity)

world:addSystem(Systems.test_system, "update")
world:addSystem(Systems.test_system, "update", "update2")

function love.update(dt)
    world:flush()

    world:emit("update", dt)
end

function love.keypressed(key)
    if key == "q" then
        entity:remove(Components.test_comp_1)
    end
    if key == "w" then
        entity:give(Components.test_comp_1)
    end
    if key == "e" then
        world:removeEntity(entity)
    end
end