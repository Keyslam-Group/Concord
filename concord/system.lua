--- System
-- A System iterates over Entities. From these Entities its get Components and modify them.
-- A System contains 1 or more Pools.
-- A System is contained by 1 World.

local PATH = (...):gsub('%.[^%.]+$', '')

local Pool  = require(PATH..".pool")
local Utils = require(PATH..".utils")

local System = {
   ENABLE_OPTIMIZATION = true,
}

System.mt = {
   __index = System,
   __call  = function(systemClass, world)
      local system = setmetatable({
         __enabled = true,

         __pools = {},
         __world = world,

         __isSystem = true,
         __isSystemClass = false, -- Overwrite value from systemClass
      }, systemClass)

      -- Optimization: We deep copy the World class into our instance of a world.
      -- This grants slightly faster access times at the cost of memory.
      -- Since there (generally) won't be many instances of worlds this is a worthwhile tradeoff
      if (System.ENABLE_OPTIMIZATION) then
         Utils.shallowCopy(systemClass, system)
      end

      for _, filter in pairs(systemClass.__filter) do
         local pool = system.__buildPool(filter)
         if not system[pool.__name] then
            system[pool.__name]                 = pool
            system.__pools[#system.__pools + 1] = pool
         else
            error("Pool with name '"..pool.name.."' already exists.")
         end
      end

      system:init(world)

      return system
   end,
}

--- Creates a new SystemClass.
-- @param ... Variable amounts of filters
-- @return A new SystemClass
function System.new(...)
   local systemClass = setmetatable({
      __isSystemClass = true,
      __filter = {...},
   }, System.mt)
   systemClass.__index = systemClass

   -- Optimization: We deep copy the World class into our instance of a world.
   -- This grants slightly faster access times at the cost of memory.
   -- Since there (generally) won't be many instances of worlds this is a worthwhile tradeoff
   if (System.ENABLE_OPTIMIZATION) then
      Utils.shallowCopy(System, systemClass)
   end

   return systemClass
end

--- Internal: Builds a Pool for the System.
-- @param baseFilter The 'raw' Filter
-- @return A new Pool
function System.__buildPool(baseFilter)
   local name   = "pool"
   local filter = {}

   for _, value in ipairs(baseFilter) do
      if type(value) == "table" then
         filter[#filter + 1] = value
      elseif type(value) == "string" then
         name = value
      end
   end

   return Pool(name, filter)
end

--- Internal: Evaluates an Entity for all the System's Pools.
-- @param e The Entity to check
-- @return self
function System:__evaluate(e)
   for _, pool in ipairs(self.__pools) do
      local has  = pool:has(e)
      local eligible = pool:__eligible(e)

      if not has and eligible then
         pool:__add(e)
      elseif has and not eligible then
         pool:__remove(e)
      end
   end

   return self
end

--- Internal: Removes an Entity from the System.
-- @param e The Entity to remove
-- @return self
function System:__remove(e)
   for _, pool in ipairs(self.__pools) do
      if pool:has(e) then
         pool:__remove(e)
      end
   end

   return self
end

--- Internal: Clears all Entities from the System.
-- @return self
function System:clear()
   for i = 1, #self.__pools do
      self.__pools[i]:__clear()
   end

   return self
end

--- Enables the System.
-- @return self
function System:enable()
   self:setEnabled(true)

   return self
end

--- Disables the System.
-- @return self
function System:disable()
   self:setEnabled(false)

   return self
end

--- Toggles if the System is enabled.
-- @return self
function System:toggleEnable()
   self:setEnabled(not self.__enabled)

   return self
end

--- Sets if the System is enabled
-- @param enable Enable
-- @return self
function System:setEnabled(enable)
   if (not self.__enabled and enable) then
      self.__enabled = true
      self:onEnabled()
   elseif (self.__enabled and not enable) then
      self.__enabled = false
      self:onDisabled()
   end

   return self
end

--- Returns is the System is enabled
-- @return True if the System is enabled, false otherwise
function System:isEnabled()
   return self.__enabled
end

--- Returns the World the System is in.
-- @return The World the System is in
function System:getWorld()
   return self.__world
end

--- Callback for system initialization.
-- @param world The World the System was added to
function System:init(world) -- luacheck: ignore
end

-- Callback for when a System is enabled.
function System:onEnabled() -- luacheck: ignore
end

-- Callback for when a System is disabled.
function System:onDisabled() -- luacheck: ignore
end

return setmetatable(System, {
   __call = function(_, ...)
      return System.new(...)
   end,
})