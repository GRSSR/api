os.loadAPI("/api/redString")

userTable = {}

function generateKey(length)
	local minChar = 33
	local maxChar = 126

	key = ""
	for i = 0, length, 1 do
		nextChar = string.char(
			math.random(minChar, maxChar))
		key = key..nextChar
	end
	return key
end

function addUser(name, token)
	userTable[name] = token
end

function loadUsers(file)
	f = io.open(file, "r")
	userTable = {}
	for line in f:lines() do
		split = redString.split(line)
		userTable[split[1]] = split[2]
	end
	f:close()
end

function loadAccessList(file)
	f = io.open(file, "r")
	accessTable = {}
	if f then
		for line in f:lines() do
			accessTable[line] = true
		end
		f:close()
	end
	return accessTable
end

function saveAccessList(file, accessList)
	f = io.open(file, "w")
	for user, throwAway in pairs(accessList) do
		f:write(user.."\n")
	end
	f:close()
end

function saveUsers(file)
	f = io.open(file, "w")
	for user, token in pairs(userTable) do
		f:write(user.." "..token.."\n")
	end
	f:close()
end

function mapUser(userToken)
	for user, token in pairs(userTable) do
		if userToken == token then
			return user
		end
	end
	return false
end

function printUsers()
	for user, token in pairs(userTable) do
		print(user..": "..token)
	end
end

function readIDDisk()
	locations = {
		"top",
		"left",
		"front",
		"back",
		"right",
		"bottom"}

	for key, location in pairs(locations) do
		if disk.isPresent(location) then
			diskRoot = disk.getMountPath(location)
			idFile = fs.combine(diskRoot, "ID")

			if fs.exists(idFile) then 
				f = io.open(idFile, "r")
				token = f:lines()()
				f:close()
				userName = string.match(disk.getLabel(location), "(.+)'")
				return userName, token
			end
		end
	end
	return false
end