local Concord = require("concord")

local function display(t)
    print("Table: " ..tostring(t))
    for key, value in pairs(t) do
        if type(value) == "table" then
            display(value)
        else
            print(key, value)
        end
    end
end

local test_component_1 = Concord.component(function(e, x, y)
    e.x = x or 0
    e.y = y or 0
end)
Concord.components.register("test_component_1", test_component_1)

function test_component_1:serialize()
    return {
        x = self.x,
        y = self.y,
    }
end

function test_component_1:deserialize(data)
    self.x = data.x or 0
    self.y = data.y or 0
end

local test_component_2 = Concord.component(function(e, foo)
    e.foo = foo
end)
Concord.components.register("test_component_2", test_component_2)

function test_component_2:serialize()
    return {
        foo = self.foo
    }
end

function test_component_2:deserialize(data)
    self.foo = data.foo
end

-- Test worlds
local world_1 = Concord.world()
local world_2 = Concord.world()

-- Test Entity
Concord.entity(world_1)
:give(test_component_1, 100, 50)
:give(test_component_2, "Hello World!")

-- Serialize world
local data = world_1:serialize()

-- Deserialize world
world_2:deserialize(data)

-- Check result
local test_entity_copy = world_2:getEntities()[1]

local test_comp_1 = test_entity_copy[test_component_1]
local test_comp_2 = test_entity_copy[test_component_2]

print(test_comp_1.x, test_comp_1.y)
print(test_comp_2.foo)