--- List

local List = {}
local mt = {__index = List}

--- Creates a new List.
-- @return A new list
function List.new()
   return setmetatable({
      objects  = {},
      pointers = {},
      size     = 0,
   }, mt)
end

--- Clears the List completely.
-- @return self
function List:clear()
   self.objects  = {}
   self.pointers = {}
   self.size     = 0

   return self
end

--- Adds an object to the List.
-- @param obj The object to add
-- @return self
function List:add(obj)
   local size = self.size + 1

   self.objects[size] = obj
   self.pointers[obj] = size
   self.size          = size

   return self
end

--- Removes an object from the List.
-- @param obj The object to remove
-- @return self
function List:remove(obj)
   local index = self.pointers[obj]
   if not index then return end 
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

--- Gets an object by numerical index.
-- @param index The index to look at
-- @return The object at the index
function List:get(index)
   return self.objects[index]
end

--- Gets if the List has the object.
-- @param obj The object to search for
-- true if the list has the object, false otherwise
function List:has(obj)
   return self.pointers[obj] and true
end

return setmetatable(List, {
   __call = function() return List.new() end,
})
