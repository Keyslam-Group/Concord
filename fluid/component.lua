local Component = {}
Component.__index = Component

--- Creates a new Component.
-- @param populate A function that populates the Bag with values
-- @param inherit States if the Bag should inherit the Component's functions
-- @return A Component object
function Component.new(populate, inherit)
   local component = setmetatable({
      __populate = populate,
      __inherit  = inherit,
   }, Component)

   if inherit then
      component.__mt = {__index = component}
   end

   return component
end

-- Creates and initializes a new Bag.
-- @param ... The values passed to the populate function
-- @return A new initialized Bag
function Component:initialize(...)
   if self.__populate then
      local bag = {}
      self.__populate(bag, ...)

      if self.__inherit then
         setmetatable(bag, self.__mt)
      end

      return bag
   end

   return true
end

return setmetatable(Component, {
   __call = function(_, ...) return Component.new(...) end,
})
