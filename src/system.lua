--- System

local PATH = (...):gsub('%.[^%.]+$', '')

local Pool    = require(PATH..".pool")

local System = {}
System.mt    = {
   __index = System,
   __call  = function(baseSystem, world)
      local system = setmetatable({
         __enabled = true,

         __pools = {},
         __world = world,

         __isSystem = true,
         __isBaseSystem = false, -- Overwrite value from baseSystem
      }, baseSystem)

      for _, filter in pairs(baseSystem.__filter) do
         local pool = system:__buildPool(filter)
         if not system[pool.name] then
            system[pool.name]                   = pool
            system.__pools[#system.__pools + 1] = pool
         else
            error("Pool with name '"..pool.name.."' already exists.")
         end
      end

      system:init(world)

      return system
   end,
}

--- Creates a new System prototype.
-- @param ... Variable amounts of filters
-- @return A new System prototype
function System.new(...)
   local baseSystem = setmetatable({
      __isBaseSystem = true,
      __filter = {...},
   }, System.mt)
   baseSystem.__index = baseSystem

   return baseSystem
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
function System:__evaluate(e)
   for _, pool in ipairs(self.__pools) do
      local has  = pool:has(e)
      local eligible = pool:eligible(e)

      if not has and eligible then
         pool:add(e)
      elseif has and not eligible then
         pool:remove(e)
      end
   end
end

--- Remove an Entity from the System.
-- @param e The Entity to remove
function System:__remove(e)
   for _, pool in ipairs(self.__pools) do
      if pool:has(e) then
         pool:remove(e)
      end
   end
end

function System:clear()
   for i = 1, #self.__pools do
      self.__pools[i]:clear()
   end
end

function System:enable()
   self:setEnabled(true)
end

function System:disable()
   self:setEnabled(false)
end

function System:toggleEnable()
   self:setEnabled(not self.__enabled)
end

function System:setEnabled(enable)
   if (not self.__enabled and enable) then
      self.__enabled = true
      self:onEnabledCallback()
   elseif (self.__enabled and not enable) then
      self.__enabled = false
      self:onDisabledCallback()
   end
end

function System:isEnabled()
   return self.__enabled
end

--- Returns the World the System is in.
-- @return The world the system is in
function System:getWorld()
   return self.__world
end

--- Default callback for system initialization.
-- @param world The World the System was added to
function System:init(world) -- luacheck: ignore
end

-- Default callback for when a System's callback is enabled.
-- @param callbackName The name of the callback that was enabled
function System:onEnabledCallback(callbackName) -- luacheck: ignore
end

-- Default callback for when a System's callback is disabled.
-- @param callbackName The name of the callback that was disabled
function System:onDisabledCallback(callbackName) -- luacheck: ignore
end

return setmetatable(System, {
   __call = function(_, ...)
      return System.new(...)
   end,
})