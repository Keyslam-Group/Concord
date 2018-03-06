local PATH = (...):gsub('%.[^%.]+$', '')

local List         = require(PATH..".list")
local EventManager = require(PATH..".eventManager")

local Instance = {}
Instance.__index = Instance

function Instance.new()
   local instance = setmetatable({
      entities     = List(),
      systems      = {},
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

function Instance:addSystem(system, eventName, callback, enabled)
   self.systems[eventName] = self.systems[eventName] or {}

   local i = #self.systems[eventName] + 1
   self.systems[eventName][i] = {
      system    = system,
      eventName = eventName,
      callback  = callback or eventName,
      enabled   = enabled == nil or true,
   }

   return self
end

function Instance:enableSystem(system, eventName, callback)

end

function Instance:disableSystem(system, eventName, callback)

end

function Instance:emit(...)
   self.eventManager:emit(...)

   return self
end

return setmetatable(Instance, {
   __call = function(_, ...) return Instance.new(...) end,
})
