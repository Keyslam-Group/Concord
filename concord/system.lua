--- Iterates over Entities. From these Entities its get Components and modify them.
-- A System contains 1 or more Pools.
-- A System is contained by 1 World.
-- @classmod System

local PATH = (...):gsub('%.[^%.]+$', '')

local Pool       = require(PATH..".pool")
local Utils      = require(PATH..".utils")
local Components = require(PATH..".components")

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

      -- Optimization: We deep copy the System class into our instance of a system.
      -- This grants slightly faster access times at the cost of memory.
      -- Since there (generally) won't be many instances of worlds this is a worthwhile tradeoff
      if (System.ENABLE_OPTIMIZATION) then
         Utils.shallowCopy(systemClass, system)
      end

      for name, filter in pairs(systemClass.__filter) do
         local pool = Pool(name, filter)

         system[name] = pool
         system.__pools[#system.__pools + 1] = pool
      end

      system:init(world)

      return system
   end,
}

local validateFilters = function (baseFilters)
   local filters = {}

   for name, componentsList in pairs(baseFilters) do
      if type(name) ~= 'string' then
         error("invalid name for filter (string key expected, got "..type(name)..")", 3)
      end

      if type(componentsList) ~= 'table' then
         error("invalid component list for filter '"..name.."' (table expected, got "..type(componentsList)..")", 3)
      end

      local filter = {}
      for n, component in ipairs(componentsList) do
         local ok, componentClass = Components.try(component)

         if not ok then
            error("invalid component for filter '"..name.."' at position #"..n.." ("..componentClass..")", 3)
         end

         filter[#filter + 1] = componentClass
      end

      filters[name] = filter
   end

   return filters
end

--- Creates a new SystemClass.
-- @param table filters A table containing filters (name = {components...})
-- @treturn System A new SystemClass
function System.new(filters)
   local systemClass = setmetatable({
      __filter = validateFilters(filters),

      __name          = nil,
      __isSystemClass = true,
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

-- Internal: Evaluates an Entity for all the System's Pools.
-- @param e The Entity to check
-- @treturn System self
function System:__evaluate(e)
   for _, pool in ipairs(self.__pools) do
      pool:evaluate(e)
   end

   return self
end

-- Internal: Removes an Entity from the System.
-- @param e The Entity to remove
-- @treturn System self
function System:__remove(e)
   for _, pool in ipairs(self.__pools) do
      if pool:has(e) then
         pool:remove(e)
      end
   end

   return self
end

-- Internal: Clears all Entities from the System.
-- @treturn System self
function System:__clear()
   for i = 1, #self.__pools do
      self.__pools[i]:clear()
   end

   return self
end

--- Sets if the System is enabled
-- @tparam boolean enable
-- @treturn System self
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
-- @treturn boolean
function System:isEnabled()
   return self.__enabled
end

--- Returns the World the System is in.
-- @treturn World
function System:getWorld()
   return self.__world
end

--- Returns true if the System has a name.
-- @treturn boolean
function System:hasName()
   return self.__name and true or false
end

--- Returns the name of the System.
-- @treturn string
function System:getName()
   return self.__name
end

--- Callbacks
-- @section Callbacks

--- Callback for system initialization.
-- @tparam World world The World the System was added to
function System:init(world) -- luacheck: ignore
end

--- Callback for when a System is enabled.
function System:onEnabled() -- luacheck: ignore
end

--- Callback for when a System is disabled.
function System:onDisabled() -- luacheck: ignore
end

return setmetatable(System, {
   __call = function(_, ...)
      return System.new(...)
   end,
})
