
local Object = require "object"
local Widget = require "ui.widget"

local _M = {}

function _M:draw(renderer)
	renderer:setDrawColor(0xFF00FF)
	renderer:drawRect {
		w = self.realWidth,
		h = self.realHeight,
		x = self.x,
		y = self.y
	}
end

function _M:new(arg)
	Widget.new(self, arg)
end

return Object(_M, Widget)

