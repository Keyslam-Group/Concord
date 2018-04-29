local PATH = (...):gsub('%.init$', '')

local Type = require(PATH..".type")

local Concord = {}

--- Initializes the library with some optional settings
-- @param settings Table of settings: {
--  useEvents Flag to overwrite love.run and use events. Defaults to false
-- }
-- @return Concord
function Concord.init(settings)
   Concord.entity       = require(PATH..".entity")
   Concord.component    = require(PATH..".component")
   Concord.system       = require(PATH..".system")
   Concord.instance     = require(PATH..".instance")

   if settings and settings.useEvents then
      Concord.instances = {}

      Concord.addInstance = function(instance)
         if not Type.isInstance(instance) then
            error("bad argument #1 to 'Concord.addInstance' (Instance expected, got "..type(instance)..")", 2)
         end

         table.insert(Concord.instances, instance)
      end

      Concord.removeInstance = function(instance)
         if not Type.isInstance(instance) then
            error("bad argument #1 to 'Concord.addInstance' (Instance expected, got "..type(instance)..")", 2)
         end

         for i, instance in ipairs(Concord.instances) do
            table.remove(Concord.instances, i)
            break
         end
      end

      love.run = require(PATH..".run")
   end

   return Concord
end

return Concord
