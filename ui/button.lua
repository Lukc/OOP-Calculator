
local Object = require "object"
local Widget = require "ui.widget"

local _M = {}

function _M:new(arg)
	Widget.new(self, arg)

	self.label = arg.label

	self.onClick = arg.onClick
end

function _M:draw(renderer)
	local rectangle = {
		w = self.realWidth or 0,
		h = self.realHeight or 0,
		x = self.x or 0,
		y = self.y or 0
	}

	-- FIXME: Print text.

	renderer:setDrawColor(0xFF00FF)
	renderer:drawRect(rectangle)

	self:drawChildren(renderer)
end

return Object(_M, Widget)

