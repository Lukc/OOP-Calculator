
local sdl = require "SDL"

local Object = require "object"

local Widget    = require "ui.widget"
local Window    = require "ui.window"
local Column    = require "ui.column"
local Row       = require "ui.row"
local DrawBox   = require "ui.drawbox"
local Button    = require "ui.button"
local TextInput = require "ui.textinput"

local _M = {
	Widget    = Widget,
	Window    = Window,
	Column    = Column,
	Row       = Row,
	DrawBox   = DrawBox,
	Button    = Button,
	TextInput = TextInput
}

function _M:run(elements)
	for e in sdl.pollEvent() do
		local i = 1
		while i <= #elements do
			local element = elements[i]

			if element:onEvent(e) then
				i = #elements
			else
				i = i + 1
			end
		end
	end

	for i = 1, #elements do
		local element = elements[i]

		if element.update then
			element:update()
		end
	end

	for i = 1, #elements do
		local element = elements[i]

		element.renderer:setDrawColor(0xFFFFFF)
		element.renderer:clear()
		--[[element.renderer:drawRect {
			w = element.realWidth,
			h = element.realHeight,
			x = 0, y = 0
		}]]

		if element.draw then
			element:draw(element.renderer)
		end

		element.renderer:present()
	end

	return true
end

return _M

