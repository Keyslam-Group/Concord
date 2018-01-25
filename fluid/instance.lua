local PATH = (...):gsub('%.[^%.]+$', '')

local Pool         = require(PATH..".pool")
local EventManager = require(PATH..".eventManager")

local Instance = {}
Instance.__index = Instance

function Instance.new()
   local instance = setmetatable({
      entities     = Pool(),
      eventManager = EventManager(),

      systems      = {},
      namedSystems = {},
   }, Instance)

   return instance
end

function Instance:addEntity(e)
   e.instance = self
   self.entities:add(e)
   self:checkEntity(e)
end

function Instance:checkEntity(e)
   for _, system in ipairs(self.systems) do
      if system:entityUpdated(e) then
         e.systems[#e.systems + 1] = system
      end
   end
end

function Instance:destroyEntity(e)
   self.entities:remove(e)

   for _, system in ipairs(e.systems) do
      system:remove(e)
   end
end

function Instance:addSystem(system, eventName)
   if not self.namedSystems[system] then
      self.systems[#self.systems + 1] = system
      self.namedSystems[system]       = system
   end

   self.eventManager:register(eventName, system)

   return self
end

function Instance:removeSystem(system)
   for index, other in ipairs(self.systems) do
      if system == other then
         table.remove(self.systems, index)
      end
   end

   self.namedSystems[system] = nil

   return self
end

function Instance:emit(...)
   self.eventManager:emit(...)

   return self
end

function Instance:update(dt)
   self:emit("update", dt)

   return self
end

function Instance:draw()
   self:emit("draw")

   return self
end

return setmetatable(Instance, {
   __call = function(_, ...) return Instance.new(...) end,
})
