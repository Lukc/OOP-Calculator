
local Object = require "object"
local Widget = require "ui.widget"

local _M = {}

function _M:new(arg)
	Widget.new(self, arg)
end

function _M:addChild(child)
	Widget.addChild(self, child)

	if child.height == math.huge then
		io.stderr:writee("<Column.addChild> child.height == math.huge\n")
	end
end

function _M:update()
	self.realWidth = self.width or 0
	self.realHeight = self.height or 0

	local h = 0
	for i = 1, #self.children do
		local child = self.children[i]

		child.x = self.x
		child.y = self.y + h

		if not self.height then
			self.realHeight = self.realHeight + child.realHeight
		end

		if not self.width and child.width ~= math.huge then
			self.realWidth = math.max(self.realWidth, child.realWidth)
		end

		h = h + child.realHeight
	end

	Widget.update(self)
end

function _M:draw(renderer)
	local rectangle = {
		w = self.realWidth or 0,
		h = self.realHeight or 0,
		x = self.x or 0,
		y = self.y or 0
	}

	renderer:setDrawColor(0x0088FF)
	renderer:drawRect(rectangle)

	self:drawChildren(renderer)
end

return Object(_M, Widget)

