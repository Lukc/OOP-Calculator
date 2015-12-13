
local sdl = require "SDL"

local parser = require "parser.parser"
local ui = require "ui.init"

local _M = {}

local drawData = {}

local fnames = {
	"f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t"
}

local function getFName(self)
	local n = #fnames

	for i = 1, #self.parent.children do
		if self.parent.children[i] == self then
			n = i
			break
		end
	end

	return fnames[n]
end

function _M.FormulaeInput()
	return ui.TextInput {
		width = math.huge,
		height = 72,
		onNewValue = function(self, v)
			_M.cleanFormulaeTab(self.parent)

			if #self.labelText > 0 then
				local t = parser(self.labelText)

				require("parser.pprint")(t)

				if t.type == "assignment" then
					print("Assignment syntax is still unsupported. :’(")
				else
					local f = getFName(self)

					drawData[f] = {}

					local w = self.root.realWidth
					local s = math.floor(- w / 2)
					local e = math.floor(  w / 2)

					for i = s, e, 0.1 do
						drawData[f][i] = parser.eval(t, {x = i})
					end
				end
			end
		end
	}
end

function _M.cleanFormulaeTab(e)
	local start = #e.children == 1 and 2 or 1

	for i = start, #e.children - 1 do
		local child = e.children[i]

		if child.labelText == "" then
			local f = getFName(child)

			drawData[f] = nil

			e:removeChild(child)

			break
		end
	end

	local child = e.children[#e.children-1]
	if child.labelText ~= "" then
		e:addChild(_M.FormulaeInput{})

		local c = e.children
		local tmp = c[#c]
		c[#c] = c[#c-1]
		c[#c-1] = tmp
	end
end

local w = ui.Window {
	title = "Calooplator",
	flags = { sdl.window.Resizable },

	minWidth = 800,
	minHeight = 600,

	onExit = function() os.exit(0) end,

	ui.Column {
		width = math.huge,
		height = math.huge,

		ui.Row {
			id = "infobar",

			-- Generic info about stuff, here.
			-- For example, number of displayed curves and scale.
			height = 48,
			width = math.huge,

			-- Tests. Should be text boxes/labels.
			ui.Button { width = 120, height = math.huge, label = "Test" },
			ui.Widget { width = 120, height = math.huge },
			ui.Widget { width = 120, height = math.huge },
		},
		ui.Row {
			ui.Column {
				id = "formulaeList",

				width = 380,
				-- Add curves’ data here.
				-- Formulae, at least. Edition boxes would be nice as well.

				_M.FormulaeInput(),

				ui.Column {
					width = math.huge;
					height = math.huge;

					x = 0;

					ui.Row {
						height = 72;
						width = math.huge;
						ui.Button { height = math.huge; width = 95; label = "+" },
						ui.Button { height = math.huge; width = 95; label = "-" },
						ui.Button { height = math.huge; width = 95; label = "/" },
						ui.Button { height = math.huge; width = 95; label = "*" },
					},

					ui.Row {
						height = 72;
						width = math.huge;
						ui.Button { height = math.huge; width = 95; label = "^" },
						ui.Button { height = math.huge; width = 95; label = "cos" },
						ui.Button { height = math.huge; width = 95; label = "sin" },
						ui.Button { height = math.huge; width = 95; label = "tan" },
					},

					ui.Row {
						height = 72;
						width = math.huge;
						ui.Button { height = math.huge; width = 95; label = "sqrt" },
						ui.Button { height = math.huge; width = 95; label = "log" },
						ui.Button { height = math.huge; width = 95; label = "ln" },
						ui.Button { height = math.huge; width = 95; label = "*" },
					},
				},

				update = function(self)
					self.realHeight = self.root.realHeight - 48
				end
			},
			ui.DrawBox {
				id = "drawbox",
				drawData = drawData,
				onDraw = function(self, renderer)
					-- FIXME: We should be using its position and size
					--        instead of hardcoded offsets and the size
					--        of the whole fucking window.
					for f, values in pairs(drawData) do
						renderer:setDrawColor(0x000000)

						for x, y in pairs(values) do
							local x = 380 + self.root.realWidth / 2 + x
							local y = 48 + self.root.realHeight / 2 - y

							if y > 48 then
								renderer:drawPoint {
									x = x,
									y = y
								}
							end
						end
					end
				end
			},
		},
	}
}

while ui:run {w} do end

