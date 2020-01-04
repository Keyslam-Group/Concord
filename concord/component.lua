--- A pure data container that is contained by a single entity.
-- @classmod Component

local Component = {}
Component.__mt = {
   __index = Component,
}

--- Creates a new ComponentClass.
-- @tparam function populate Function that populates a Component with values
-- @treturn Component A new ComponentClass
function Component.new(populate)
   if (type(populate) ~= "function" and type(populate) ~= "nil") then
      error("bad argument #1 to 'Component.new' (function/nil expected, got "..type(populate)..")", 2)
   end

   local componentClass = setmetatable({
      __populate = populate,

      __name             = nil,
      __isComponentClass = true,
   }, Component.__mt)

   componentClass.__mt = {
      __index = componentClass
   }

   return componentClass
end

-- Internal: Populates a Component with values
function Component:__populate() -- luacheck: ignore
end

function Component:serialize() -- luacheck: ignore
end

function Component:deserialize(data) -- luacheck: ignore
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
