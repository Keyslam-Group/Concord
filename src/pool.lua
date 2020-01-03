--- Pool

local PATH = (...):gsub('%.[^%.]+$', '')

local List = require(PATH..".list")

local Pool = {}
Pool.__mt = {
   __index = Pool,
}

--- Creates a new Pool
-- @param name Identifier for the Pool.
-- @param filter Table containing the required Components
-- @return The new Pool
function Pool.new(name, filter)
   local pool = setmetatable(List(), Pool.__mt)

   pool.__name   = name
   pool.__filter = filter

   pool.__isPool = true

   return pool
end

--- Checks if an Entity is eligible for the Pool.
-- @param e The Entity to check
-- @return True if the entity is eligible, false otherwise
function Pool:__eligible(e)
   for _, component in ipairs(self.__filter) do
      if not e[component] then
         return false
      end
   end

   return true
end

function Pool:__add(e)
   List.__add(self, e)
   self:onEntityAdded(e)
end

function Pool:__remove(e)
   List.__remove(self, e)
   self:onEntityRemoved(e)
end

function Pool:getName()
   return self.__name
end

function Pool:getFilter()
   return self.__filter
end

function Pool:onEntityAdded(e) -- luacheck: ignore
end

function Pool:onEntityRemoved(e)  -- luacheck: ignore
end

return setmetatable(Pool, {
   __index = List,
   __call  = function(_, ...)
      return Pool.new(...)
   end,
})
