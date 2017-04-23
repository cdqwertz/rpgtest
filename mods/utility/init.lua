utility = {}

utility.debugEnabled = false
function utility.debug(target)
	if not utility.debugEnabled then return end
	if type(target) == "string" then
		print(tostring(target))
	elseif type(target) == "number" then
		print(tostring(target))
	elseif type(target) == "table" then
		for key, value in ipairs(target) do
			print(tostring(key) .. tostring(' -> ') .. tostring(value))
		end
	elseif type(target) == "userdata" then
		local _t = getmetatable(target)
		print(_t)
		for key, value in ipairs(_t) do
			print(tostring(key) .. tostring(' -> ') .. tostring(value))
		end
	elseif type(target) == "nil" then
		print(tostring(target))
	elseif type(target) == "boolean" then
		print(tostring(target))
	else
		print(tostring('cannot print "' .. tostring(type(target)) .. tostring("type")))
	end
end
