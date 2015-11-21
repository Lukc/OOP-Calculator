
local rex = require "rex_posix"

local _M = {}

local function lex(str)
	local lexemes = {}

	for i in rex.gmatch(str, "([a-zA-Z]+|[()]|[a-zA-Z0-9]+|[0-9]+\\.[0-9]*|[+-/*−÷×=])") do
		lexemes[#lexemes+1] = i
	end

	return lexemes
end

local Assignment = {
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

local Product = {
	parse = function(lexemes, start, _end)
		for i = start, _end do
			local str = lexemes[i]

			for _, char in pairs{"*", "/", "÷", "×"} do
				if str == char then
					return {
						lvalue = _M.parse(lexemes, start, i - 1),
						rvalue = _M.parse(lexemes, i + 1, _end),
						type = char
					}
				end
			end
		end
	end
}

local Sum = {
	parse = function(lexemes, start, _end)
		for i = start, _end do
			local str = lexemes[i]

			for _, char in pairs{"+", "-", "−"} do
				if str == char then
					return {
						lvalue = _M.parse(lexemes, start, i - 1),
						rvalue = _M.parse(lexemes, i + 1, _end),
						type = char
					}
				end
			end
		end
	end
}

local FunctionCall = {
	parse = function(lexemes, start, _end)
		for i = start, _end - 1 do
			local fname = lexemes[i]
			local par = lexemes[i+1]

			if fname:match("%a") and par == "(" then
				for j = i + 2, _end do
					if lexemes[j] == ")" then
						local iscoma = false
						local parameters = {}
						local paramStart = i + 2
						for k = i + 2, j do
							if lexemes[k] == "," or lexemes[k] == ")" then
								parameters[#parameters+1] =
									_M.parse(lexemes, paramStart, k - 1)

								paramStart = k + 1
							end
						end

						return {
							type = "function call",
							value = fname,
							parameters = parameters
						}
					end
				end

				return {
					type = "error",
					value = "invalid function call"
				}
			end
		end
	end
}

local Parenthesis = {
	parse = function(lexemes, start, _end)
		for i = start, _end do
			local str = lexemes[i]

			if str == "(" then
				for j = i + 1, _end do
					if lexemes[j] == ")" then
						return {
							value = _M.parse(lexemes, i + 1, j - 1),
							type = "priority thing"
						}
					end
				end

				return {
					value = "error",
					type = "unclosed parenthesis"
				}
			end
		end
	end
}

local Number = {
	parse = function(lexemes, start, _end)
		for i = start, _end do
			local str = lexemes[i]

			local n = tonumber(str)

			if n then
				return {
					type = "number",
					value = n
				}
			end
		end
	end
}

local Variable = {
	parse = function(lexemes, start, _end)
		for i = start, _end do
			local str = lexemes[i]

			if str:match("%a") then
				return {
					type = "variable",
					value = str
				}
			end
		end
	end
}

-- Note: sorted by priority. Higher priorities first.
local expressions = {
	Assignment,
	Product,
	FunctionCall,
	Parenthesis,
	Sum,
	Number,
	Variable
}

-- FIXME: grooming
--   - Make a separate function for each and every single syntaxic element
--     we’re trying to identify.
function _M.parse(lexemes, start, _end)
	if not start then start = 1 end
	if not _end then _end = #lexemes end

	for _, e in pairs(expressions) do
		local element = e.parse(lexemes, start, _end)

		if element then
			return element
		end
	end

	return {
		type = "error",
		value = "could not parse"
	}
end

local pprint = require "pprint"

pprint(_M.parse(lex("f(x, y) = (43 + 2.5) / 4 * cos(2)")))

