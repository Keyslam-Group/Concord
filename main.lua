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
function test_system:update(dt)
    print(#self.pool)
end

local world = Concord.world()

local entity = Concord.entity()
entity:give(Component.test_comp_2, 100, 100)
entity:apply()

world:addEntity(entity)

world:addSystem(test_system(), "update")

function love.update(dt)
    world:emit("update", dt)
end