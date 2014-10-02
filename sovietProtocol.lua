os.loadAPI("/api/redString")

local modem = nil
local protocolChannel = 1
local LISTEN_CHANNEL = 1
local PROTOCOL_CHANNEL = 1
local debug = 0

function setDebugLevel(value)
	debug = value
end

function init(protoChannel, listenChannel, side, protocol)
	if side == nil then
		modem = peripheral.find("modem")
	else
		modem = peripheral.wrap(side)
	end

	if not protocol then protocol = "generic" end

	PROTOCOL_NAME = protocol
	PROTOCOL_CHANNEL = protoChannel
	LISTEN_CHANNEL = listenChannel
	modem.open(listenChannel)
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

function send(sendChannel, replyChannel, method, id, body)
	local message = method
	if id then 
		message = message.." "..id
		if body then 
			message = message.." "..body
		end
	end
	if debug > 5 then
		print("sending: "..message:sub(1, 40))
	end
	modem.transmit(sendChannel, replyChannel, message)
end

function hello(sendChannel, protocol)
	send(sendChannel, LISTEN_CHANNEL, "hello", protocol)
	local function helloCheck()
		local reply, response = listen()
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

function listenRaw()
	while true do
		local event, modemSide, senderChannel, replyChannel,
			message, senderDistance = os.pullEvent("modem_message")
		if parse(message).method == "hello" then
			if debug > 7 then
				print("Recieved hello from "..replyChannel)
			end
			send(replyChannel, LISTEN_CHANNEL, "greeting", os.getComputerID(), PROTOCOL_NAME)
		else
			if debug > 5 then
				print("Recieved: '"..message:sub(1, 40).."'")
			end
			return replyChannel, message
		end
	end
end

function listen()
	local replyChannel, message = listenRaw()
	return replyChannel, parse(message)
end