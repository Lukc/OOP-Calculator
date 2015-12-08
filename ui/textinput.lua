
local sdl = require "SDL"
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

	self.labelText = ""

	if arg.label then
		self:setLabel(arg.label)
	end

	if arg.onKeyUp then
		self.customKeyUp = arg.onKeyUp
	end

	self.labelUpdate = false
end

function _M:onKeyUp(event)
	local r

	if self.customKeyUp then
		r = self:customKeyUp(event)
	end

	if r then
		return r
	end

	local key

	for k,v in pairs(sdl.key) do
		if v == event.keysym.sym then
			key = k

			break
		end
	end

	if key then
		print(key .. " pressed")

		if key == "Backspace" then
			self:setLabel(self.labelText:sub(1, #self.labelText - 1))
		else
			self:setLabel(self.labelText .. key)
		end
	end

	return true
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

	if self.textLabel then
		print(self.textLabel)
	end

	local err

	if self.labelUpdate then
		self.label, err =
			self.root.fonts[1]:renderUtf8(self.labelText, "solid", 0xFFFFFF)

		if err then
			-- Commented out, because flood.
			--print(err)
		end

		if self.label then
			print("Texture update!!!")

			self.labelTexture =
				self.root.renderer:createTextureFromSurface(self.label)
		end

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

