local PATH = (...):gsub('%.[^%.]+$', '')

local Component = require(PATH..".component")
local Pool      = require(PATH..".pool")

local System = {}
System.mt    = {
   __index = System,
   __call  = function(systemProto, ...)
      local system = setmetatable({
         __all   = {},
         __pools = {},
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

function System.new(...)
   local systemProto = setmetatable({
      __filter = {...},
   }, System.mt)
   systemProto.__index = systemProto

   return systemProto
end

function System:init(...)
end

function System:__buildPool(pool)
   local name   = "pool"
   local filter = {}

   for i, v in ipairs(pool) do
      if type(v) == "table" then
         filter[#filter + 1] = v
      elseif type(v) == "string" then
         name = v
      end
   end

   return Pool(name, filter)
end

function System:__checkEntity(e)
   local systemHas = self:__has(e)

   for _, pool in ipairs(self.__pools) do
      local poolHas  = pool:has(e)
      local eligible = pool:eligible(e)

      if not poolHas and eligible then
         pool:add(e)
         self:entityAddedTo(e, pool)
         self:__tryAdd(e)

         return true
      elseif poolHas and not eligible then
         pool:remove(e)
         self:entityRemovedFrom(e, pool)
         self:__tryRemove(e)

         return false
      end
   end
end

function System:__tryAdd(e)
   if not self:__has(e) then
      self.__all[e] = 0
      self:entityAdded(e)
   end

   self.__all[e] = self.__all[e] + 1
end

function System:__tryRemove()
   if self:__has(e) then
      self.__all[e] = self.__all[e] - 1

      if self.__all[e] == 0 then
         self.__all[e] = nil
         self:entityRemoved(e)
      end
   end
end

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

function System:__has(e)
   return self.__all[e] and true
end

function System:entityAdded(e)
end

function System:entityAddedTo(e, pool)
end

function System:entityRemoved(e)
end

function System:entityRemovedFrom(e, pool)
end

return setmetatable(System, {
   __call = function(_, ...) return System.new(...) end,
})
