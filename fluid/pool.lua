local Pool = {}
Pool.__index = Pool

function Pool.new(name, filter)
   local pool = setmetatable({
      __filter = filter,
      __name   = name,
   }, Pool)

   return pool
end

function Pool:eligible(e)
   for _, component in ipairs(self.__filter) do
      if not e.components[component] then
         return false
      end
   end

   return true
end

function Pool:add(e)
   local key = #self + 1

   self[key] = e
   e.keys[self] = key
end

function Pool:has(e)
   return e.keys[self] and true
end

function Pool:remove(e, pool)
   local key = e.keys[self]

   if key then
      local count = #self

      if key == count then
         self[key]    = nil
         e.keys[self] = nil
      else
         local swap = self[count]

         self[key]       = swap
         self[count]     = nil
         swap.keys[self] = key
      end

      return true
   end
end

return setmetatable(Pool, {
   __call = function(_, ...) return Pool.new(...) end,
})
