--- System

local PATH = (...):gsub('%.[^%.]+$', '')

local Pool = require(PATH..".pool")

local System = {}
System.mt    = {
   __index = System,
   __call  = function(systemProto, ...)
      local system = setmetatable({
         __all   = {},
         __pools = {},
         __world = nil,

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
function System:__buildPool(baseFilter) -- luacheck: ignore
   local name   = "pool"
   local filter = {}

   for _, v in ipairs(baseFilter) do
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
   for _, pool in ipairs(self.__pools) do
      local poolHas  = pool:has(e)
      local eligible = pool:eligible(e)

      if not poolHas and eligible then
         pool:add(e)
         pool.added[#pool.added + 1] = e

         self:__tryAdd(e)
      elseif poolHas and not eligible then
         pool:remove(e)
         pool.removed[#pool.removed + 1] = e

         self:__tryRemove(e)
      end
   end
end

--- Remove an Entity from the System.
-- @param e The Entity to remove
function System:__remove(e)
   if self.__all[e] then
      for _, pool in ipairs(self.__pools) do
         if pool:has(e) then
            pool:remove(e)
            pool.removed[#pool.removed + 1] = e
         end
      end

      self.__all[e] = nil
   end
end

--- Tries to add an Entity to the System.
-- @param e The Entity to add
function System:__tryAdd(e)
   if not self.__all[e] then
      self.__all[e] = 0
   end

   self.__all[e] = self.__all[e] + 1
end

--- Tries to remove an Entity from the System.
-- @param e The Entity to remove
function System:__tryRemove(e)
   if self.__all[e] then
      self.__all[e] = self.__all[e] - 1

      if self.__all[e] == 0 then
         self.__all[e] = nil
      end
   end
end

function System:flush() -- luacheck: ignore
end

function System:clear()
   for i = 1, #self.__pools do
      self.__pools[i]:flush()
   end
end

--- Returns the World the System is in.
-- @return The world the system is in
function System:getWorld()
   return self.__world
end

--- Default callback for system initialization.
-- @param ... Varags
function System:init(...) -- luacheck: ignore
end

-- Default callback for when the System is added to an World.
-- @param world The World the System was added to
function System:addedTo(World) -- luacheck: ignore
end

-- Default callback for when a System's callback is enabled.
-- @param callbackName The name of the callback that was enabled
function System:enabledCallback(callbackName) -- luacheck: ignore
end

-- Default callback for when a System's callback is disabled.
-- @param callbackName The name of the callback that was disabled
function System:disabledCallback(callbackName) -- luacheck: ignore
end

return setmetatable(System, {
   __call = function(_, ...)
      return System.new(...)
   end,
})
