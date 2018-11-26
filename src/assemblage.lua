--- Assemblage

local Assemblage = {}
Assemblage.__index = Assemblage

function Assemblage.new(assemble)
   local assemblage = setmetatable({
      __assemble = assemble,

      __isAssemblage = true,
   }, Assemblage)

   return assemblage
end

function Assemblage:assemble(e, ...)
   self.__assemble(e, ...)

   return self
end

return setmetatable(Assemblage, {
   __call = function(_, ...)
      return Assemblage.new(...)
   end,
})
