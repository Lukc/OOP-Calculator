
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

	self.labelText = ""

	self.labelUpdate = false

	if arg.label then
		self:setLabel(arg.label, arg.color)
	end

	self.customKeyUp = arg.onKeyUp
	self.onNewValue = arg.onNewValue
end

function _M:onTextInput(event)
	self:setLabel(self.labelText .. event.text)

	return true
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
		if key == "Backspace" then
			if #self.labelText > 0 then
				self:setLabel(self.labelText:sub(1, #self.labelText - 1))
			end
		elseif key == "Return" or key == "KPEnter" then
			return true, self:onNewValue(self.labelText)
		elseif #key == 1 then
		else
			io.stderr:write("<TextInput> Unhandled key: ", key, "\n")
		end
	end

	return true
end

function _M:onNewValue() end

function _M:onClick(event)
	self:setFocus()
end

function _M:onFocusChange()
	self.labelUpdate = true
end

function _M:setLabel(text, color)
	if text then
		self.labelText = text
	end

	if color then
		self.color = color
	end

	self.labelUpdate = true
end

function _M:update()
	Widget.update(self)

	local err

	if self.labelUpdate then
		local color = self.color or 0x000000
		if self.focused then
			self.label, err = self.root.fonts[1]:
				renderUtf8(self.labelText .. "_", "solid", color)
		else
			self.label, err = self.root.fonts[1]:
				renderUtf8(self.labelText, "solid", color)
		end

		if self.label then
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
		renderer:setDrawColor(0x77BBFF)
	else
		renderer:setDrawColor(0x44CCDD)
	end
	renderer:fillRect(rectangle)

	renderer:setDrawColor(0xFFFFFF)
	renderer:drawRect(rectangle)

	if self.labelTexture then
		local _, _, width, height = self.labelTexture:query()

		renderer:copy(self.labelTexture, nil, {
			x = self.x,
			y = self.y + (self.height - height) / 2,
			w = width, h = height
		})
	end

	self:drawChildren(renderer)
end

return Object(_M, Widget)

