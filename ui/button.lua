
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

	self.onClick = arg.onClick

	if arg.label then
		self:setLabel(arg.label)
	end
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

	--renderer:setDrawColor(0x000000)
	--renderer:drawRect(rectangle)

	renderer:setDrawColor(0x44AACC)
	renderer:fillRect {
		w = self.realWidth - 2,
		h = self.realHeight - 2,
		x = self.x + 1,
		y = self.y + 1
	}

	if self.label then
		local _, _, width, height = self.labelTexture:query()

		renderer:copy(self.labelTexture, nil, {
			x = self.x + (self.realWidth - width ) / 2,
			y = self.y + (self.realHeight - height) / 2,
			w = width, h = height
		})
	end

	self:drawChildren(renderer)
end

return Object(_M, Widget)

