--- Component

local Component = {}
Component.__index = Component

--- Creates a new Component.
-- @param populate A function that populates the Bag with values
-- @return A Component object
function Component.new(populate)
   if not (type(populate) == "function") then
      error("bad argument #1 to 'Component.new' (function expected, got "..type(populate)..")", 2)
   end

   local baseComponent = setmetatable({
      __populate = populate,

      __isBaseComponent = true,
   }, Component)

   baseComponent.__mt = {__index = baseComponent}

   return baseComponent
end

--- Creates and initializes a new Component.
-- @param ... The values passed to the populate function
-- @return A new initialized Component
function Component:__initialize(...)
   local component = setmetatable({
      __baseComponent = self,

      __isComponent     = true,
      __isBaseComponent = false,
   }, self)

   self.__populate(component, ...)

   return component
end

return setmetatable(Component, {
   __call = function(_, ...)
      return Component.new(...)
   end,
})