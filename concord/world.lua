--- A collection of Systems and Entities.
-- A world emits to let Systems iterate.
-- A World contains any amount of Systems.
-- A World contains any amount of Entities.
-- @classmod World

local PATH = (...):gsub('%.[^%.]+$', '')

local Entity = require(PATH..".entity")
local Type   = require(PATH..".type")
local List   = require(PATH..".list")
local Utils  = require(PATH..".utils")

local World = {
   ENABLE_OPTIMIZATION = true,
}
World.__mt = {
   __index = World,
}

--- Creates a new World.
-- @treturn World The new World
function World.new()
   local world = setmetatable({
      __entities = List(),
      __systems  = List(),

      __events     = {},
      __emitSDepth = 0,

      __added   = List(), __backAdded   = List(),
      __removed = List(), __backRemoved = List(),
      __dirty   = List(), __backDirty   = List(),

      __systemLookup = {},

      __name    = nil,
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
-- @tparam Entity e Entity to add
-- @treturn World self
function World:addEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:addEntity' (Entity expected, got "..type(e)..")", 2)
   end

   if e.__world then
      error("bad argument #1 to 'World:addEntity' (Entity was already added to a world)", 2)
   end

   e.__world = self
   self.__added:add(e)

   return self
end

--- Removes an Entity from the World.
-- @tparam Entity e Entity to remove
-- @treturn World self
function World:removeEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:removeEntity' (Entity expected, got "..type(e)..")", 2)
   end

   self.__removed:add(e)

   return self
end

-- Internal: Marks an Entity as dirty.
-- @param e Entity to mark as dirty
function World:__dirtyEntity(e)
   if not self.__dirty:has(e) then
      self.__dirty:add(e)
   end
end

-- Internal: Flushes all changes to Entities.
-- This processes all entities. Adding and removing entities, as well as reevaluating dirty entities.
-- @treturn World self
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

      if e.__world == self then
         self.__entities:add(e)

         for j = 1, self.__systems.size do
            self.__systems[j]:__evaluate(e)
         end

         self:onEntityAdded(e)
      end
   end
   self.__backAdded:clear()

   -- Process removed entities
   for i = 1, self.__backRemoved.size do
      e = self.__backRemoved[i]

      if e.__world == self then
         e.__world = nil
         self.__entities:remove(e)

         for j = 1, self.__systems.size do
            self.__systems[j]:__remove(e)
         end

         self:onEntityRemoved(e)
      end
   end
   self.__backRemoved:clear()

   -- Process dirty entities
   for i = 1, self.__backDirty.size do
      e = self.__backDirty[i]

      if e.__world == self then
         for j = 1, self.__systems.size do
            self.__systems[j]:__evaluate(e)
         end
      end
   end
   self.__backDirty:clear()

   return self
end

-- These functions won't be seen as callbacks that will be emitted to.
local blacklistedSystemFunctions = {
   "init",
   "onEnabled",
   "onDisabled",
}

local tryAddSystem = function (world, systemClass)
   if (not Type.isSystemClass(systemClass)) then
      return false, "SystemClass expected, got "..type(systemClass)
   end

   if (world.__systemLookup[systemClass]) then
      return false, "SystemClass was already added to World"
   end

   -- Create instance of system
   local system = systemClass(world)

   world.__systemLookup[systemClass] = system
   world.__systems:add(system)

   for callbackName, callback in pairs(systemClass) do
      -- Skip callback if its blacklisted
      if (not blacklistedSystemFunctions[callbackName]) then
         -- Make container for all listeners of the callback if it does not exist yet
         if (not world.__events[callbackName]) then
            world.__events[callbackName] = {}
         end

         -- Add callback to listeners
         local listeners = world.__events[callbackName]
         listeners[#listeners + 1] = {
            system   = system,
            callback = callback,
         }
      end
   end

   -- Evaluate all existing entities
   for j = 1, world.__entities.size do
      system:__evaluate(world.__entities[j])
   end

   return true
end

--- Adds a System to the World.
-- Callbacks are registered automatically
-- Entities added before are added to the System retroactively
-- @see World:emit
-- @tparam System systemClass SystemClass of System to add
-- @treturn World self
function World:addSystem(systemClass)
   local ok, err = tryAddSystem(self, systemClass)

   if not ok then
      error("bad argument #1 to 'World:addSystem' ("..err..")", 2)
   end

   return self
end

--- Adds multiple Systems to the World.
-- Callbacks are registered automatically
-- @see World:addSystem
-- @see World:emit
-- @param ... SystemClasses of Systems to add
-- @treturn World self
function World:addSystems(...)
   for i = 1, select("#", ...) do
      local systemClass = select(i, ...)

      local ok, err = tryAddSystem(self, systemClass)
      if not ok then
         error("bad argument #"..i.." to 'World:addSystems' ("..err..")", 2)
      end
   end

   return self
end

--- Returns if the World has a System.
-- @tparam System systemClass SystemClass of System to check for
-- @treturn boolean
function World:hasSystem(systemClass)
   if not Type.isSystemClass(systemClass) then
      error("bad argument #1 to 'World:getSystem' (systemClass expected, got "..type(systemClass)..")", 2)
   end

   return self.__systemLookup[systemClass] and true or false
end

--- Gets a System from the World.
-- @tparam System systemClass SystemClass of System to get
-- @treturn System System to get
function World:getSystem(systemClass)
   if not Type.isSystemClass(systemClass) then
      error("bad argument #1 to 'World:getSystem' (systemClass expected, got "..type(systemClass)..")", 2)
   end

   return self.__systemLookup[systemClass]
end

--- Emits a callback in the World.
-- Calls all functions with the functionName of added Systems
-- @string functionName Name of functions to call.
-- @param ... Parameters passed to System's functions
-- @treturn World self
function World:emit(functionName, ...)
   if not functionName or type(functionName) ~= "string" then
      error("bad argument #1 to 'World:emit' (String expected, got "..type(functionName)..")")
   end

   local shouldFlush = self.__emitSDepth == 0

   self.__emitSDepth = self.__emitSDepth + 1

	local listeners = self.__events[functionName]

   if listeners then
      for i = 1, #listeners do
         local listener = listeners[i]

         if (listener.system.__enabled) then
            if (shouldFlush) then
               self:__flush()
            end

            listener.callback(listener.system, ...)
         end
      end
   end

   self.__emitSDepth = self.__emitSDepth - 1

   return self
end

--- Removes all entities from the World
-- @treturn World self
function World:clear()
   for i = 1, self.__entities.size do
      self:removeEntity(self.__entities[i])
   end

   for i = 1, self.__added.size do
      local e = self.__added[i]
      e.__world = nil
   end
   self.__added:clear()

   self:__flush()

   return self
end

function World:getEntities()
   return self.__entities
end

function World:getSystems()
   return self.__systems
end

function World:serialize()
   self:__flush()

   local data = {}

   for i = 1, self.__entities.size do
      local entity = self.__entities[i]

      local entityData = entity:serialize()

      data[i] = entityData
   end

   return data
end

function World:deserialize(data, append)
   if (not append) then
      self:clear()
   end

   for i = 1, #data do
      local entityData = data[i]

      local entity = Entity()
      entity:deserialize(entityData)

      self:addEntity(entity)
   end

   self:__flush()
end

--- Returns true if the World has a name.
-- @treturn boolean
function World:hasName()
   return self.__name and true or false
end

--- Returns the name of the World.
-- @treturn string
function World:getName()
   return self.__name
end

--- Callback for when an Entity is added to the World.
-- @tparam Entity e The Entity that was added
function World:onEntityAdded(e) -- luacheck: ignore
end

--- Callback for when an Entity is removed from the World.
-- @tparam Entity e The Entity that was removed
function World:onEntityRemoved(e) -- luacheck: ignore
end

return setmetatable(World, {
   __call = function(_, ...)
      return World.new(...)
   end,
})
