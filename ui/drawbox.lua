
local Object = require "object"
local Widget = require "ui.widget"

local _M = {}

function _M:draw(renderer)
	renderer:setDrawColor(0xFF0000)
	renderer:fillRect {
		w = self.realWidth,
		h = self.realHeight,
		x = self.x,
		y = self.y
	}

	if self.onDraw then
		self:onDraw(renderer)
	end
end

function _M:new(arg)
	Widget.new(self, arg)

	self.onDraw = arg.onDraw
end

return Object(_M, Widget)

