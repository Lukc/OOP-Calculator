
---
-- Primitive object/class implementation.
-- Does simple inheritance, makes constructors easy to define, and that’s about
-- it. Basically, it’s an automated metatables generator.
---

return function(class, parent)
	setmetatable(class, {
		__call = function(self, ...)
			local instance = {}

			setmetatable(instance, {
				__index = class
			})
			
			local r = class.new(instance, ...)

			return r or instance
		end,

		__index = parent
	})

	return class
end

