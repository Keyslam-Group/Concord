local Concord = require("src")

local Entity     = Concord.entity
local Component  = Concord.component
local System     = Concord.system
local Assemblage = Concord.assemblage

local Game = Concord.context()

local Legs = Component(function(e, legCount)
   e.legCount = legCount or 0
end)

local Instinct = Component(function(e) -- luacheck: ignore
end)

local Cool = Component(function(e, coolness)
   e.coolness = coolness
end)

local Wings = Component(function(e)
   e.wingCount = 2
end)


local Animal = Assemblage(function(e, legCount)
   e
   :give(Legs, legCount)
   :give(Instinct)

   print("Animal")
end)

local Lion = Assemblage(function(e, coolness)
   e
   :assemble(Animal, 4)
   :give(Cool, coolness)

   print("Lion")
end)

local Eagle = Assemblage(function(e)
   e
   :assemble(Animal, 2)
   :give(Wings)

   print("Eagle")
end)

local Griffin = Assemblage(function(e, coolness)
   e
   :assemble(Animal, 4)
   :assemble(Lion, coolness * 2)
   :assemble(Eagle)
end)


local myAnimal = Entity()
:assemble(Griffin, 5)
--:apply()

print(myAnimal:has(Legs))
print(myAnimal:has(Instinct))
print(myAnimal:has(Cool))
print(myAnimal:has(Wings))
