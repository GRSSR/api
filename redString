
function split(string, limit, delimiter)
	if not delimiter then
		delimiter = "%S+"
	end
	local ret = {}
	local length = 0
	for match in string.gmatch(string, delimiter) do
		if limit and (#ret + 1) >= limit then
			local start, finish = string:find(match, length, true)
			ret[#ret + 1] = string:sub(start)
			break
		else
			ret[#ret + 1] = match
			length = length + ret[#ret]:len()
		end
	end
	return ret
end
