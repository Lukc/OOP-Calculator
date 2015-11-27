
local sdl = require "SDL"
local ttf = require "SDL.ttf"

local Object = require "object"
local Widget = require "ui.widget"

local _M = {}

function _M:onEvent(event)                       
	if event.type == sdl.event.Quit then         
		os.exit(0)
	elseif event.windowID == self.window:getID() then
		for i = 1, #self.children do
			local child = self.children[i]

			local r = child:onEvent(event)

			if r then
				return
			end
		end
	end                                          
end                                              

local function registerRoot(root, element)
	element.root = root

	for i = 1, #element.children do
		local child = element.children[i]

		registerRoot(root, child)
	end
end

function _M:addChild(child)
	Widget.addChild(self, child)

	registerRoot(self, self)
end

function _M:update()
	self.realWidth, self.realHeight = self.window:getSize()

	self:updateChildren()
end

function _M:new(arg)
	Widget.new(self, arg)

	self.root = self
	self.focused = {}

	self.fonts = {}

	local r, err = sdl.init {
		sdl.flags.Video
	}

	if not r then
		return nil, err
	end

	r, err = ttf.init()

	if not r then
		return nil, err
	end

	self.window, err = sdl.createWindow {
		flags = arg.flags,
		title = arg.title,

		width = arg.width,
		height = arg.height
	}

	if not self.window then
		return nil, err
	end

	self.renderer, err = sdl.createRenderer(self.window, -1)

	if not self.renderer then
		return nil, err
	end

	-- Default font. In case nothing else could be found later.
	self.fonts[1], err = ttf.open("DejaVuSans.ttf", 36)

	if not self.fonts[1] then
		print(err)
	end

	self.window:setMinimumSize(arg.minWidth or 0, arg.minHeight or 0)
end

return Object(_M, Widget)

