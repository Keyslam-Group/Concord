local List = {}
local mt = {__index = List}

function List.new()
   return setmetatable({
      objects  = {},
      pointers = {},
      size     = 0,
   }, mt)
end

function List:clear()
   self.objects  = {}
   self.pointers = {}
   self.size     = 0
end

function List:add(obj)
   local size = self.size + 1

   self.objects[size] = obj
   self.pointers[obj] = size
   self.size          = size
end

function List:remove(obj)
   local index = self.pointers[obj]
   local size  = self.size

   if index == size then
      self.objects[size] = nil
   else
      local other = self.objects[size]

      self.objects[index]  = other
      self.pointers[other] = index

      self.objects[size] = nil
   end


   self.pointers[obj] = nil
   self.size = size - 1
end

function List:get(index)
   return self.objects[index]
end

function List:has(obj)
   return self.pointers[obj] and true
end

return setmetatable(List, {
   __call = function() return List.new() end,
})
