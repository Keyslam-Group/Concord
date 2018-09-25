--- init

local PATH = (...):gsub('%.init$', '')

local Type = require(PATH..".type")

local Concord = {
   _VERSION     = "1.0",
   _DESCRIPTION = "A feature-complete ECS library",
   _LICENCE     = [[
      MIT LICENSE

      Copyright (c) 2018 Justin van der Leij / Tjakka5

      Permission is hereby granted, free of charge, to any person obtaining a
      copy of this software and associated documentation files (the
      "Software"), to deal in the Software without restriction, including
      without limitation the rights to use, copy, modify, merge, publish,
      distribute, sublicense, and/or sell copies of the Software, and to
      permit persons to whom the Software is furnished to do so, subject to
      the following conditions:

      The above copyright notice and this permission notice shall be included
      in all copies or substantial portions of the Software.
      
      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
      OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
      MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
      IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
      CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
      TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
      SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
   ]]
}

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
