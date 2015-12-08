
local sdl = require "SDL"

local ui = require "ui.init"

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

				-- Tests. Should be text input boxes.
				ui.TextInput { width = math.huge, height = 72 },
				ui.TextInput { width = math.huge, height = 72 },
				ui.TextInput { width = math.huge, height = 72 },

				update = function(self)
					self.realHeight = self.root.realHeight - 48
				end
			},
			ui.DrawBox {
				id = "drawbox"
				-- Drawing curves here.
			}
		}
	}
}

while ui:run {w} do end

