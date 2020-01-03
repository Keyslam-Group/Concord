--- World

local PATH = (...):gsub('%.[^%.]+$', '')

local Type  = require(PATH..".type")
local List  = require(PATH..".list")
local Utils = require(PATH..".utils")

local World = {
   ENABLE_OPTIMIZATION = true,
}
World.__mt = {
   __index = World,
}

--- Creates a new World.
-- @return The new World
function World.new()
   local world = setmetatable({
      entities = List(),
      systems  = List(),

      events = {},

      __added   = List(), __backAdded   = List(),
      __removed = List(), __backRemoved = List(),
      __dirty   = List(), __backDirty   = List(),

      __systemLookup = {},

      __isWorld = true,
   }, World.__mt)

   -- Optimization: We deep copy the World class into our instance of a world.
   -- This grants slightly faster access times at the cost of memory.
   -- Since there (generally) won't be many instances of worlds this is a worthwhile tradeoff
   if (World.ENABLE_OPTIMIZATION) then
      Utils.shallowCopy(World, world)
   end

   return world
end

--- Adds an Entity to the World.
-- @param e The Entity to add
-- @return self
function World:addEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:addEntity' (Entity expected, got "..type(e)..")", 2)
   end

   if e.__world then
      error("bad argument #1 to 'World:addEntity' (Entity was already added to a world)", 2)
   end

   e.__world = self
   self.__added:__add(e)

   return self
end

--- Removes an entity from the World.
-- @param e The Entity to mark
-- @return self
function World:removeEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:removeEntity' (Entity expected, got "..type(e)..")", 2)
   end

   self.__removed:__add(e)

   return self
end

function World:__dirtyEntity(e)
   if not self.__dirty:has(e) then
      self.__dirty:__add(e)
   end
end


-- @return self
function World:__flush()
   -- Early out
   if (self.__added.size == 0 and self.__removed.size == 0 and self.__dirty.size == 0) then
      return self
   end

   -- Switch buffers
   self.__added,   self.__backAdded   = self.__backAdded,   self.__added
   self.__removed, self.__backRemoved = self.__backRemoved, self.__removed
   self.__dirty,   self.__backDirty   = self.__backDirty,   self.__dirty

   local e

   -- Process added entities
   for i = 1, self.__backAdded.size do
      e = self.__backAdded[i]

      self.entities:__add(e)

      for j = 1, self.systems.size do
         self.systems[j]:__evaluate(e)
      end

      self:onEntityAdded(e)
   end
   self.__backAdded:__clear()

   -- Process removed entities
   for i = 1, self.__backRemoved.size do
      e = self.__backRemoved[i]

      e.__world = nil
      self.entities:__remove(e)

      for j = 1, self.systems.size do
         self.systems[j]:__remove(e)
      end

      self:onEntityRemoved(e)
   end
   self.__backRemoved:__clear()

   -- Process dirty entities
   for i = 1, self.__backDirty.size do
      e = self.__backDirty[i]

      for j = 1, self.systems.size do
         self.systems[j]:__evaluate(e)
      end
   end
   self.__backDirty:__clear()

   return self
end

local blacklistedSystemMethods = {
   "init",
}

function World:addSystem(baseSystem)
   if (not Type.isBaseSystem(baseSystem)) then
      error("bad argument #1 to 'World:addSystems' (baseSystem expected, got "..type(baseSystem)..")", 2)
   end

   -- TODO: Check if baseSystem was already added

   -- Create instance of system
   local system = baseSystem(self)

   self.__systemLookup[baseSystem] = system
   self.systems:__add(system)

   for callbackName, callback in pairs(baseSystem) do
      -- Skip callback if its blacklisted
      if (not blacklistedSystemMethods[callbackName]) then
         -- Make container for all listeners of the callback if it does not exist yet
         if (not self.events[callbackName]) then
            self.events[callbackName] = {}
         end

         -- Add callback to listeners
         local listeners = self.events[callbackName]
         listeners[#listeners + 1] = {
            system   = system,
            callback = callback,
         }
      end
   end

   -- Evaluate all existing entities
   for j = 1, self.entities.size do
      system:__evaluate(self.entities[j])
   end
end

function World:addSystems(...)
   for i = 1, select("#", ...) do
      local baseSystem = select(i, ...)

      self:addSystem(baseSystem)
   end
end


function World:hasSystem(baseSystem)
   if not Type.isBaseSystem(baseSystem) then
      error("bad argument #1 to 'World:getSystem' (baseSystem expected, got "..type(baseSystem)..")", 2)
   end

   return self.__systemLookup[baseSystem] and true or false
end

function World:getSystem(baseSystem)
   if not Type.isBaseSystem(baseSystem) then
      error("bad argument #1 to 'World:getSystem' (baseSystem expected, got "..type(baseSystem)..")", 2)
   end

   return self.__systemLookup[baseSystem]
end

--- Emits an Event in the World.
-- @param eventName The Event that should be emitted
-- @param ... Parameters passed to listeners
-- @return self
function World:emit(callbackName, ...)
   if not callbackName or type(callbackName) ~= "string" then
      error("bad argument #1 to 'World:emit' (String expected, got "..type(callbackName)..")")
   end

   local listeners = self.events[callbackName]

   if listeners then
      for i = 1, #listeners do
         local listener = listeners[i]

         if (listener.system.__enabled) then
            self:__flush()

            listener.callback(listener.system, ...)
         end
      end
   end

   return self
end

--- Removes all entities from the World
-- @return self
function World:clear()
   for i = 1, self.entities.size do
      self:removeEntity(self.entities[i])
   end

   return self
end

--- Default callback for adding an Entity.
-- @param e The Entity that was added
function World:onEntityAdded(e) -- luacheck: ignore
end

--- Default callback for removing an Entity.
-- @param e The Entity that was removed
function World:onEntityRemoved(e) -- luacheck: ignore
end

return setmetatable(World, {
   __call = function(_, ...)
      return World.new(...)
   end,
})
