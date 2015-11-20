
local rex = require "rex_posix"

local function lex(str)
	local lexemes = {}

	for i in rex.gmatch(str, "([a-zA-Z]+|[()]|[a-zA-Z0-9]+|[0-9]+\\.[0-9]*|[+-/*−÷×=])") do
		print(i)

		lexemes[#lexemes+1] = i
	end

	return lexemes
end

-- FIXME: grooming
--   - Make a separate function for each and every single syntaxic element
--     we’re trying to identify.
local function parse(lexemes, start, _end)
	if not start then start = 1 end
	if not _end then _end = #lexemes end

	for i = start, _end do
		local str = lexemes[i]

		if str == "=" then
			return {
				lvalue = parse(lexemes, start, i - 1),
				rvalue = parse(lexemes, i + 1, _end),
				type = "assignment"
			}
		end
	end

	for i = start, _end do
		local str = lexemes[i]

		for _, char in pairs{"*", "/", "÷", "×"} do
			if str == char then
				return {
					lvalue = parse(lexemes, start, i - 1),
					rvalue = parse(lexemes, i + 1, _end),
					type = char
				}
			end
		end
	end

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
								parse(lexemes, paramStart, k - 1)

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
				value = "error"
			}
		end
	end

	for i = start, _end do
		local str = lexemes[i]

		if str == "(" then
			for j = i + 1, _end do
				if lexemes[j] == ")" then
					return {
						value = parse(lexemes, i + 1, j - 1),
						type = "priority thing"
					}
				end
			end

			return {
				value = "error",
				type = "error"
			}
		end
	end

	for i = start, _end do
		local str = lexemes[i]

		for _, char in pairs{"+", "-"} do
			if str == char then
				return {
					lvalue = parse(lexemes, start, i - 1),
					rvalue = parse(lexemes, i + 1, _end),
					type = char
				}
			end
		end
	end

	for i = start, _end do
		local str = lexemes[i]

		local n = tonumber(str)

		if type(n) == "number" then
			return {
				type = "number",
				value = n
			}
		end
	end

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

local function pprint(t, i)
	if not i then i = 0 end

	if type(t) == "table" then
		io.write("{\n")

		for var in pairs(t) do
			for j = 1, i + 1 do
				io.write("  ")
			end
			io.write("[" .. tostring(var) .. "] = ")
			pprint(t[var], i + 1)
		end

		for j = 1, i do
			io.write("  ")
		end
		io.write("}\n")
	else
		io.write(tostring(t))
	end

	io.write("\n")
end

pprint(parse(lex("f(x, y) = (43 + 2.5) / 4 * cos(2)")))

