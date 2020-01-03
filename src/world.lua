--- World

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")
local List = require(PATH..".list")

local World = {}
World.__index = World

--- Creates a new World.
-- @return The new World
function World.new()
   local world = setmetatable({
      entities = List(),
      systems  = List(),

      events   = {},

      __added   = List(), __backAdded   = List(),
      __removed = List(), __backRemoved = List(),
      __dirty   = List(), __backDirty   = List(),

      __systemLookup = {},

      __isWorld = true,
   }, World)

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
   self.__added:add(e)

   return self
end

--- Removes an entity from the World.
-- @param e The Entity to mark
-- @return self
function World:removeEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:removeEntity' (Entity expected, got "..type(e)..")", 2)
   end

   self.__removed:add(e)

   return self
end

function World:__dirtyEntity(e)
   if not self.__dirty:has(e) then
      self.__dirty:add(e)
   end
end


-- @return self
function World:__flush()
   -- Switch buffers
   self.__added,   self.__backAdded   = self.__backAdded,   self.__added
   self.__removed, self.__backRemoved = self.__backRemoved, self.__removed
   self.__dirty,   self.__backDirty   = self.__backDirty,   self.__dirty

   local e

   -- Added
   for i = 1, self.__backAdded.size do
      e = self.__backAdded[i]

      self.entities:add(e)

      for j = 1, self.systems.size do
         self.systems[j]:__evaluate(e)
      end

      self:onEntityAdded(e)
   end
   self.__backAdded:clear()

   -- Removed
   for i = 1, self.__backRemoved.size do
      e = self.__backRemoved[i]

      e.__world = nil
      self.entities:remove(e)

      for j = 1, self.systems.size do
         self.systems[j]:__remove(e)
      end

      self:onEntityRemoved(e)
   end
   self.__backRemoved:clear()

   -- Dirty
   for i = 1, self.__backDirty.size do
      e = self.__backDirty[i]

      for j = 1, self.systems.size do
         self.systems[j]:__evaluate(e)
      end
   end
   self.__backDirty:clear()

   return self
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

--- Adds a System to the World.
-- @param baseSystem The BaseSystem of the system to add
-- @param callbackName The callbackName to register to
-- @param callback The function name to call. Defaults to callbackName
-- @param enabled If the system is enabled. Defaults to true
-- @return self
function World:addSystem(baseSystem, callbackName, callback, enabled)
   if not Type.isBaseSystem(baseSystem) then
      error("bad argument #1 to 'World:addSystem' (baseSystem expected, got "..type(baseSystem)..")", 2)
   end

   local system = self.__systemLookup[baseSystem]
   if (not system) then
      -- System was not created for this world yet, so we create it ourselves
      system = baseSystem(self)

      self.__systemLookup[baseSystem] = system

      self.systems:add(system)
   end

   -- Retroactively evaluate all entities for this system
   for i = 1, self.entities.size do
      system:__evaluate(self.entities[i])
   end

   if callbackName then
      self.events[callbackName] = self.events[callbackName] or {}

      local i = #self.events[callbackName] + 1
      self.events[callbackName][i] = {
         system   = system,
         callback = callback or callbackName,
         enabled  = enabled == nil or enabled,
      }

      if enabled == nil or enabled then
         system:enabledCallback(callback or callbackName)
      end
   end

   return self
end

--- Enables a System in the World.
-- @param system The System to enable
-- @param callbackName The Event it was registered to
-- @param callback The callback it was registered with. Defaults to eventName
-- @return self
function World:enableSystem(system, callbackName, callback)
   if not Type.isSystem(system) then
      error("bad argument #1 to 'World:enableSystem' (System expected, got "..type(system)..")", 2)
   end

   return self:setSystem(system, callbackName, callback, true)
end

--- Disables a System in the World.
-- @param system The System to disable
-- @param eventName The Event it was registered to
-- @param callback The callback it was registered with. Defaults to eventName
-- @return self
function World:disableSystem(system, callbackName, callback)
   if not Type.isSystem(system) then
      error("bad argument #1 to 'World:disableSystem' (System expected, got "..type(system)..")", 2)
   end

   return self:setSystem(system, callbackName, callback, false)
end

--- Sets a System 'enable' in the World.
-- @param system The System to set
-- @param eventName The Event it was registered to
-- @param callback The callback it was registered with. Defaults to eventName
-- @param enable The state to set it to
-- @return self
function World:setSystem(system, callbackName, callback, enable)
   if not Type.isSystem(system) then
      error("bad argument #1 to 'World:setSystem' (System expected, got "..type(system)..")", 2)
   end

   callback = callback or callbackName

   if callback then
      local listeners = self.events[callbackName]

      if listeners then
         for i = 1, #listeners do
            local listener = listeners[i]

            if listener.system == system and listener.callback == callback then
               if enable and not listener.enabled then
                  system:enabledCallback(callback)
               elseif not enable and listener.enabled then
                  system:disabledCallback(callback)
               end

               listener.enabled = enable

               break
            end
         end
      end
   end

   return self
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

         if listener.enabled then
            self:__flush()

            listener.system[listener.callback](listener.system, ...)
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
