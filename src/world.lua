--- World

local PATH = (...):gsub('%.[^%.]+$', '')

local Type   = require(PATH..".type")
local List   = require(PATH..".list")

local World = {}
World.__index = World

--- Creates a new World.
-- @return The new World
function World.new()
   local world = setmetatable({
      entities = List(),
      systems  = List(),
      events   = {},

      marked   = {},
      removed  = {},

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

   self:onEntityAdded(e)

   e.worlds:add(self)
   self.entities:add(e)
   self:checkEntity(e)

   return self
end

--- Marks an Entity as removed from the World.
-- @param e The Entity to mark
-- @return self
function World:removeEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:removeEntity' (Entity expected, got "..type(e)..")", 2)
   end

   self.removed[#self.removed + 1] = e

   return self
end

function World:markEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:markEntity' (Entity expected, got "..type(e)..")", 2)
   end

   self.marked[#self.marked + 1] = e

   return self
end

--- Checks an Entity against all the systems in the World.
-- @param e The Entity to check
-- @return self
function World:checkEntity(e)
   if not Type.isEntity(e) then
      error("bad argument #1 to 'World:checkEntity' (Entity expected, got "..type(e)..")", 2)
   end

   for i = 1, self.systems.size do
      self.systems:get(i):__check(e)
   end

   return self
end

--- Completely removes all marked Entities in the World.
-- @return self
function World:flush()
   while #self.marked > 0 do
      local marked = self.removed
      self.removed  = {}

      for i = 1, #marked do
         local e = marked[i]

         e.Worlds:apply()
         e.Worlds:checkEntity(e)
      end
   end

   while #self.removed > 0 do
      local removed = self.removed
      self.removed  = {}

      for i = 1, #removed do
         local e = removed[i]

         e.worlds:remove(self)
         self.entities:remove(e)

         for j = 1, self.systems.size do
            self.systems:get(j):__remove(e)
         end

         self:onEntityRemoved(e)
      end
   end

   for i = 1, self.systems.size do
      local system = self.systems:get(i)
      system:flush()
      system:clear()
   end

   return self
end

--- Adds a System to the World.
-- @param system The System to add
-- @param eventName The Event to register to
-- @param callback The function name to call. Defaults to eventName
-- @param enabled If the system is enabled. Defaults to true
-- @return self
function World:addSystem(system, eventName, callback, enabled)
   if not Type.isSystem(system) then
      error("bad argument #1 to 'World:addSystem' (System expected, got "..type(system)..")", 2)
   end

   if system.__World and system.__World ~= self then
      error("System already in World '" ..tostring(system.__World).."'")
   end

   if not self.systems:has(system) then
      self.systems:add(system)
      system.__World = self

      system:addedTo(self)
   end

   if eventName then
      self.events[eventName] = self.events[eventName] or {}

      local i = #self.events[eventName] + 1
      self.events[eventName][i] = {
         system   = system,
         callback = callback or eventName,
         enabled  = enabled == nil or enabled,
      }

      if enabled == nil or enabled then
         system:enabledCallback(callback or eventName)
      end
   end

   local e
   for i = 1, self.entities.size do
      e = self.entities:get(i)

      self:checkEntity(e)
   end

   return self
end

--- Enables a System in the World.
-- @param system The System to enable
-- @param eventName The Event it was registered to
-- @param callback The callback it was registered with. Defaults to eventName
-- @return self
function World:enableSystem(system, eventName, callback)
   if not Type.isSystem(system) then
      error("bad argument #1 to 'World:enableSystem' (System expected, got "..type(system)..")", 2)
   end

   return self:setSystem(system, eventName, callback, true)
end

--- Disables a System in the World.
-- @param system The System to disable
-- @param eventName The Event it was registered to
-- @param callback The callback it was registered with. Defaults to eventName
-- @return self
function World:disableSystem(system, eventName, callback)
   if not Type.isSystem(system) then
      error("bad argument #1 to 'World:disableSystem' (System expected, got "..type(system)..")", 2)
   end

   return self:setSystem(system, eventName, callback, false)
end

--- Sets a System 'enable' in the World.
-- @param system The System to set
-- @param eventName The Event it was registered to
-- @param callback The callback it was registered with. Defaults to eventName
-- @param enable The state to set it to
-- @return self
function World:setSystem(system, eventName, callback, enable)
   if not Type.isSystem(system) then
      error("bad argument #1 to 'World:setSystem' (System expected, got "..type(system)..")", 2)
   end

   callback = callback or eventName

   if callback then
      local listeners = self.events[eventName]

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
function World:emit(eventName, ...)
   if not eventName or type(eventName) ~= "string" then
      error("bad argument #1 to 'World:emit' (String expected, got "..type(eventName)..")")
   end

   self:flush()

   local listeners = self.events[eventName]

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
      self.entities:get(i):destroy()
   end

   self:flush()

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
