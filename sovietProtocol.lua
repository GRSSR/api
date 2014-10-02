os.loadAPI("/api/redString")

local modem = nil
local protocolChannel = 1

local debug = 0

function setDebugLevel(value)
	debug = value
end

function init(protoChannel, listenChannel, side)
	if side == nil then
		modem = peripheral.find("modem")
	else
		modem = peripheral.wrap(side)
	end
	protocolChannel = protoChannel
	modem.open(listenChannel)
end

function parse(message)
	local split = redString.split(message, 3)
	ret = {}
	ret.method = split[1]
	ret.id = split[2]
	ret.body = split[3]
	return ret
end

function send(sendChannel, replyChannel, method, id, body)
	if not body then body = "" end
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

function listenRaw()
	local event, modemSide, senderChannel, replyChannel,
		message, senderDistance = os.pullEvent("modem_message")
	if debug > 5 then
		print("Recieved: "..message:sub(1, 40))
	end
	return replyChannel, message
end

function listen()
	local replyChannel, message = listenRaw()
	return replyChannel, parse(message)
end