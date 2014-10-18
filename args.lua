
function parseArgs(args) 

	local parsedArgs = {}
	for k, v in pairs(args) do 
		if v:sub(1, 2) == "--" then
			parsedArgs[v:sub(3)] = true
		elseif v:sub(1,1) == "-" then
			for i=2, v:len() do 
				parsedArgs[v:sub(i,i)] = true
			end
		end
	end
	return parsedArgs
end