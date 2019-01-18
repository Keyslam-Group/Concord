--- Type

local Type = {}

--- Check if 't' is a component
-- @param t A table/object to be checked
-- @return a boolean `true` if it `t` is a component, otherwise false
function Type.isComponent(t)
   return type(t) == "table" and t.__isComponent
end

--- Check if 't' is an entity
-- @param t A table/object to be checked
-- @return a boolean `true` if it `t` is an entity, otherwise false
function Type.isEntity(t)
   return type(t) == "table" and t.__isEntity
end

--- Check if 't' is a system
-- @param t A table/object to be checked
-- @return a boolean `true` if it `t` is a system, otherwise false
function Type.isSystem(t)
   return type(t) == "table" and t.__isSystem
end

--- Check if 't' is an instance
-- @param t A table/object to be checked
-- @return a boolean `true` if it `t` is an instance, otherwise false
function Type.isInstance(t)
   return type(t) == "table" and t.__isInstance
end

return Type
