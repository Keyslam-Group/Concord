--- Component

local PATH = (...):gsub('%.[^%.]+$', '')

local Components = require(PATH..".components")

local Component = {}
Component.__index = Component

--- Creates a new Component.
-- @param populate A function that populates the Bag with values
-- @return A Component object
function Component.new(name, populate)
   if (type(name) ~= "string") then
      error("bad argument #1 to 'Component.new' (string expected, got "..type(name)..")", 2)
   end

   if not (populate == nil or type(populate) == "function") then
      error("bad argument #2 to 'Component.new' (function/nil expected, got "..type(populate)..")", 2)
   end

   local component = setmetatable({
      __name = name,
      __populate = populate,

      __isComponent = true,
   }, Component)

   component.__mt = {__index = component}

   Components.register(name, component)

   return component
end

--- Creates and initializes a new Bag.
-- @param ... The values passed to the populate function
-- @return A new initialized Bag
function Component:__initialize(...)
   if self.__populate then
      local bag = setmetatable({}, self.__mt)
      self.__populate(bag, ...)

      return bag
   end

   return true
end

return setmetatable(Component, {
   __call = function(_, ...)
      return Component.new(...)
   end,
})