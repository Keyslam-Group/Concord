--- List
-- Data structure that allows for fast removal at the cost of containing order.

local List = {}
List.__mt = {
   __index = List
}

--- Creates a new List.
-- @return A new List
function List.new()
   return setmetatable({
      size = 0,
   }, List.__mt)
end

--- Adds an object to the List.
-- Object must be of reference type
-- Object may not be the string 'size'
-- @param obj Object to add
-- @return self
function List:__add(obj)
   local size = self.size + 1

   self[size] = obj
   self[obj]  = size
   self.size  = size

   return self
end

--- Removes an object from the List.
-- @param obj Object to remove
-- @return self
function List:__remove(obj)
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

   return self
end

--- Clears the List completely.
-- @return self
function List:__clear()
   for i = 1, self.size do
      local o = self[i]

      self[o] = nil
      self[i] = nil
   end

   self.size = 0

   return self
end

--- Returns true if the List has the object.
-- @param obj Object to check for
-- @return True if the List has the object, false otherwise
function List:has(obj)
   return self[obj] and true or false
end

--- Returns the object at an index.
-- @param i Index to get from
-- @return Object at the index
function List:get(i)
   return self[i]
end

--- Returns the index of an object in the List.
-- @param obj Object to get index of
-- @return index of object in the List.
function List:indexOf(obj)
   if (not self[obj]) then
      error("bad argument #1 to 'List:indexOf' (Object was not in List)", 2)
   end

   return self[obj]
end

return setmetatable(List, {
   __call = function()
      return List.new()
   end,
})
