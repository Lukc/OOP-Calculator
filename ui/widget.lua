
local Object = require "object"

local _M = {}

-- Default values. Better not rely on those.
_M.width = nil
_M.height = nil

_M.realWidth = 0
_M.realHeight = 0

_M.x = 0
_M.y = 0

function _M:getRoot()
	local element = self

	while element.parent do
		element = element.parent
	end

	return element
end

function _M:addChild(child)
	self.children[#self.children+1] = child
	child.parent = self

	if child.id then
		self:getRoot().ids[child.id] = child
	end

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

