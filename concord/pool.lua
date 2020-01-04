--- Used to iterate over Entities with a specific Components
-- A Pool contain a any amount of Entities.
-- @classmod Pool

local PATH = (...):gsub('%.[^%.]+$', '')

local List = require(PATH..".list")

local Pool = {}
Pool.__mt = {
   __index = Pool,
}

--- Creates a new Pool
-- @string name Name for the Pool.
-- @tparam table filter Table containing the required BaseComponents
-- @treturn Pool The new Pool
function Pool.new(name, filter)
   local pool = setmetatable(List(), Pool.__mt)

   pool.__name   = name
   pool.__filter = filter

   pool.__isPool = true

   return pool
end

--- Checks if an Entity is eligible for the Pool.
-- @tparam Entity e Entity to check
-- @treturn boolean
function Pool:__eligible(e)
   for _, component in ipairs(self.__filter) do
      if not e[component] then
         return false
      end
   end

   return true
end

-- Internal: Adds an Entity to the Pool.
-- @param e Entity to add
-- @treturn Pool self
function Pool:__add(e)
   List.__add(self, e)
   self:onEntityAdded(e)

   return self
end

-- Internal: Removed an Entity from the Pool.
-- @param e Entity to remove
-- @treturn Pool self
function Pool:__remove(e)
   List.__remove(self, e)
   self:onEntityRemoved(e)

   return self
end

--- Gets the name of the Pool
-- @treturn string
function Pool:getName()
   return self.__name
end

--- Gets the filter of the Pool.
-- Warning: Do not modify this filter.
-- @return Filter of the Pool.
function Pool:getFilter()
   return self.__filter
end

--- Callback for when an Entity is added to the Pool.
-- @tparam Entity e Entity that was added.
function Pool:onEntityAdded(e) -- luacheck: ignore
end

-- Callback for when an Entity is removed from the Pool.
-- @tparam Entity e Entity that was removed.
function Pool:onEntityRemoved(e)  -- luacheck: ignore
end

return setmetatable(Pool, {
   __index = List,
   __call  = function(_, ...)
      return Pool.new(...)
   end,
})
