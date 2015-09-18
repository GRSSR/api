
Opts = {
	opt_list = {},
	opt_results ={}}

function Opts:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	return self

function Opts:read()
	local opts = {...}
	local arg = 1
	while arg <= opts:len() do
		local opt = opts[arg]

		if opt[1,2] == '--' then

		elseif opt[1,1] == '-' then

		elseif opt[1,1] == '"' then

		else 

		end


	arg = arg + 1
	end