
local sdl = require "SDL"

local Object = require "object"

local _M = {}

-- Default values. Better not rely on those.
_M.width = nil
_M.height = nil

_M.realWidth = 0
_M.realHeight = 0

_M.x = 0
_M.y = 0

function _M:addChild(child)
	self.children[#self.children+1] = child
	child.parent = self

	return self
end

function _M:drawChildren(renderer)
	for i = 1, #self.children do
		local child = self.children[i]

		if child then
			child:draw(renderer)
		end
	end
end

function _M:draw(renderer)
	renderer:setDrawColor(0xFF0000)
	renderer:drawRect {
		w = self.realWidth,
		h = self.realHeight,
		x = self.x,
		y = self.y
	}

	self:drawChildren(renderer)
end

function _M:updateChildren()
	for i = 1, #self.children do
		local child = self.children[i]

		if child then
			child:update()
		end
	end
end

function _M:clickHandler(event)
	if event.type == sdl.event.MouseButtonUp then
		local isIn =
			event.x >= self.x and
			event.x < self.x + self.realWidth and
			event.y >= self.y and
			event.y < self.y + self.realHeight

		if isIn then
			if self.onClick then
				r = self:onClick(event)

				if not r then
					r = true
				end
			end

			if not r then
				for i = 1, #self.children do
					local child = self.children[i]

					r = child:clickHandler(event)

					if r then
						return r
					end
				end
			end
		end
	end
end

function _M:keyboardHandler(event)
	if event.type == sdl.event.KeyUp and self.focused then
		local r

		if self.onKeyUp then
			r = self:onKeyUp(event)

			if not r then
				r = true
			end
		end

		if not r then
			for i = 1, #self.children do
				local child = self.children[i]

				if child.focused then
					r = child:keyboardHandler(event)

					if r then
						return r
					end
				end
			end
		end
	end
end

function _M:onEvent(event)
	for i = 1, #self.children do
		local child = self.children[i]
		local r

		r = child:clickHandler(event)

		if not r then
			r = child:keyboardHandler(event)
		end

		if not r then
			-- Generic/Unknown event handler.
			r = child:onEvent(event)
		end

		if r then
			return r
		end
	end
end

function _M:update()
	if self.width == math.huge then
		self.realWidth = self.parent.realWidth
	end

	if self.height == math.huge then
		self.realHeight = self.parent.realHeight
	end

	if self.customUpdate then
		self:customUpdate()
	end

	self:updateChildren()
end

function _M:setFocus()
	local root = self.root

	for i = 1, #root.focused do
		root.focused[i].focused = false
		root.focused[i] = nil
	end

	local e = self
	while e.parent do
		e.focused = true

		root.focused[#root.focused+1] = e

		e = e.parent
	end
end

function _M:new(arg)
	self.children = {}

	-- Will probably be useful for top-level elements. Much less for
	-- the others.
	self.ids = {}

	for i = 1, #arg do
		self:addChild(arg[i])
	end

	for _, key in pairs {"height", "width"} do
		self[key] = arg[key]
	end

	self.customUpdate = arg.update

	if self.height then
		self.realHeight = self.height
	end

	if self.width then
		self.realWidth = self.width
	end
end

return Object(_M)

