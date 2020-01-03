local Utils = {}

function Utils.shallowCopy(orig, target)
	for key, value in pairs(orig) do
		target[key] = value
	end
end

return Utils