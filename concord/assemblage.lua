--- Gives an entity a set of components.
-- @classmod Assemblage

local Assemblage = {}
Assemblage.__mt = {
   __index = Assemblage,
}

--- Creates a new Assemblage.
-- @tparam function assemble Function that assembles an Entity
-- @treturn Assemblage A new assemblage
function Assemblage.new(assemble)
   local assemblage = setmetatable({
      __assemble = assemble,

      __name         = nil,
      __isAssemblage = true,
   }, Assemblage.__mt)

   return assemblage
end

--- Assembles an Entity.
-- @tparam Entity e Entity to assemble
-- @param ... additional arguments to pass to the assemble function
-- @treturn Assemblage self
function Assemblage:assemble(e, ...)
   self.__assemble(e, ...)

   return self
end

--- Returns true if the Assemblage has a name.
-- @treturn boolean
function Assemblage:hasName()
   return self.__name and true or false
end

--- Returns the name of the Assemblage.
-- @treturn string
function Assemblage:getName()
   return self.__name
end

return setmetatable(Assemblage, {
   __call = function(_, ...)
      return Assemblage.new(...)
   end,
})
