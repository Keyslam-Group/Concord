--- Utils
-- Helper module for misc operations

local Utils = {}

--- Does a shallow copy of a table and appends it to a target table.
-- @param orig Table to copy
-- @param target Table to append to
function Utils.shallowCopy(orig, target)
	for key, value in pairs(orig) do
		target[key] = value
	end
end

return Utils