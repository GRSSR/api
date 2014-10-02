function split(string, limit, delimiter)
	if not delimiter then
		delimiter = "%s+"
	end
	local ret = {}
	local length = 0

	while true do
		local dStart, dEnd = string:find(delimiter)
		if limit and length >= limit -1 then
			ret[#ret + 1] = string
			return ret
		elseif dStart then
			if dEnd >= string:len()+1 then
				return ret
			end

			ret[#ret + 1] = string:sub(1, dStart-1)
			length = length + 1
			string = string:sub(dEnd+1)
		elseif string:len() == 0 then
			return ret
		else
			ret[#ret + 1] = string
			return ret
		end
	end
end

function join(list, delimiter)
	if not delimiter then delimiter = " " end
	local string = ""
	for k, value in pairs(list) do 
		string = string .. delimiter .. value
	end
	return string
end
