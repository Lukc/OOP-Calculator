
local lexer = require "parser.lexer"

local _M = {}

function _M.parse(input)
	local lexemes = lexer(input)

	local preParsedTree = _M.firstPass(lexemes)

	return _M.secondPass(preParsedTree)
end

local firstPassExpressions = {
	{
		type = "Parenthesis",
		parse = function(lexemes, start, _end)
			local str = lexemes[start].value

			if str == "(" then
				for j = start + 1, _end do
					if lexemes[j].value == ")" then
						return {
							value = _M.firstPass(lexemes, start + 1, j - 1),
							type = "sub-expression"
						}, j
					end
				end

				return {
					value = "error",
					type = "unclosed parenthesis"
				}
			end
		end
	}
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
		end
	},
	{
		type = "sum",
		parse = function(lexemes, start, _end)
			for i =  _end, start, -1 do
				local str = lexemes[i].value

				for _, char in pairs{"+", "-"} do
					if str == char then
						return {
							lvalue = _M.secondPass(lexemes, start, i - 1),
							rvalue = _M.secondPass(lexemes, i + 1, _end),
							type = char == "+" and
								"sum" or "subtraction"
						}
					end
				end
			end
		end
	},
	{
		type = "product",
		parse = function(lexemes, start, _end)
			for i =  _end, start, -1 do
				local str = lexemes[i].value

				for _, char in pairs{"*", "/"} do
					if str == char then
						return {
							lvalue = _M.secondPass(lexemes, start, i - 1),
							rvalue = _M.secondPass(lexemes, i + 1, _end),
							type = char == "*" and
								"product" or "quotient"
						}
					end
				end
			end
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

setmetatable(_M, {
	__call = function(self, ...)
		return _M.parse(...)
	end
})

--_M "w(t,f) = (4+7)/3.1415*cos(42 * t-pi/2 * f) - f^(t-3)"

return _M

