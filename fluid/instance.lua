local PATH = (...):gsub('%.[^%.]+$', '')

local List         = require(PATH..".list")
local EventManager = require(PATH..".eventManager")

local Instance = {}
Instance.__index = Instance

function Instance.new()
   local instance = setmetatable({
      entities     = List(),
      systems      = List(),
      systemCount  = {},
      eventManager = EventManager(),
   }, Instance)

   return instance
end

function Instance:addEntity(e)
   e.instances:add(self)
   self.entities:add(e)
   self:checkEntity(e)
end

function Instance:checkEntity(e)
   for i = 1, self.systems.size do
      self.systems:get(i):__check(e)
   end
end

function Instance:removeEntity(e)
   e.instances:remove(self)
   self.entities:remove(e)

   for i = 1, self.systems.size do
      self.systems:get(i):__remove(e)
   end
end

function Instance:addSystem(system, eventName, callback)
   self.systemCount[system] = (self.systemCount[system] or 0) + 1
   self.systems:add(system)

   self.eventManager:register(eventName, system, callback)

   return self
end

function Instance:removeSystem(system, callback)
   self.systemCount[system] = self.systemCount[system] - 1
   if self.systemCount[system] == 0 then
      self.systemCount[system] = nil
      self.eventManager:deregister(eventName, system, callback)
   end

   return self
end

function Instance:emit(...)
   self.eventManager:emit(...)

   return self
end

return setmetatable(Instance, {
   __call = function(_, ...) return Instance.new(...) end,
})
