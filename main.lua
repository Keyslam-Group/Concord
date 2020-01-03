--[=[
local file = "examples.simpleDrawing"
-- local file = "examples.baseLayout.main"

require(file)
]=]--

--test

local Concord = require("src")

local Component  = Concord.component
local Components = Concord.components

local System  = Concord.system
local Systems = Concord.systems

local Entity = Concord.entity

local World  = Concord.world
local Worlds = Concord.worlds


local test_comp_1 = Component(function(e, a)
    e.a = a
end)

local test_comp_2 = Component(function(e, a)
    e.a = a
end)

local test_comp_3 = Component()

local test_system_1 = System({test_comp_1})

function test_system_1:init()
    self.pool.onEntityAdded   = function()
        print("Added to test_system 1")
    end
    self.pool.onEntityRemoved = function() print("Removed from test_system 1") end
end

function test_system_1:test()
    print("Running test_system_1 with: " ..#self.pool)

    for _, e in ipairs(self.pool) do
        local newE = Entity()
        newE:give(test_comp_1)
        self:getWorld():addEntity(newE)

        e:give(test_comp_2)
    end
end



local test_system_2 = System({test_comp_2})

function test_system_2:init()
    self.pool.onEntityAdded   = function(pool, e) print("Added to test_system 2") e:remove(test_comp_1) end
    self.pool.onEntityRemoved = function() print("Removed from test_system 2") end
end

function test_system_2:test()
    print("Running test_system_2 with: " ..#self.pool)

    for _, e in ipairs(self.pool) do
    end
end

local world = World()

local entity = Entity(world)
entity:give(test_comp_1, 100, 100)

world:addSystem(test_system_1, "test")
world:addSystem(test_system_2, "test")

print("Iteration: 1")
world:emit("test")

print("Iteration: 2")
world:emit("test")

print("Iteration: 3")
world:emit("test")