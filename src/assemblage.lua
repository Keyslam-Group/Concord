--- Assemblage
-- An Assemblage is a function that 'makes' an entity something.
-- It does this by :give'ing or :ensure'ing Components, or by :assemble'ing the Entity.

local Assemblage = {}
Assemblage.__mt = {
   __index = Assemblage,
}

--- Creates a new Assemblage.
-- @param assemble Function that assembles an Entity
-- @return A new Assemblage
function Assemblage.new(assemble)
   local assemblage = setmetatable({
      __assemble = assemble,

      __isAssemblage = true,
   }, Assemblage.__mt)

   return assemblage
end

--- Assembles an Entity.
-- @see Entity:assemble
-- @param e Entity to assemble
-- @param ... Varargs to pass to the assemble function
-- @ return self
function Assemblage:assemble(e, ...)
   self.__assemble(e, ...)

   return self
end

return setmetatable(Assemblage, {
   __call = function(_, ...)
      return Assemblage.new(...)
   end,
})
