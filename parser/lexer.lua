
local rex = require "rex_posix"

local _M = {}

local lexemes = {
	{
		type = "operator",
		pattern = "[+-/*=^÷−%]"
	},
	{
		type = "symbol",
		pattern = "[a-zA-Z]+[a-zA-Z0-9]*"
	},
	{
		type = "number",
		pattern = "([0-9]+|[0-9]+\\.[0-9]*)"
	},
	{
		type = "parenthesis",
		pattern = "[()]"
	},
	{
		type = "separator",
		pattern = ","
	},
	{
		type = "space",
		pattern = "[[:space:]]",
		-- We sort of don’t care about keeping track of spaces.
		fake = true
	}
}

function _M.lex(input)
	local output = {}

	local inputIndex = 1

	while #input > 0 do
		local matched

		local i = 1
		while i <= #lexemes and not matched do
			local lexeme = lexemes[i]
			local match = rex.match(input, "^" .. lexeme.pattern)

			if match and match ~= "" then
				input = input:sub(#match + 1, #input)

				inputIndex = inputIndex + #match

				if not lexeme.fake then
					output[#output+1] = {
						type = lexeme.type,
						value = match
					}

					--print(
					--	string.format("%10s", lexeme.type),
					--	inputIndex, "'"..match.."'", "-", input)
				end

				matched = true
			end

			i = i + 1
		end

		if not matched then
			io.stderr:write("<lexer.lex> Unexpected characters or smthing.\n")
			return {
				type = "error", 
				value = "unexpected character(s)",
				at = inputIndex,
			}
		end
	end

	return output
end

setmetatable(_M, {
	__call = function(self, ...)
		return _M.lex(...)
	end
})

return _M

