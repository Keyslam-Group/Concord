--- Assemblage

local PATH = (...):gsub('%.[^%.]+$', '')

local Assemblages = require(PATH..".world")

local Assemblage = {}
Assemblage.__index = Assemblage

function Assemblage.new(name, assemble)
   if (type(name) ~= "string") then
      error("bad argument #1 to 'Assemblage.new' (string expected, got "..type(name)..")", 2)
   end

   local assemblage = setmetatable({
      __assemble = assemble,

      __name         = name,
      __isAssemblage = true,
   }, Assemblage)
   
   Assemblages.register(name, assemblage)

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
