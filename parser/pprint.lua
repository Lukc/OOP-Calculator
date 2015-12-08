
---
-- A pretty printer for our parsed tree.
--
-- May be extented into a more general-purpose pretty printer later, but that’s
-- really not something we should be willing to spend much time on.
--

local function indent(n)
	for i = 1, n do
		io.write("   ")
	end
end

local function pprint(t, i)
	if not i then i = 0 end

	if type(t) == "table" then
		io.write("{\n")

		for _, key in pairs {"type", "value", "lvalue", "rvalue", "parameters"} do
			if t[key] then
				indent(i + 1)

				io.write(string.format("%-5s = ",
					tostring(key)))
				pprint(t[key], i + 1)
			end
		end

		for j = 1, #t do
			indent(i + 1)

			io.write("[", tostring(j), "] = ")
			pprint(t[j], i + 1)
		end

		indent(i)
		io.write("}")
	elseif type(t) == "string" then
		io.write("\"", t, "\"")
	else
		io.write(tostring(t))
	end

	io.write("\n")
end

return pprint

