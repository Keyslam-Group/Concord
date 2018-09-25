--- System

local PATH = (...):gsub('%.[^%.]+$', '')

local Component = require(PATH..".component")
local Pool      = require(PATH..".pool")

local System = {}
System.mt    = {
   __index = System,
   __call  = function(systemProto, ...)
      local system = setmetatable({
         __all      = {},
         __pools    = {},
         __instance = nil,

         __isSystem = true,
      }, systemProto)

      for _, filter in pairs(systemProto.__filter) do
         local pool = system:__buildPool(filter)
         if not system[pool.name] then
            system[pool.name]                   = pool
            system.__pools[#system.__pools + 1] = pool
         else
            error("Pool with name '"..pool.name.."' already exists.")
         end
      end

      system:init(...)
      return system
   end,
}

--- Creates a new System prototype.
-- @param ... Variable amounts of filters
-- @return A new System prototype
function System.new(...)
   local systemProto = setmetatable({
      __filter = {...},
   }, System.mt)
   systemProto.__index = systemProto

   return systemProto
end

--- Builds a Pool for the System.
-- @param baseFilter The 'raw' Filter
-- @return A new Pool
function System:__buildPool(baseFilter)
   local name   = "pool"
   local filter = {}

   for i, v in ipairs(baseFilter) do
      if type(v) == "table" then
         filter[#filter + 1] = v
      elseif type(v) == "string" then
         name = v
      end
   end

   return Pool(name, filter)
end

--- Checks and applies an Entity to the System's pools.
-- @param e The Entity to check
-- @return True if the Entity was added, false if it was removed. Nil if nothing happend
function System:__check(e)
   local systemHas = self:__has(e)

   for _, pool in ipairs(self.__pools) do
      local poolHas  = pool:has(e)
      local eligible = pool:eligible(e)

      if not poolHas and eligible then
         pool:add(e)
         self:entityAddedTo(e, pool)
         self:__tryAdd(e)
      elseif poolHas and not eligible then
         pool:remove(e)
         self:entityRemovedFrom(e, pool)
         self:__tryRemove(e)
      end
   end
end

--- Removed an Entity from the System.
-- @param e The Entity to remove
function System:__remove(e)
   if self:__has(e) then
      for _, pool in ipairs(self.__pools) do
         if pool:has(e) then
            pool:remove(e)
            self:entityRemovedFrom(e, pool)
         end
      end

      self.__all[e] = nil
      self:entityRemoved(e)
   end
end

--- Tries to add an Entity to the System.
-- @param e The Entity to add
function System:__tryAdd(e)
   if not self:__has(e) then
      self.__all[e] = 0
      self:entityAdded(e)
   end

   self.__all[e] = self.__all[e] + 1
end

--- Tries to remove an Entity from the System.
-- @param e The Entity to remove
function System:__tryRemove(e)
   if self:__has(e) then
      self.__all[e] = self.__all[e] - 1

      if self.__all[e] == 0 then
         self.__all[e] = nil
         self:entityRemoved(e)
      end
   end
end

--- Returns the Instance the System is in.
-- @return The Instance
function System:getInstance()
   return self.__instance
end

--- Returns if the System has the Entity.
-- @param e The Entity to check for
-- @return True if the System has the Entity. False otherwise
function System:__has(e)
   return self.__all[e] and true
end

--- Default callback for system initialization.
-- @param ... Varags
function System:init(...)
end

--- Default callback for adding an Entity.
-- @param e The Entity that was added
function System:entityAdded(e)
end

--- Default callback for adding an Entity to a pool.
-- @param e The Entity that was added
-- @param pool The pool the Entity was added to
function System:entityAddedTo(e, pool)
end

--- Default callback for removing an Entity.
-- @param e The Entity that was removed
function System:entityRemoved(e)
end

--- Default callback for removing an Entity from a pool.
-- @param e The Entity that was removed
-- @param pool The pool the Entity was removed from
function System:entityRemovedFrom(e, pool)
end

-- Default callback for when the System is added to an Instance.
-- @param instance The Instance the System was added to
function System:addedTo(instance)
end

-- Default callback for when a System's callback is enabled.
-- @param callbackName The name of the callback that was enabled 
function System:enabledCallback(callbackName)
end

-- Default callback for when a System's callback is disabled.
-- @param callbackName The name of the callback that was disabled 
function System:disabledCallback(callbackName)
end

return setmetatable(System, {
   __call = function(_, ...) return System.new(...) end,
})
