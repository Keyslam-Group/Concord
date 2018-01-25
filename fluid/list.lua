local List = {}
local mt = {__index = List}

function List.new()
   return setmetatable({
      numerical = {},
      named     = {},
      size      = 0,
   }, mt)
end

function List:clear()
   self.numerical = {}
   self.named     = {}
   self.size      = 0
end

function List:add(obj)
   local size = self.size + 1

   self.numerical[size] = obj
   self.named[obj]      = size
   self.size            = size
end

function List:remove(obj)
   local index = self.named[obj]
   local size  = self.size

   if index == size then
      self.numerical[size] = nil
   else
      local other = self.numerical[size]

      self.numerical[index] = other
      self.named[other]     = index
   end

   self.named[obj] = nil
   self.size = size - 1
end

function List:get(i)
   return self.numerical[i]
end

function List:getIndex(obj)
   return self.named[obj]
end

return setmetatable(List, {
   __call = function() return List.new() end,
})
