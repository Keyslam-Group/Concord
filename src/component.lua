--- Component
-- A Component is a pure data container.
-- A Component is contained by a single entity.

local Component = {}
Component.__mt = {
   __index = Component,
}

--- Creates a new ComponentClass.
-- @param populate Function that populates a Component with values
-- @return A new ComponentClass
function Component.new(populate)
   if (type(populate) ~= "function" and type(populate) ~= "nil") then
      error("bad argument #1 to 'Component.new' (function/nil expected, got "..type(populate)..")", 2)
   end

   local componentClass = setmetatable({
      __populate = populate,

      __isComponentClass = true,
   }, Component.__mt)

   componentClass.__mt = {
      __index = componentClass
   }

   return componentClass
end

--- Internal: Populates a Component with values
function Component:__populate() -- luacheck: ignore
end

--- Internal: Creates and populates a new Component.
-- @param ... Varargs passed to the populate function
-- @return A new populated Component
function Component:__initialize(...)
   local component = setmetatable({
      __componentClass = self,

      __isComponent     = true,
      __isComponentClass = false,
   }, self)

   self.__populate(component, ...)

   return component
end

return setmetatable(Component, {
   __call = function(_, ...)
      return Component.new(...)
   end,
})