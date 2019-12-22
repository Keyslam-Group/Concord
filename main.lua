--[=[
local file = "examples.simpleDrawing"
-- local file = "examples.baseLayout.main"

require(file)
]=]--

--test

local Concord = require("src")

local Component  = require("src.component")
local Components = require("src.components")

local System  = Concord.system
local Systems = Concord.systems

local Entity = Concord.entity

local World  = Concord.world
local Worlds = Concord.worlds

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

local function onEntityAdded(pool, e) -- luacheck: ignore
    local test_comp = e:get(Components.test_comp_1)
    print(test_comp.x)
end

local function onEntityRemoved(pool, e) -- luacheck: ignore
    print("Removed")
end

function test_system:init()
    self.pool.onEntityAdded   = onEntityAdded
    self.pool.onEntityRemoved = onEntityRemoved
end

function test_system:update(dt) -- luacheck: ignore
    --[=[
    for _, v in ipairs(self.pool) do
        print(v)
    end
    ]=]
end

function test_system:update2(dt) -- luacheck: ignore
    --print(#self.pool)
end


local world = World("testWorld")

local entity = Entity()
entity
:give(Components.test_comp_1, 100, 100)
:remove(Components.test_comp_1)
:give(Components.test_comp_1, 200, 100)


Worlds.testWorld:addEntity(entity)

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