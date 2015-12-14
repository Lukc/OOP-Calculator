
local lexer = require "parser.lexer"

local _M = {}

function _M.parse(input)
	local lexemes = lexer(input)

	local preParsedTree, err = _M.firstPass(lexemes)

	if preParsedTree then
		return _M.secondPass(preParsedTree)
	else
		return nil, err
	end
end

local firstPassExpressions = {}

firstPassExpressions[1] = {
	type = "parenthesis",
	parse = function(lexemes, start, _end)
		local str = lexemes[start].value
		local count = 1

		if str == "(" then
			for j = start + 1, _end do
				if lexemes[j].value == "(" then
					count = count + 1
				elseif lexemes[j].value == ")" then
					count = count - 1

					if count == 0 then
						return {
							value = _M.firstPass(lexemes, start + 1, j - 1),
							type = "sub-expression"
						}, j
					end
				end
			end

			return {
				type = "error",
				value = "unclosed parenthesis"
			}
		end
	end
}

firstPassExpressions[2] = {
	type = "function call",
	parse = function(lexemes, start, _end)
		local fname = lexemes[start]

		if fname.type == "symbol" then
			if lexemes[start+1] and lexemes[start+1].value == "(" then
				local count = 1

				for i = start + 2, _end do
					if lexemes[i].value == "(" then
						count = count + 1
					elseif lexemes[i].value == ")" then
						count = count - 1

						if count == 0 then
							local arg = {}

							count = 1
							local s = start + 2
							for j = start + 2, i do
								local c = lexemes[j].value
								if c == "(" then
									count = count + 1
								elseif c ==")" then
									count = count - 1
								end

								if count == 0 and (c == "," or c == ")") then
									arg[#arg + 1] =
										_M.firstPass(lexemes, s, j - 1)

									s = j + 1
								end
							end

							return {
								lvalue = fname.value,
								rvalue = arg,
								type = "function call"
							}, i
						end
					end
				end

				return {
					type = "error",
					value = "unclosed parenthesis"
				}
			end
		end
	end
}

function _M.firstPass(input, start, _end)
	start = start or 1
	_end = _end or #input

	local output = {}

	local index = start

	while index <= _end do
		local matched

		local i = 1
		while i <= #firstPassExpressions and not matched do
			local expression = firstPassExpressions[i]

			local value, newIndex = expression.parse(input, index, _end)

			if value then
				matched = true

				if value.type == "error" then
					return nil, value
				end

				index = newIndex + 1

				output[#output+1] = value

				--print("... matched")
			end

			i = i + 1
		end

		if not matched then
			print(input[index].value, "... ignored by pass 1")

			-- Keeping lexemes here.
			output[#output+1] = input[index]

			index = index + 1
		end
	end

	return output
end

local secondPassExpressions = {
	{
		type = "assignment",
		parse = function(lexemes, start, _end)
			for i = start, _end do
				local str = lexemes[i]

				if str == "=" then
					return {
						lvalue = _M.secondPass(lexemes, start, i - 1),
						rvalue = _M.secondPass(lexemes, i + 1, _end),
						type = "assignment"
					}
				end
			end
		end,
		eval = function(self, env)
			return _M.eval(self.rvalue, env)
		end
	},
	{
		type = "sum",
		parse = function(lexemes, start, _end)
			for i =  _end, start, -1 do
				local str = lexemes[i].value

				for _, char in pairs{"+"} do
					if str == char then
						return {
							lvalue = _M.secondPass(lexemes, start, i - 1),
							rvalue = _M.secondPass(lexemes, i + 1, _end),
							type = "sum"
						}
					end
				end
			end
		end,
		eval = function(self, env)
			return _M.eval(self.lvalue, env) + _M.eval(self.rvalue, env)
		end
	},
	{
		type = "subtraction",
		parse = function(lexemes, start, _end)
			for i =  _end, start, -1 do
				local str = lexemes[i].value

				for _, char in pairs{"-"} do
					if str == char then
						local lvalue
						if start <= i-1 then
							return {
								lvalue = _M.secondPass(lexemes, start, i-1),
								rvalue = _M.secondPass(lexemes, i + 1, _end),
								type = "subtraction"
							}
						else
							return {
								value = _M.secondPass(lexemes, i + 1, _end),
								type = "subtraction"
							}
						end
					end
				end
			end
		end,
		eval = function(self, env)
			if self.lvalue then
				return _M.eval(self.lvalue, env) - _M.eval(self.rvalue, env)
			else
				return - _M.eval(self.value, env)
			end
		end
	},
	{
		type = "product",
		parse = function(lexemes, start, _end)
			for i =  _end, start, -1 do
				local str = lexemes[i].value

				for _, char in pairs{"*", "×"} do
					if str == char then
						return {
							lvalue = _M.secondPass(lexemes, start, i - 1),
							rvalue = _M.secondPass(lexemes, i + 1, _end),
							type = "product"
						}
					end
				end
			end
		end,
		eval = function(self, env)
			return _M.eval(self.lvalue, env) * _M.eval(self.rvalue, env)
		end
	},
	{
		type = "quotient",
		parse = function(lexemes, start, _end)
			for i =  _end, start, -1 do
				local str = lexemes[i].value

				for _, char in pairs{"/", "÷", ":"} do
					if str == char then
						return {
							lvalue = _M.secondPass(lexemes, start, i - 1),
							rvalue = _M.secondPass(lexemes, i + 1, _end),
							type = "quotient"
						}
					end
				end
			end
		end,
		eval = function(self, env)
			return _M.eval(self.lvalue, env) / _M.eval(self.rvalue, env)
		end
	},
	{
		type = "modulo",
		parse = function(lexemes, start, _end)
			local char = "%"
			for i =  _end, start, -1 do
				local str = lexemes[i].value

				if str == char then
					return {
						lvalue = _M.secondPass(lexemes, start, i - 1),
						rvalue = _M.secondPass(lexemes, i + 1, _end),
						type = "modulo"
					}
				end
			end
		end,
		eval = function(self, env)
			return _M.eval(self.lvalue, env) % _M.eval(self.rvalue, env)
		end
	},
	{
		type = "power",
		parse = function(lexemes, start, _end)
			local char = "^"
			for i =  start, _end do
				local str = lexemes[i].value

				if str == char then
					return {
						lvalue = _M.secondPass(lexemes, start, i - 1),
						rvalue = _M.secondPass(lexemes, i + 1, _end),
						type = "power"
					}
				end
			end
		end,
		eval = function(self, env)
			return math.pow(_M.eval(self.lvalue, env), _M.eval(self.rvalue, env))
		end
	},
	{
		type = "function call",
		parse = function(lexemes, start, _end)
			if start == _end and lexemes[start].type == "function call" then
				local expr = lexemes[start]
				local arg = {}

				for i = 1, #expr.rvalue do
					arg[#arg+1] = _M.secondPass(expr.rvalue[i])
				end

				return {
					type = "function call",
					lvalue = expr.lvalue,
					rvalue = arg
				}
			end
		end,
		eval = function(self, env)
			local arg = {}

			for i = 1, #self.rvalue do
				arg[#arg+1] = _M.eval(self.rvalue[i], env)
			end

			return env[self.lvalue](table.unpack(arg))
		end
	},
	{
		type = "symbol",
		parse = function(lexemes, start, _end)
			if start == _end and lexemes[start].type == "symbol" then
				return lexemes[start]
			else
				print(lexemes[start].type, lexemes[start].value)
			end
		end,
		eval = function(self, env)
			return env[self.value] or (0 / 0) -- -nan
		end
	},
	{
		type = "number",
		parse = function(lexemes, start, _end)
			if start == _end and lexemes[start].type == "number" then
				return lexemes[start]
			else
				print(lexemes[start].type, lexemes[start].value)
			end
		end,
		eval = function(self)
			return tonumber(self.value)
		end
	},
	{
		type = "error",
		parse = function(lexemes, start, _end)
			if lexemes[start].type == "error" then
				return lexemes[start]
			end
		end,
		eval = function(self)
			return 0/0
		end
	}
}

secondPassExpressions[#secondPassExpressions+1] = {
		type = "virtual",
		parse = function(lexemes, start, _end)
			for i = 1, #secondPassExpressions do
				local type = secondPassExpressions[i].type

				if start == _end and lexemes[start].type == type then
					return lexemes[start]
				end
			end
		end
	}

function _M.secondPass(input, start, _end)
	start = start or 1
	_end = _end or #input

	if #input == 0 or start > _end then
		return {
			type = "error",
			value = "empty expression"
		}
	end

	local output

	for i = start, _end do
		local expr = input[i]

		if expr.type == "sub-expression" then
			input[i] = _M.secondPass(expr.value, 1, #expr.value)

			require("parser.pprint")(input[i])
		end
	end

	local i = 1
	while i <= #secondPassExpressions and not output do
		local expression = secondPassExpressions[i]

		output = expression.parse(input, start, _end)

		if output then
			if (not output.value and not (output.lvalue and output.rvalue))
				or output.type == "error"
				or (output.lvalue and output.lvalue.type == "error")
				or (output.rvalue and output.rvalue.type == "error" ) then
				print("Oh, shit…")

				-- FIXME: Properly return error value.
				return {
					type = "error",
					value = output.type == "error" and output.value
				}
			end
		end

		i = i + 1
	end

	if not output then
		print("[", start, "..", _end,  "]", "... not matched")
		io.write(" >> ")
		for i = start, _end do
			io.write(" ", tostring(input[i].value))
		end
		io.write("\n")

		return {
			type = "error",
			value = "unrecognized syntax"
		}
	end

	return output
end

function _M.eval(expr, env)
	for i = 1, #secondPassExpressions do
		local t = secondPassExpressions[i]

		if t.type == expr.type then
			return t.eval(expr, env)
		end
	end

	return
end

setmetatable(_M, {
	__call = function(self, ...)
		return _M.parse(...)
	end
})

--_M "w(t,f) = (4+7)/3.1415*cos(42 * t-pi/2 * f) - f^(t-3)"

return _M

