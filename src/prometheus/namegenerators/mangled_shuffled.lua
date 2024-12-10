-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- namegenerators/mangled_shuffled.lua
--
-- This Script provides a function for generation of mangled names with shuffled character order


local util = require("Prometheus.util");
local chararray = util.chararray;

local VarDigits = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_");
local VarStartDigits = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");

local function generateName(id, scope)
    local name = ''
    local d1 = id % #VarStartDigits
    id = (id - d1) / #VarStartDigits
    name = name .. VarStartDigits[d1 + 1]
    while id > 0 do
        local d2 = id % #VarDigits
        id = (id - d2) / #VarDigits
        name = name .. VarDigits[d2 + 1]
    end
    return name
end

local function prepare(ast)
	util.shuffle(VarDigits);
	util.shuffle(VarStartDigits);
end

return {
	generateName = generateName,
	prepare = prepare
};
