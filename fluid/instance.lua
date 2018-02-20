local PATH = (...):gsub('%.[^%.]+$', '')

local List         = require(PATH..".list")
local EventManager = require(PATH..".eventManager")

local Instance = {}
Instance.__index = Instance

function Instance.new()
   local instance = setmetatable({
      entities     = List(),
      eventManager = EventManager(),

      systems      = {},
      namedSystems = {},
   }, Instance)

   return instance
end

function Instance:addEntity(e)
   e.instances:add(self)
   self.entities:add(e)
   self:checkEntity(e)
end

function Instance:checkEntity(e)
   for _, system in ipairs(self.systems) do
      system:__checkEntity(e)
   end
end

function Instance:removeEntity(e)
   e.instances:remove(self)
   self.entities:remove(e)

   for _, system in ipairs(self.systems) do
      system:__remove(e)
   end
end

function Instance:addSystem(system, eventName, callback)
   if not self.namedSystems[system] then
      self.systems[#self.systems + 1] = system
      self.namedSystems[system]       = system
   end

   self.eventManager:register(eventName, system, callback)

   return self
end

function Instance:removeSystem(system, callback)
   for index, other in ipairs(self.systems) do
      if system == other then
         table.remove(self.systems, index)
      end
   end

   self.eventManager:deregister(eventName, system, callback)

   self.namedSystems[system] = nil

   return self
end

function Instance:emit(...)
   self.eventManager:emit(...)

   return self
end

return setmetatable(Instance, {
   __call = function(_, ...) return Instance.new(...) end,
})
