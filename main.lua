--[=[
local file = "examples.simpleDrawing"
-- local file = "examples.baseLayout.main"

require(file)
]=]--

--test

local Concord = require("src")

local Component = Concord.component
local System    = Concord.system
local Entity    = Concord.entity
local World     = Concord.world

local test_comp_1 = Component(function(e, a)
    e.a = a
end)

local test_system_1 = System({test_comp_1})
local test_system_2 = System({test_comp_1})
local test_system_3 = System({test_comp_1})

function test_system_1:test()
    for _, _ in ipairs(self.pool) do
    end
end

function test_system_2:test()
    for _, _ in ipairs(self.pool) do
    end
end

function test_system_3:test()
    for _, _ in ipairs(self.pool) do
    end
end

local world = World()

world:addSystems(test_system_1, test_system_2, test_system_3)

for _ = 1, 100 do
    local entity = Entity(world)
    entity:give(test_comp_1, 100, 100)
end


local start = love.timer.getTime()
for _ = 1, 1000000 do
    world:emit("test")
end
local stop = love.timer.getTime()

print("Time taken: " .. stop - start)