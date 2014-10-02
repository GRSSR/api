local buttonMapping = {}

function resetScreen(screen)
	local x,y = screen.getSize()
	for xpos=1, x do
		for ypos=1, y do
			screen.setCursorPos(xpos,ypos)
			screen.setBackgroundColor(colors.black)
			screen.write(" ")
		end
	end
end

function pad(output, length)
	for i =1, length do 
		output.write(" ")
	end
end

Button ={
	width = 1,
	height = 1,
	screen = nil,
	text = "",
	x = 1,
	y = 1,
	colour = colors.white,
	callback = nil
}

function Button:new()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Button:draw()
	self.screen.setCursorPos(self.x, self.y)
	self.screen.setBackgroundColor(self.colour)
	length = string.len(self.text)
	textLine = self.y + math.floor(self.height/2)
	for i = self.y, self.y + self.height-1 do
		buttonMapping[i] = self
		self.screen.setCursorPos(self.x, i)
		padding = math.floor((self.width - length)/2)
		if i == textLine then
			pad(self.screen, padding)
			self.screen.write(self.text)
			pad(self.screen, self.width - (padding+length))
		else
			pad(self.screen, self.width)
		end
	end
end

function Button:init(screen, text, x, y, width, height, colour, callback)
end

function runCallback(x, y)
	local button = buttonMapping[y]
	if button then
		if button.x < x  and x < (button.x + button.width) then
			if buttonMapping[y].callback then
				return buttonMapping[y].callback()
			end
		end
	end
end