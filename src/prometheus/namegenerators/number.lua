-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- Ultra Enhanced version of namegenerators/number.lua
-- Provides top-tier obfuscation with extensive dynamic elements, complex hex conversion, and vastly unpredictable patterns.

local function dynamicPrefix(id)
	local prefixes = { "_", "$", "O", "X", "Z", "^", "L", "!", "#", "%", "&", "*", ">", "<", "=", "+", "-", ":", ";", "'",
		"[", "]", "{", "}" }
	local randomIndex = math.random(1, #prefixes)
	local complexityIncrease = id * os.time() % 13 -- Introduced complexity based on time
	return prefixes[((id + randomIndex * complexityIncrease % #prefixes) % #prefixes) + 1]
end

local function Hex(id)
	local hex, salt = "", ((id % 13 + 7) * math.random(3, 9)) % 20 -- Further complex salting
	id = (id * math.random(2, 7) + salt) ^ 2                    -- Additional complexity with square
	while id > 0 do
		local remainder = (id + salt) % 16
		local charCodeOffset = remainder < 10 and 48 or 55
		charCodeOffset = charCodeOffset + math.random(-3, 3) -- Maintained broad range of randomness
		hex = string.char(math.max(48, math.min(90, charCodeOffset + remainder))) .. hex
		id = math.floor((id - salt) / 16)
		salt = ((salt * 2) % 20 - 10) * math.random(2, 5) -- Increased dynamic salt modification
	end
	hex = hex == "" and "G" or hex                  -- Changed default non-zero value
	return hex
end

local function additionalCharacters(id, length)
	length = length * math.random(2, 4) +
	math.floor(math.log(id + 1) / math.log(3))                                    -- Increased dynamic length and changed base of logarithm
	local validChars = { "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "+", "=", "/", "|", "[", "]", "{", "}",
		":",
		";", "'", ",", ".", "<", ">", "?", "`", "~" }
	local extra = ""
	for i = 1, length do
		local index = ((id * i * 11) + math.random(1, #validChars)) % #validChars +
		1                                                                       -- Increased complexity in character selection
		extra = extra .. validChars[index]
	end
	return extra
end

local function ultimateEntropy(id, scope)
	-- New function to introduce another layer of entropy into the generated names
	local entropyFactor = #scope % 5 + math.random(1, #scope % 7) -- Entropy factor based on scope length and randomness
	local entropyString = ""
	for i = 1, entropyFactor do
		entropyString = entropyString ..
		string.char(math.random(33, 126))                            -- Generating random ASCII characters for entropy
	end
	return entropyString
end

return function(id, scope)
	-- Seed the random number generator using more sources of entropy
	math.randomseed(os.time() + tonumber(tostring({}):match("0x%x+"), 16) + id + #scope)
	local prefix = dynamicPrefix(id)
	local hex = Hex(id + #scope + os.clock())                   -- Incorporate the length of 'scope' and process time for variability.
	local extraChars = additionalCharacters(id, math.random(5, 8)) -- Increased variability in additional character length.
	local entropy = ultimateEntropy(id, scope)                  -- Apply the new layer of entropy
	return prefix .. hex .. extraChars .. entropy
end
