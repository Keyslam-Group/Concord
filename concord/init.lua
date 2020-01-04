---
-- @module Concord

local PATH = (...):gsub('%.init$', '')

local Concord = {
   _VERSION     = "2.0 Beta",
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

Concord.entity     = require(PATH..".entity")

Concord.component  = require(PATH..".component")
Concord.components = require(PATH..".components")

Concord.system     = require(PATH..".system")
Concord.systems    = require(PATH..".systems")

Concord.world      = require(PATH..".world")
Concord.worlds     = require(PATH..".worlds")

Concord.assemblage  = require(PATH..".assemblage")
Concord.assemblages = require(PATH..".assemblages")

local function load(pathOrFiles, namespace)
   if (type(pathOrFiles) ~= "string" and type(pathOrFiles) ~= "table") then
      error("bad argument #1 to 'load' (string/table of strings expected, got "..type(pathOrFiles)..")", 3)
   end

   if (type(pathOrFiles) == "string") then
      local info = love.filesystem.getInfo(pathOrFiles) -- luacheck: ignore
      if (info == nil or info.type ~= "directory") then
         error("bad argument #1 to 'load' (path '"..pathOrFiles.."' not found)", 3)
      end

      local files = love.filesystem.getDirectoryItems(pathOrFiles)

      for _, file in ipairs(files) do
         local name = file:sub(1, #file - 4)
         local path = pathOrFiles.."."..name

         namespace.register(name, require(path))
      end
   elseif (type(pathOrFiles == "table")) then
      for _, path in ipairs(pathOrFiles) do
         if (type(path) ~= "string") then
            error("bad argument #2 to 'load' (string/table of strings expected, got table containing "..type(path)..")", 3) -- luacheck: ignore
         end

         local name = path

         local dotIndex, slashIndex = path:match("^.*()%."), path:match("^.*()%/")
         if (dotIndex or slashIndex) then
            name = path:sub((dotIndex or slashIndex) + 1)
         end

         namespace.register(name, require(path))
      end
   end
end

--- Loads ComponentClasses and puts them in the Components container.
-- Accepts a table of paths to files: {"component_1", "component_2", "etc"}
-- Accepts a path to a directory with ComponentClasses: "components"
function Concord.loadComponents(pathOrFiles)
   load(pathOrFiles, Concord.components)
end

--- Loads SystemClasses and puts them in the Systems container.
-- Accepts a table of paths to files: {"system_1", "system_2", "etc"}
-- Accepts a path to a directory with SystemClasses: "systems"
function Concord.loadSystems(pathOrFiles)
   load(pathOrFiles, Concord.systems)
end

--- Loads Worlds and puts them in the Worlds container.
-- Accepts a table of paths to files: {"world_1", "world_2", "etc"}
-- Accepts a path to a directory with Worlds: "worlds"
function Concord.loadWorlds(pathOrFiles)
   load(pathOrFiles, Concord.worlds)
end

--- Loads Assemblages and puts them in the Assemblages container.
-- Accepts a table of paths to files: {"assemblage_1", "assemblage_2", "etc"}
-- Accepts a path to a directory with Assemblages: "assemblages"
function Concord.loadAssemblages(pathOrFiles)
   load(pathOrFiles, Concord.assemblages)
end

return Concord
