-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- namegenerators/mangled.lua
-- Enhanced for better obfuscation, now even more enhanced

local util = require("Prometheus.util");
local chararray = util.chararray;

-- Extended character array for more obfuscation strength, cautiously selected
local VarDigits = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_");
local VarStartDigits = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");

-- More complex hash function to mix id, scope and time for a truly unpredictable seed
local function complexHash(id, scope)
	local hash = os.time()
	for i = 1, #id do
		hash = (hash * 33 + id:byte(i)) % 2147483648
	end
	for i = 1, #scope do
		hash = (hash * 33 + scope:byte(i)) % 2147483648
	end
	return hash
end

return function(id, scope)
	-- Securely seed the random number generator
	math.randomseed(complexHash(tostring(id), scope))

	util.shuffle(VarDigits);
	util.shuffle(VarStartDigits);

	local name = ''
	local seed = complexHash(tostring(id), scope) -- Using complexHash for seed generation
	local dynamicLengthFactor = (seed % 10) + 5 -- Now varies from 5 to 14 additional characters

	local d = seed % #VarStartDigits
	id = (seed - d) / #VarStartDigits
	name = name .. VarStartDigits[d + 1]
	while id > 0 do
		local d = id % #VarDigits
		id = (id - d) / #VarDigits
		name = name .. VarDigits[d + 1]
	end

	-- Inserting multiple random characters in a more unpredictable pattern
	for _ = 1, math.random(3, 6) do -- Between 2 and 6 additional random inserts
		local randomChar = VarDigits[math.random(1, #VarDigits)]
		local position = math.random(1, #name + 1)
		name = name:sub(1, position - 1) .. randomChar .. name:sub(position)
	end

	-- Introducing a complex condition for additional unpredictability
	if (#scope + seed) % 4 == 0 then
		name = name:gsub(".", function(c) return VarDigits[math.random(1, #VarDigits)] end) -- More intense randomization
	end

	-- Append 'random' characters with an updated logic based on dynamicLengthFactor
	for i = 1, dynamicLengthFactor do
		local extChar = VarDigits[math.random(1, #VarDigits)]
		name = name .. extChar
	end

	return name
end
