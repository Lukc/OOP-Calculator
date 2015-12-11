
local sdl = require "SDL"

local parser = require "parser.parser"
local ui = require "ui.init"

local _M = {}

function _M.FormulaeInput()
	return ui.TextInput {
		width = math.huge,
		height = 72,
		onNewValue = function(self, v)
			_M.cleanFormulaeTab(self.parent)

			if #self.labelText > 0 then
				print(parser.parse(self.labelText))
			end
		end
	}
end

function _M.cleanFormulaeTab(e)
	for i = 2, #e.children - 1 do
		local child = e.children[i]

		if child.labelText == "" then
			e:removeChild(child)

			break
		end
	end

	local child = e.children[#e.children]
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
				id = "drawbox"
				-- Drawing curves here.
			},
		},
	}
}

while ui:run {w} do end

