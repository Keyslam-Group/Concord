--- List

local List = {}
local mt = {__index = List}

--- Creates a new List.
-- @return A new list
function List.new()
   return setmetatable({
      size = 0,
   }, mt)
end

--- Clears the List completely.
-- @return self
function List:clear()
   for i = 1, self.size do
      local o = self[i]

      self[o] = nil
      self[i] = nil
   end

   self.size = 0

   return self
end

--- Adds an object to the List.
-- @param obj The object to add
-- @return self
function List:add(obj) -- obj can not be a number and also not the string "size"
   local size = self.size + 1

   self[size] = obj
   self[obj]  = size
   self.size  = size

   return self
end

--- Removes an object from the List.
-- @param obj The object to remove
-- @return self
function List:remove(obj)
   local index = self[obj]
   if not index then return end
   local size  = self.size

   if index == size then
      self[size] = nil
   else
      local other = self[size]

      self[index] = other
      self[other] = index

      self[size] = nil
   end

   self[obj] = nil
   self.size = size - 1
end

--- Gets an object by numerical index.
-- @param index The index to look at
-- @return The object at the index
function List:get(index)
   return self[index]
end

--- Gets if the List has the object.
-- @param obj The object to search for
-- true if the list has the object, false otherwise
function List:has(obj)
   return self[obj] and true
end

return setmetatable(List, {
   __call = function()
      return List.new()
   end,
})
