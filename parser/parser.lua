
local lexer = require "lexer"

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
			print(input[index].value, "... not matched")

			-- Keeping lexemes here.
			output[#output+1] = input[index]

			index = index + 1
		end
	end

	return output
end

local secondPassExpressions = {
	{
		type = "Assignment",
		parse = function(lexemes, start, _end)
			for i = start, _end do
				local str = lexemes[i]

				if str == "=" then
					return {
						lvalue = _M.parse(lexemes, start, i - 1),
						rvalue = _M.parse(lexemes, i + 1, _end),
						type = "assignment"
					}
				end
			end
		end
	}
}

function _M.secondPass(input)
	require("pprint")(input)
end

setmetatable(_M, {
	__call = function(self, ...)
		return _M.parse(...)
	end
})

_M "w(t,f) = (4+7)/3.1415*cos(42 * t-pi/2 * f) - f^(t-3)"

return _M

