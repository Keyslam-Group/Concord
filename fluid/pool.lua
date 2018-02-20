local PATH = (...):gsub('%.[^%.]+$', '')

local List = require(PATH..".list")

local Pool = {}
Pool.__index = Pool

function Pool.new(name, filter)
   local pool = setmetatable(List(), Pool)

   pool.name   = name
   pool.filter = filter

   return pool
end

function Pool:eligible(e)
   for _, component in ipairs(self.filter) do
      if not e.components[component] or e.removed[component] then
         return false
      end
   end

   return true
end

return setmetatable(Pool, {
   __index = List,
   __call  = function(_, ...) return Pool.new(...) end,
})
