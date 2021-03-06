
local Object = require "object"
local Widget = require "ui.widget"

local _M = {}

function _M:draw(renderer)
	local start, _end, step

	self:onUpdate()

	step = self.scaleX
	start = self.x + (self.realWidth / 2) % step
	_end = self.x + self.realWidth

	local pair

	for i = start, _end, step do
		pair = not pair
		if pair then
			renderer:setDrawColor(0x888888)
		else
			renderer:setDrawColor(0xAAAAAA)
		end
		renderer:drawLine({
			x1 = i,
			y1 = self.y,
			x2 = i,
			y2 = self.y + self.realHeight
		})
	end

	step = self.scaleY
	start = self.y + (self.realHeight / 2) % step
	_end = self.y + self.realHeight
	for i = start, _end, step do
		pair = not pair
		if pair then
			renderer:setDrawColor(0x888888)
		else
			renderer:setDrawColor(0xAAAAAA)
		end
		renderer:drawLine({
			x1 = self.x,
			y1 = i,
			x2 = self.x + self.realWidth,
			y2 = i
		})
	end

	if self.onDraw then
		renderer:setDrawColor(0xFFFFFF)
		self:onDraw(renderer)
	end
end

function _M:setScale(x, y)
	self.scaleX = x or self.scaleX
	self.scaleY = y or self.scaleY
end

function _M:new(arg)
	Widget.new(self, arg)

	self.scaleX, self.scaleY = 50, 50

	self.onDraw = arg.onDraw
	self.onUpdate = arg.onUpdate
end

return Object(_M, Widget)

