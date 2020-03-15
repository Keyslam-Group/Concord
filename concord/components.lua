--- Container for registered ComponentClasses
-- @module Components

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Components = {}

--- Returns true if the containter has the ComponentClass with the specified name
-- @string name Name of the ComponentClass to check
-- @treturn boolean
function Components.has(name)
   return rawget(Components, name) and true or false
end

--- Returns true and the ComponentClass if one was registered with the specified name
-- or false and an error otherwise
-- @string name Name of the ComponentClass to check
-- @treturn boolean
-- @treturn Component or error string
function Components.try(name)
   if type(name) ~= "string" then
      return false, "ComponentsClass name is expected to be a string, got "..type(name)..")"
   end

   local value = rawget(Components, name)
   if not value then
      return false, "ComponentClass '"..name.."' does not exist / was not registered"
   end

   return true, value
end

--- Returns the ComponentClass with the specified name
-- @string name Name of the ComponentClass to get
-- @treturn Component
function Components.get(name)
   local ok, value = Components.try(name)

   if not ok then error(value, 2) end

   return value
end

return setmetatable(Components, {
   __index = function(_, name)
      local ok, value = Components.try(name)

      if not ok then error(value, 2) end

      return value    end
})
