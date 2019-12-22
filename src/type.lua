-- Type

local Type = {}

function Type.isEntity(t)
   return type(t) == "table" and t.__isEntity or false
end

function Type.isBaseComponent(t)
   return type(t) == "table" and t.__isBaseComponent or false
end

function Type.isComponent(t)
   return type(t) == "table" and t.__isComponent or false
end

function Type.isBaseSystem(t)
   return type(t) == "table" and t.__isBaseSystem or false
end

function Type.isSystem(t)
   return type(t) == "table" and t.__isSystem or false
end

function Type.isWorld(t)
   return type(t) == "table" and t.__isWorld or false
end

function Type.isAssemblage(t)
   return type(t) == "table" and t.__isAssemblage or false
end

return Type
