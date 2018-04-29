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

function Type.isInstance(t)
   return type(t) == "table" and t.__isInstance
end

return Type