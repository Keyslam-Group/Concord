--- A pure data container that is contained by a single entity.
-- @classmod Component

local PATH = (...):gsub('%.[^%.]+$', '')

local Components = require(PATH..".components")
local Utils      = require(PATH..".utils")

local Component = {}
Component.__mt = {
   __index = Component,
}

--- Creates a new ComponentClass.
-- @tparam function populate Function that populates a Component with values
-- @treturn Component A new ComponentClass
function Component.new(name, populate)
   if (type(name) ~= "string") then
      error("bad argument #1 to 'Component.new' (string expected, got "..type(name)..")", 2)
   end

   if (rawget(Components, name)) then
      error("bad argument #1 to 'Component.new' (ComponentClass with name '"..name.."' was already registerd)", 2) -- luacheck: ignore
   end

   if (type(populate) ~= "function" and type(populate) ~= "nil") then
      error("bad argument #1 to 'Component.new' (function/nil expected, got "..type(populate)..")", 2)
   end

   local componentClass = setmetatable({
      __populate = populate,

      __name             = name,
      __isComponentClass = true,
   }, Component.__mt)

   componentClass.__mt = {
      __index = componentClass
   }

   Components[name] = componentClass

   return componentClass
end

-- Internal: Populates a Component with values
function Component:__populate() -- luacheck: ignore
end

function Component:serialize()
   local data = Utils.shallowCopy(self, {})

   --This values shouldn't be copied over
   data.__componentClass = nil
   data.__isComponent = nil
   data.__isComponentClass = nil

   return data
end

function Component:deserialize(data)
   Utils.shallowCopy(data, self)
end

-- Internal: Creates a new Component.
-- @return A new Component
function Component:__new()
   local component = setmetatable({
      __componentClass = self,

      __isComponent      = true,
      __isComponentClass = false,
   }, self.__mt)

   return component
end

-- Internal: Creates and populates a new Component.
-- @param ... Varargs passed to the populate function
-- @return A new populated Component
function Component:__initialize(...)
   local component = self:__new()

   self.__populate(component, ...)

   return component
end

--- Returns true if the Component has a name.
-- @treturn boolean
function Component:hasName()
   return self.__name and true or false
end

--- Returns the name of the Component.
-- @treturn string
function Component:getName()
   return self.__name
end

return setmetatable(Component, {
   __call = function(_, ...)
      return Component.new(...)
   end,
})
