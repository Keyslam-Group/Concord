local Concord = require("src")

local Entity    = Concord.entity
local Component = Concord.component
local System    = Concord.system

local Game = Concord.world()

local Position = Component(function(e, x, y)
   e.x = x
   e.y = y
end)

local Rectangle = Component(function(e, w, h)
   e.w = w
   e.h = h
end)

local Circle = Component(function(e, r)
   e.r = r
end)

local Color = Component(function(e, r, g, b, a)
   e.r = r
   e.g = g
   e.b = b
   e.a = a
end)

local RectangleRenderer = System({Position, Rectangle})
function RectangleRenderer:draw()
   for _, e in ipairs(self.pool) do
      local position  = e:get(Position)
      local rectangle = e:get(Rectangle)
      local color     = e:get(Color)

      love.graphics.setColor(255, 255, 255)
      if color then
         love.graphics.setColor(color.r, color.g, color.b, color.a)
      end

      love.graphics.rectangle("fill", position.x, position.y, rectangle.w, rectangle.h)
   end
end

local CircleRenderer = System({Position, Circle})
function CircleRenderer:flush()
   for _, e in ipairs(self.pool.removed) do
      print(tostring(e).. " was removed from my pool D:")
   end
end

function CircleRenderer:draw()
   for _, e in ipairs(self.pool) do
      local position = e:get(Position)
      local circle   = e:get(Circle)
      local color    = e:get(Color)

      love.graphics.setColor(255, 255, 255)
      if color then
         love.graphics.setColor(color.r, color.g, color.b, color.a)
      end

      love.graphics.circle("fill", position.x, position.y, circle.r)
   end
end

local RandomRemover = System({})

function RandomRemover:init()
   self.time = 0
end

function RandomRemover:update(dt)
   self.time = self.time + dt

   if self.time >= 0.05 then
      self.time = 0

      if self.pool.size > 0 then
         local i = love.math.random(1, self.pool.size)

         self.pool:get(i):destroy()
      end
   end

   love.window.setTitle(love.timer.getFPS())
end

Game:addSystem(RandomRemover(),     "update")
Game:addSystem(RectangleRenderer(), "draw")
Game:addSystem(CircleRenderer(),    "draw")

for _ = 1, 100 do
   local e = Entity()
   e:give(Position, love.math.random(0, 700), love.math.random(0, 700))
   e:give(Rectangle, love.math.random(5, 20), love.math.random(5, 20))

   if love.math.random(0, 1) == 0 then
      e:give(Color, love.math.random(), love.math.random(), love.math.random(), 1)
   end

   Game:addEntity(e)
end

for _ = 1, 100 do
   local e = Entity()
   e:give(Position, love.math.random(0, 700), love.math.random(0, 700))
   e:give(Circle, love.math.random(5, 20))

   if love.math.random(0, 1) == 0 then
      e:give(Color, love.math.random(), love.math.random(), love.math.random(), 1)
   end

   Game:addEntity(e)
end


function love.update(dt)
   Game:emit("update", dt)
end

function love.draw()
   Game:emit("draw")
end
