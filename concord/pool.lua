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
function Pool:eligible(e)
   for i=#self.__filter, 1, -1 do
      local component = self.__filter[i].__name

      if not e[component] then return false end
   end

   return true
end

-- Adds an Entity to the Pool, if it can be eligible.
-- @param e Entity to add
-- @treturn Pool self
-- @treturn boolean Whether the entity was added or not
function Pool:add(e, bypass)
   if not bypass and not self:eligible(e) then
      return self, false
   end

   List.add(self, e)
   self:onEntityAdded(e)

   return self, true
end

-- Remove an Entity from the Pool.
-- @param e Entity to remove
-- @treturn Pool self
function Pool:remove(e)
   List.remove(self, e)
   self:onEntityRemoved(e)

   return self
end

--- Evaluate whether an Entity should be added or removed from the Pool.
-- @param e Entity to add or remove
-- @treturn Pool self
function Pool:evaluate(e)
   local has  = self:has(e)
   local eligible = self:eligible(e)

   if not has and eligible then
      self:add(e, true) --Bypass the check cause we already checked
   elseif has and not eligible then
      self:remove(e)
   end

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
