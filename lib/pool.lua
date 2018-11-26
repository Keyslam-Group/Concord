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

   pool.added   = {}
   pool.removed = {}

   pool.name   = name
   pool.filter = filter

   pool.__isPool = true

   return pool
end

function Pool:flush()
   for i = 1, math.max(#self.added, #self.removed) do
      self.added[i], self.removed[i] = nil, nil
   end
end

--- Checks if an Entity is eligible for the Pool.
-- @param e The Entity to check
-- @return True if the entity is eligible, false otherwise
function Pool:eligible(e)
   for _, component in ipairs(self.filter) do
      if not e[component] or e.removed[component] then
         return false
      end
   end

   return true
end

return setmetatable(Pool, {
   __index = List,
   __call  = function(_, ...)
      return Pool.new(...)
   end,
})
