--- World
-- A World is a collection of Systems and Entities
-- A world emits to let Systems iterate
-- A World contains any amount of Systems
-- A World contains any amount of Entities

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
-- @param e Entity to add
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

--- Removes an Entity from the World.
-- @param e Entity to remove
-- @return self
function World:removeEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:removeEntity' (Entity expected, got "..type(e)..")", 2)
   end

   self.__removed:__add(e)

   return self
end

--- Internal: Marks an Entity as dirty.
-- @param e Entity to mark as dirty
function World:__dirtyEntity(e)
   if not self.__dirty:has(e) then
      self.__dirty:__add(e)
   end
end

--- Internal: Flushes all changes to Entities.
-- This processes all entities. Adding and removing entities, as well as reevaluating dirty entities.
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

-- These functions won't be seen as callbacks that will be emitted to.
local blacklistedSystemFunctions = {
   "init",
   "onEnabled",
   "onDisabled",
}

--- Adds a System to the World.
-- Callbacks are registered automatically
-- Entities added before are added to the System retroactively
-- @see World:emit
-- @param systemClass SystemClass of System to add
-- @return self
function World:addSystem(systemClass)
   if (not Type.isSystemClass(systemClass)) then
      error("bad argument #1 to 'World:addSystems' (SystemClass expected, got "..type(systemClass)..")", 2)
   end

   if (self.__systemLookup[systemClass]) then
      error("bad argument #1 to 'World:addSystems' (SystemClass was already added to World)", 2)
   end

   -- Create instance of system
   local system = systemClass(self)

   self.__systemLookup[systemClass] = system
   self.systems:__add(system)

   for callbackName, callback in pairs(systemClass) do
      -- Skip callback if its blacklisted
      if (not blacklistedSystemFunctions[callbackName]) then
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

   return self
end

--- Adds multiple Systems to the World.
-- Callbacks are registered automatically
-- @see World:addSystem
-- @see World:emit
-- @param ... SystemClasses of Systems to add
-- @return self
function World:addSystems(...)
   for i = 1, select("#", ...) do
      local systemClass = select(i, ...)

      self:addSystem(systemClass)
   end

   return self
end

--- Returns if the World has a System.
-- @param systemClass SystemClass of System to check for
-- @return True if World has System, false otherwise
function World:hasSystem(systemClass)
   if not Type.isSystemClass(systemClass) then
      error("bad argument #1 to 'World:getSystem' (systemClass expected, got "..type(systemClass)..")", 2)
   end

   return self.__systemLookup[systemClass] and true or false
end

--- Gets a System from the World.
-- @param systemClass SystemClass of System to get
-- @return System to get
function World:getSystem(systemClass)
   if not Type.isSystemClass(systemClass) then
      error("bad argument #1 to 'World:getSystem' (systemClass expected, got "..type(systemClass)..")", 2)
   end

   return self.__systemLookup[systemClass]
end

--- Emits a callback in the World.
-- Calls all functions with the functionName of added Systems
-- @param functionName Name of functions to call.
-- @param ... Parameters passed to System's functions
-- @return self
function World:emit(functionName, ...)
   if not functionName or type(functionName) ~= "string" then
      error("bad argument #1 to 'World:emit' (String expected, got "..type(functionName)..")")
   end

	local listeners = self.events[functionName]

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

   for i = 1, self.systems.size do
      self.systems[i]:__clear()
   end

   return self
end

--- Callback for when an Entity is added to the World.
-- @param e The Entity that was added
function World:onEntityAdded(e) -- luacheck: ignore
end

--- Callback for when an Entity is removed from the World.
-- @param e The Entity that was removed
function World:onEntityRemoved(e) -- luacheck: ignore
end

return setmetatable(World, {
   __call = function(_, ...)
      return World.new(...)
   end,
})
