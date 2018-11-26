-- Type

local Type = {}

function Type.isComponent(t)
   return type(t) == "table" and t.__isComponent
end

function Type.isEntity(t)
   return type(t) == "table" and t.__isEntity
end

function Type.isSystem(t)
   return type(t) == "table" and t.__isSystem
end

function Type.isContext(t)
   return type(t) == "table" and t.__isContext
end

function Type.isAssemblage(t)
   return type(t) == "table" and t.__isAssemblage
end

return Type
