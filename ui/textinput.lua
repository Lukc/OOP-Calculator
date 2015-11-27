
local ttf = require "SDL.ttf"

local Object = require "object"
local Widget = require "ui.widget"

local _M = {}

---
-- @todo Text color.
-- @todo Text alignments (vertical AND horizontal).
--

function _M:new(arg)
	Widget.new(self, arg)

	self.label = arg.label

	if arg.label then
		self:setLabel(arg.label)
	end
end

function _M:onClick(event)
	self:setFocus()
end

function _M:setLabel(text)
	self.labelText = text
	self.labelUpdate = true
end

function _M:update()
	Widget.update(self)

	if self.labelUpdate then
		self.label =
			self.root.fonts[1]:renderUtf8(self.labelText, "solid", 0xFFFFFF)
		self.labelTexture =
			self.root.renderer:createTextureFromSurface(self.label)

		self.labelUpdate = nil
	end
end

function _M:draw(renderer)
	local rectangle = {
		w = self.realWidth or 0,
		h = self.realHeight or 0,
		x = self.x or 0,
		y = self.y or 0
	}

	if self.focused then
		renderer:setDrawColor(0xFF00FF)
	else
		renderer:setDrawColor(0x880088)
	end
	renderer:drawRect(rectangle)

	if self.label then
		local _, _, width, height = self.labelTexture:query()

		renderer:copy(self.labelTexture, nil, {
			x = self.x,
			y = self.y,
			w = width, h = height
		})
	end

	self:drawChildren(renderer)
end

return Object(_M, Widget)

