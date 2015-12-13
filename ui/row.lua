
local Object = require "object"
local Widget = require "ui.widget"

local _M = {}

function _M:new(arg)
	Widget.new(self, arg)
end

function _M:addChild(child)
	Widget.addChild(self, child)

	if child.width == math.huge then
		io.stderr:write("<Row.addChild> child.width == math.huge\n")
	end
end

function _M:update()
	self.realWidth = self.width or 0
	self.realHeight = self.height or 0

	local w = 0
	for i = 1, #self.children do
		local child = self.children[i]

		child.x = self.x + w
		child.y = self.y

		if not self.height and child.height ~= math.huge then
			self.realHeight = math.max(self.realHeight, child.realHeight)
		end

		if not self.width then
			self.realWidth = self.realWidth + child.realWidth
		end

		w = w + child.realWidth
	end

	Widget.update(self)
end

function _M:draw(renderer)
	if self.debug then
		local rectangle = {
			w = self.realWidth or 0,
			h = self.realHeight or 0,
			x = self.x or 0,
			y = self.y or 0
		}

		renderer:setDrawColor(0x00FF44)
		renderer:drawRect(rectangle)
	end

	self:drawChildren(renderer)
end

return Object(_M, Widget)

