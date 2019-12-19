--- Pool

local PATH = (...):gsub('%.[^%.]+$', '')

local List = require(PATH..".list")

local Pool = {}
Pool.__index = Pool

--- Creates a new Pool
-- @param name Identifier for the Pool.
-- @param filter Table containing the required Components
-- @return The new Pool
function Pool.new(name, filter)
   local pool = setmetatable(List(), Pool)

   pool.name   = name
   pool.filter = filter

   pool.__isPool = true

   return pool
end

--- Checks if an Entity is eligible for the Pool.
-- @param e The Entity to check
-- @return True if the entity is eligible, false otherwise
function Pool:eligible(e)
   for _, component in ipairs(self.filter) do
      if not e[component] then
         return false
      end
   end

   return true
end

function Pool:add(e)
   List.add(self, e)
   self:onEntityAdded(e)
end

function Pool:remove(e)
   List.remove(self, e)
   self:onEntityRemoved(e)
end

function Pool:onEntityAdded(e)
end

function Pool:onEntityRemoved(e)
end

return setmetatable(Pool, {
   __index = List,
   __call  = function(_, ...)
      return Pool.new(...)
   end,
})
