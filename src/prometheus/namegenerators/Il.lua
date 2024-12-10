-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- namegenerators/il.lua
--
-- This Script provides a function for generation of weird names consisting of I, l and 1
-- Modified to enhance obfuscation strength and unpredictability by incorporating a stronger algorithm for character generation

local MIN_CHARACTERS = 5;
local MAX_INITIAL_CHARACTERS = 20; -- Broadened the range for initial characters

local util = require("Prometheus.util");
local chararray = util.chararray;

local function dynamicOffset(id, scope)
	-- Enhanced non-linear formula for dynamic offset calculation
	local baseOffset = (5 ^ ((MIN_CHARACTERS + #scope) % 5)) * math.sin(id);       -- Non-linear transformation
	local adjustment = (id % 13 + #scope % 13 + math.floor(os.clock() * 1000)) % 111; -- Improved unpredictability
	return (baseOffset + adjustment) % 2147483647;                                 -- Modulo with a prime number
end

-- Expanding the character set further with additional visually ambiguous characters and special symbols
local VarDigits = chararray("Il1Oo0S5Z2E3A4G6T7B8D9PCQRVXYNKUMWHJF_|!@#$%&");
local VarStartDigits = chararray("IlOo0S5Z2_|!@#$%&"); -- Including special characters for starting characters

local function generateName(id, scope)
	local name = ''
	local offset = dynamicOffset(id, scope); -- Use enhanced dynamic offset
	id = id + offset;
	local d = id % #VarStartDigits;
	id = (id - d) / #VarStartDigits;
	name = name .. VarStartDigits[d + 1];
	while id > 0 do
		local d = id % #VarDigits;
		id = (id - d) / #VarDigits;
		name = name .. VarDigits[d + 1];
	end
	-- Adding complexity with a dynamic adjustment for the name length using a non-linear strategy
	name = name ..
		string.rep(VarDigits[math.random(1, #VarDigits)],
			math.random(MIN_CHARACTERS, id % 15 + scope:len() % 15 + MIN_CHARACTERS))
	return name
end

local function prepare(ast)
    util.shuffle(VarDigits); -- Shuffling methods to increase unpredictability
    util.shuffle(VarStartDigits);
    -- Enhancing unpredictability with a dynamic baseline offset
    local offset = math.random(5 ^ MIN_CHARACTERS, 5 ^ (MAX_INITIAL_CHARACTERS + #ast % 5));
end

return {
	generateName = generateName,
	prepare = prepare
};
