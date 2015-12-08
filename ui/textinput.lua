
local sdl = require "SDL"
local ttf = require "SDL.ttf"

local Object = require "object"
local Widget = require "ui.widget"

local _M = {}

_M.knownKeys = {
	LeftParen = "(",
	RightParen = ")",
	Space = " ",
	Equals = "=",
	Percent = "%",
	Slash = "/",
	Asterisk = "*",
	Minus = "-",
	Plus = "+"
}

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
		if key == "Backspace" then
			if #self.labelText > 0 then
				self:setLabel(self.labelText:sub(1, #self.labelText - 1))
			end
		elseif #key == 1 then
			self:setLabel(self.labelText .. key)
		else
			local k = _M.knownKeys[key]

			if k then
				self:setLabel(self.labelText .. k)
			else
				io.stderr:write("<TextInput> Unhandled key: ", key, "\n")
			end
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

	local err

	if self.labelUpdate then
		self.label, err =
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

