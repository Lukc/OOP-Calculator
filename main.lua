
local sdl = require "SDL"

local parser = require "parser.parser"
local ui = require "ui.init"

local _M = {}

local scaleX, scaleY = 1, 1
local drawData = {}

local fnames = {
	"f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t"
}

local colors = {
	0x660000, 0x006600, 0x000066, 0x666600, 0x660066, 0x006600, 0x666666
}

local function getFName(self)
	local n = #fnames

	for i = 1, #self.parent.children do
		if self.parent.children[i] == self then
			n = i
			break
		end
	end

	return fnames[n], colors[n % #colors]
end

function updateFormulaData(self)
	if self.labelText and #self.labelText > 0 then
		local t = parser(self.labelText)

		require("parser.pprint")(t)

		if t.type == "assignment" then
			print("Assignment syntax is still unsupported. :’(")
		else
			local f, color = getFName(self)

			drawData[f] = {
				color = color
			}
			self:setLabel(nil, color)

			local env = {}

			for key, value in pairs(math) do
				env[key] = value
			end

			local drawBox = self.root:getElementById("drawbox")
			local w = drawBox.realWidth
			local h = drawBox.realHeight
			local s = math.floor(-w / 2)
			local e = math.ceil( w / 2)

			local step = 0.25

			for i = s, e, step do
				env.x = i / scaleX
				drawData[f][i] = parser.eval(t, env) * scaleY

				-- To take care of floating point errors. 0.05px is ≃ 0px
				if i > s + 0.05 then
					local n1, n2 = drawData[f][i-step], drawData[f][i]
					local diff = math.abs(n1 - n2)

					local outOfScreen = n1 > h / 2 or n1 < - h / 2

					if diff > 1 and not outOfScreen then
						for j = i - step, i, 1 / math.max(diff, 25) do
							env.x = j / scaleX
							drawData[f][j] = parser.eval(t, env) * scaleY
						end
					end
				end
			end
		end
	end
end

function _M.FormulaeInput()
	return ui.TextInput {
		width = math.huge,
		height = 72,
		onNewValue = function(self, v)
			_M.cleanFormulaeTab(self.parent)

			updateFormulaData(self)
		end,
		update = function(self)
			if self.root.resized then
				updateFormulaData(self)
			end
		end,
		onEvent = function(self, event)
			if event.type == sdl.event.WindowEvent then
				updateFormulaData(self)
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

local function InputButton(arg)
	arg.onClick = function(self)
		local l = self.parent.parent.parent.children
		for i = 1, #l - 1 do
			local e = l[i]

			if e.focused then
				print("!!!")
				e:setLabel(e.labelText .. self.labelText)

				break
			end
		end

		print("Uhhh???")
	end

	return ui.Button(arg)
end

local function updateGraphics(s)
	local l = s.root:getElementById("formulaeList").children

	for i = 1, #l do
		updateFormulaData(l[i])
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

			-- Scale.
			-- XXX: Those Buttons should be Labels, but I was, like, REALLY too
			-- lazy to implement that properly (and to edit both TextInput and
			-- Buttons to inherit from them)
			ui.Button {
				width = 70, height = math.huge, label = "dx:"
			},
			ui.TextInput {
				width = 120, height = math.huge,
				label = "1", color = 0xFFFFFF,
				onNewValue = function(self, v)
					local nv = tonumber(v)

					if nv then
						scaleX = nv

						updateGraphics(self)
					else
						self:setLabel(tostring(scaleX))
					end
				end
			},
			ui.Button {
				width = 70, height = math.huge, label = "dy:"
			},
			ui.TextInput {
				width = 120, height = math.huge,
				label = "1", color = 0xFFFFFF,
				onNewValue = function(self, v)
					local nv = tonumber(v)

					if nv then
						scaleY = nv

						updateGraphics(self)
					else
						self:setLabel(tostring(scaleY))
					end
				end
			},
		},
		ui.Row {
			width = math.huge,
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
						InputButton { height = math.huge; width = 95; label = "+" },
						InputButton { height = math.huge; width = 95; label = "-" },
						InputButton { height = math.huge; width = 95; label = "/" },
						InputButton { height = math.huge; width = 95; label = "*" },
					},

					ui.Row {
						height = 72;
						width = math.huge;
						InputButton { height = math.huge; width = 95; label = "^" },
						InputButton { height = math.huge; width = 95; label = "cos" },
						InputButton { height = math.huge; width = 95; label = "sin" },
						InputButton { height = math.huge; width = 95; label = "tan" },
					},

					ui.Row {
						height = 72;
						width = math.huge;
						InputButton { height = math.huge; width = 95; label = "sqrt" },
						InputButton { height = math.huge; width = 95; label = "log" },
						InputButton { height = math.huge; width = 95; label = "log10" },
						InputButton { height = math.huge; width = 95; label = "abs" },
					},
				},

				update = function(self)
					self.realHeight = self.root.realHeight - 48
				end
			},
			ui.DrawBox {
				id = "drawbox",
				drawData = drawData,
				height = math.huge,
				-- Hack.
				onUpdate = function(self)
					self.realWidth =
						self.parent.realWidth - self.parent.children[1].realWidth
				end,
				onDraw = function(self, renderer)
					-- FIXME: We should be using its position and size
					--        instead of hardcoded offsets and the size
					--        of the whole fucking window.
					for f, values in pairs(drawData) do
						renderer:setDrawColor(values.color)

						for x, y in pairs(values) do
							if type(x) == "number" then
								local x = self.x + self.realWidth / 2 + x
								local y = self.y + self.realHeight / 2 - y

								if y > self.y then
									renderer:drawPoint {
										x = x,
										y = y
									}
								end
							end
						end
					end
				end
			},
		},
	}
}

while ui:run {w} do end

