os.loadAPI("/api/redString")

local DEBUG_LEVEL = 0
local proto_channel_map = {}

function setDebugLevel(value)
	DEBUG_LEVEL = value
end

function parse(message)
	local split = redString.split(message, 3)
	ret = {}
	ret.protocol = ""
	ret.method = split[1]
	ret.id = split[2]
	ret.body = split[3]
	return ret
end

function findModems()
	local modems = {}
	for key, device in pairs(peripheral.getNames()) do
		if peripheral.getType(device) == "modem" then
			modems[device] = peripheral.wrap(device)
		end
	end
	return modems
end

Protocol = {
	name = nil,
	modem = nil,
	channel = nil,
	listen_channel = nil,
	time_out = nil
}

function Protocol:new(name, protoChannel, listenChannel, side)
	o = {}
	setmetatable(o, self)
	self.__index = self
	self.channel = tonumber(protoChannel)
	self.listen_channel = tonumber(listenChannel)
	self.name = name
	if proto_channel_map[self.channel] ~= nil then
		print("Protocol channel already in use")
		return false
	else 
		proto_channel_map[self.channel] = self
	end

	if side == nil then
		self.modem = peripheral.find("modem")
	else
		self.modem = peripheral.wrap(side)
	end
	self.modem.open(listenChannel)
	return self
end

function Protocol:tearDown()
	proto_channel_map[self.channel] = nil
end

function Protocol:send(method, id, body, channel)
	if channel == nil then
		channel = self.channel
	end
	local message = method
	if id then 
		message = message.." "..id
		if body then 
			message = message.." "..body
		end
	end
	if DEBUG_LEVEL > 5 then
		print("sending: "..message:sub(1, 40))
	end
	self.modem.transmit(channel, self.listen_channel, message)
end

function Protocol:hello()
	self:send("hello", self.name)
	local function helloCheck()
		local reply, response = self:listen()
		if response.method == "greeting" then
			return true, redString.split(response.body)
		else
			return false, {}
		end
	end

	local function sleep1()
		sleep(1)
	end

	local winner = parallel.waitForAny(helloCheck, sleep1)

	if winner == 1 then
		return true
	else
		return false
	end	
end

function Protocol:handleEvent(event, modemSide, senderChannel, replyChannel, message, senderDistance)
	if senderChannel == self.listen_channel then
		if parse(message).method == "hello" then
			if DEBUG_LEVEL > 7 then
				print("Recieved hello from "..replyChannel.." for protocol "..parse(message).id)
			end
			self:send("greeting", os.getComputerID(), self.name, replyChannel)
		else
			if DEBUG_LEVEL > 5 then
				print("Recieved: '"..message:sub(1, 40).."'")
			end
			return replyChannel, message
		end
	end
end

function Protocol:listenRaw()
	while true do
		local event, modemSide, senderChannel, replyChannel,
			message, senderDistance = os.pullEvent("modem_message")
		local replyChannel, message = self:handleEvent(
			event, modemSide, senderChannel, replyChannel,
			message, senderDistance)
		if replyChannel then
			return replyChannel, message
		end
	end
end

function Protocol:listen()
	local replyChannel, message = self:listenRaw()
	return replyChannel, parse(message)
end
