--- World

local PATH = (...):gsub('%.[^%.]+$', '')

local Worlds = require(PATH..".worlds")
local Type   = require(PATH..".type")
local List   = require(PATH..".list")

local World = {}
World.__index = World

--- Creates a new World.
-- @return The new World
function World.new(name)
   if (type(name) ~= "string") then
      error("bad argument #1 to 'World.new' (string expected, got "..type(name)..")", 2)
   end

   local world = setmetatable({
      entities = List(),
      systems  = List(),

      events   = {},

      __added   = {},
      __removed = {},

      __systemLookup = {},

      __name    = name,
      __isWorld = true,
   }, World)

   Worlds.register(name, world)

   return world
end

--- Adds an Entity to the World.
-- @param e The Entity to add
-- @return self
function World:addEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:addEntity' (Entity expected, got "..type(e)..")", 2)
   end

   if e.world then
      error("bad argument #1 to 'World:addEntity' (Entity was already added to a world)", 2)
   end

   e.world = self
   e.__wasAdded = true

   self.entities:add(e)

   return self
end

--- Removes an entity from the World.
-- @param e The Entity to mark
-- @return self
function World:removeEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:removeEntity' (Entity expected, got "..type(e)..")", 2)
   end

   e.__wasRemoved = true

   return self
end

-- @return self
function World:flush()
   local e
   for i = 1, self.entities.size do
      e = self.entities:get(i)

      if e.__wasAdded then
         e.__wasAdded = false
         e.__isDirty = false

         for j = 1, self.systems.size do
            self.systems:get(j):__evaluate(e)
         end

         self:onEntityAdded(e)
      end

      if e.__wasRemoved then
         e.world = nil
         self.entities:remove(e)

         for j = 1, self.systems.size do
            self.systems:get(j):__remove(e)
         end

         e.__wasRemoved = false
      end

      if e.__isDirty then
         for j = 1, self.systems.size do
            self.systems:get(j):__evaluate(e)
         end

         e.__isDirty = false
      end
   end

   return self
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
      system:__evaluate(self.entities:get(i))
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
      self.removeEntity(self.entities[i])
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
