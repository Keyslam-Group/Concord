--- Utils
-- Helper module for misc operations

local Utils = {}

function Utils.error(level, str, ...)
    error(string.format(str, ...), level + 1)
end

--- Does a shallow copy of a table and appends it to a target table.
-- @param orig Table to copy
-- @param target Table to append to
function Utils.shallowCopy(orig, target)
   for key, value in pairs(orig) do
      target[key] = value
   end

   return target
end

--- Requires files and puts them in a table.
-- Accepts a table of paths to Lua files: {"path/to/file_1", "path/to/another/file_2", "etc"}
-- Accepts a path to a directory with Lua files: "my_files/here"
-- @param pathOrFiles The table of paths or a path to a directory.
-- @param namespace A table that will hold the required files
-- @treturn table The namespace table
function Utils.loadNamespace(pathOrFiles, namespace)
   if type(pathOrFiles) ~= "string" and type(pathOrFiles) ~= "table" then
       Utils.error(2, "bad argument #1 to 'loadNamespace' (string/table of strings expected, got %s)", type(pathOrFiles))
   end

   if type(pathOrFiles) == "string" then
       local info = love.filesystem.getInfo(pathOrFiles) -- luacheck: ignore
       if info == nil or info.type ~= "directory" then
            Utils.error(2, "bad argument #1 to 'loadNamespace' (path '%s' not found)", pathOrFiles)
       end

       local files = love.filesystem.getDirectoryItems(pathOrFiles)

       for _, file in ipairs(files) do
            local isFile = love.filesystem.getInfo(pathOrFiles .. "/" .. file).type == "file"

            if isFile and string.match(file, '%.lua$') ~= nil then
                 local name = file:sub(1, #file - 4)
                 local path = pathOrFiles.."."..name

                 local value = require(path:gsub("%/", "."))
                 if namespace then namespace[name] = value end
            end
       end
   elseif type(pathOrFiles) == "table" then
       for _, path in ipairs(pathOrFiles) do
            if type(path) ~= "string" then
                Utils.error(2, "bad argument #2 to 'loadNamespace' (string/table of strings expected, got table containing %s)", type(path)) -- luacheck: ignore
            end

            local name = path

            local dotIndex, slashIndex = path:match("^.*()%."), path:match("^.*()%/")
            if dotIndex or slashIndex then
                name = path:sub((dotIndex or slashIndex) + 1)
            end

            local value = require(path:gsub("%/", "."))
            if namespace then namespace[name] = value end
       end
   end

   return namespace
end

return Utils
