-- UTIL.LUA CONTEXT
-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- util.lua
-- This file Provides some utility functions
local logger = require("logger");
local bit32 = {}; local N = 32; local P = 2 ^ N;
bit32.bnot=function(x)x=x%P;return(P-1)-x end;bit32.band=function(x,y)if(y==255)then return x%256 end;if(y==65535)then return x%65536 end;if(y==4294967295)then return x%4294967296 end;x,y=x%P,y%P;local r=0;local p=1;for i=1,N do local a,b=x%2,y%2;x,y=math.floor(x/2),math.floor(y/2)if((a+b)==2)then r=r+p end;p=2*p end;return r end;bit32.bor=function(x,y)if(y==255)then return(x-(x%256))+255 end;if(y==65535)then return(x-(x%65536))+65535 end;if(y==4294967295)then return 4294967295 end;x,y=x%P,y%P;local r=0;local p=1;for i=1,N do local a,b=x%2,y%2;x,y=math.floor(x/2),math.floor(y/2)if((a+b)>=1)then r=r+p end;p=2*p end;return r end;bit32.bxor=function(x,y)x,y=x%P,y%P;local r=0;local p=1;for i=1,N do local a,b=x%2,y%2;x,y=math.floor(x/2),math.floor(y/2)if((a+b)==1)then r=r+p end;p=2*p end;return r end;bit32.lshift=function(x,s_amount)if(math.abs(s_amount)>=N)then return 0 end;x=x%P;if(s_amount<0)then return math.floor(x*(2^s_amount))else return(x*(2^s_amount))%P end end;bit32.rshift=function(x,s_amount)if(math.abs(s_amount)>=N)then return 0 end;x=x%P;if(s_amount>0)then return math.floor(x*(2^-s_amount))else return(x*(2^-s_amount))%P end end;bit32.arshift=function(x,s_amount)if(math.abs(s_amount)>=N)then return 0 end;x=x%P;if(s_amount>0)then local add=0;if(x>=(P/2))then add=P-(2^(N-s_amount))end;return math.floor(x*(2^-s_amount))+add else return(x*(2^-s_amount))%P end end

local MAX_UNPACK_COUNT = 195;
local string_sub = string.sub
local string_char = string.char
local table_insert = table.insert
local math_random = math.random
local table_concat = table.concat
local string_format = string.format
local string_byte = string.byte
local math_floor = math.floor
local math_abs = math.abs
local math_log = math.log
local bit32_band = bit32.band
local bit32_rshift = bit32.rshift
local bit32_bor = bit32.bor
local bit32_lshift = bit32.lshift
local unpack = table.unpack or unpack
local newproxy = newproxy
local getmetatable = getmetatable
local pairs = pairs
local ipairs = ipairs
local type = type
local error = error
local math_fmod = math.fmod
local string_gmatch = string.gmatch

local function lookupify(tb)
    assert(type(tb) == "table", "Expected a table as argument")
    local tb2 = {}
    for _, v in ipairs(tb) do
        tb2[v] = true
    end
    return tb2
end

-- Use table constructor instead of table.insert
local function unlookupify(tb)
    assert(type(tb) == "table", "Expected a table as argument")
    local tb2 = {n = #tb}
    for v, _ in pairs(tb) do
        tb2[v] = _
    end
    return tb2
end

local function escape(str, shouldEscape)
    -- By default, escape all strings unless shouldEscape = false
    if shouldEscape == false then
        return str
    end
    assert(type(str) == "string", "Expected a string as argument")

    local escapeMap = {
        ["\\"] = "\\\\",
        ["\n"] = "\\n",
        ["\r"] = "\\r",
        ["\t"] = "\\t",
        ["\a"] = "\\a",
        ["\b"] = "\\b",
        ["\v"] = "\\v",
        ["\""] = "\\\"",
        ["\'"] = "\\\'"
    }

    return str:gsub(".", function(char)
        if char:match("[^ %-~\n\t\a\b\v\r\"\']") then -- Check if non Printable ASCII Character
            return string.format("\\%03d", string.byte(char))
        end
        return escapeMap[char] or char
    end)
end

local function keys(tb)
    local keyset={}
    local n=0
    for k,v in pairs(tb) do
        n=n+1
        keyset[n]=k
    end
    return keyset
end

local utf8char
do
    function utf8char(cp)
      if cp < 128 then
        return string_char(cp)
      end
      local suffix = cp % 64
      local c4 = 128 + suffix
      cp = (cp - suffix) / 64
      if cp < 32 then
        return string_char(192 + cp, c4)
      end
      suffix = cp % 64
      local c3 = 128 + suffix
      cp = (cp - suffix) / 64
      if cp < 16 then
        return string_char(224 + cp, c3, c4)
      end
      suffix = cp % 64
      cp = (cp - suffix) / 64
      return string_char(240 + cp, 128 + suffix, c3, c4)
    end
end

local function shuffle(tb)
    assert(type(tb) == "table", "Expected a table")
    for i = #tb, 2, -1 do
        local j = math.random(i)
        tb[i], tb[j] = tb[j], tb[i]
    end
    return tb
end

local function deepCopy(original, copies)
    copies = copies or {}
    if copies[original] then
        return copies[original]
    end

    local copy = {}
    copies[original] = copy
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = deepCopy(v, copies)
        end
        copy[k] = v
    end
    return copy
end

local function chararray(str)
    assert(type(str) == "string", "Expected a string")
    local result = {}
    for i = 1, #str do
        result[i] = str:sub(i, i)
    end
    return result
end

local function shuffle_string(str)
    local t = chararray(str)
    return table.concat(shuffle(t))
end

local function readDouble(bytes)
    assert(type(bytes) == "table", "Expected a table")
    local sign = 1
    local mantissa = bytes[2] % 2^4
    for i = 3, 8 do
        mantissa = mantissa * 256 + bytes[i]
    end
    if bytes[1] > 127 then sign = -1 end
    local exponent = (bytes[1] % 128) * 2^4 + math.floor(bytes[2] / 2^4)

    if exponent == 0 then
        return 0
    end
    mantissa = (mantissa * 2^-52 + 1) * sign
    return mantissa * 2^(exponent - 1023)
end

-- Avoid unnecessary calculations
local function writeDouble(num)
    assert(type(num) == "number", "Expected a number")
    local bytes = {0,0,0,0, 0,0,0,0}
    if num == 0 then
        return bytes
    end
    local anum = math.abs(num)
    local exponent = math.floor(math.log(anum, 2))
    local mantissa = anum / 2^exponent
    exponent = exponent + 1023
    local sign = num ~= anum and 128 or 0
    bytes[1] = sign + math.floor(exponent / 2^4)
    mantissa = mantissa * 2 - 1
    local currentmantissa
    for i= 3, 8 do
        mantissa = mantissa * 2^8
        currentmantissa = math.floor(mantissa)
        mantissa = mantissa - currentmantissa
        bytes[i] = currentmantissa
    end
    return bytes
end

local function writeU16(u16)
	if (u16 < 0 or u16 > 65535) then
		logger:error(string.format("u16 out of bounds: %d", u16));
	end
	local lower = bit32.band(u16, 255);
	local upper = bit32.rshift(u16, 8);
	return {lower, upper}
end

local function readU16(arr)
	return bit32.bor(arr[1], bit32.lshift(arr[2], 8));
end

local function writeU24(u24)
	if(u24 < 0 or u24 > 16777215) then
		logger:error(string.format("u24 out of bounds: %d", u24));
	end
	
	local arr = {};
	for i = 0, 2 do
		arr[i + 1] = bit32.band(bit32.rshift(u24, 8 * i), 255);
	end
	return arr;
end

local function readU24(arr)
	local val = 0;

	for i = 0, 2 do
		val = bit32.bor(val, bit32.lshift(arr[i + 1], 8 * i));
	end

	return val;
end

local function writeU32(u32)
	if(u32 < 0 or u32 > 4294967295) then
		logger:error(string.format("u32 out of bounds: %d", u32));
	end

	local arr = {};
	for i = 0, 3 do
		arr[i + 1] = bit32.band(bit32.rshift(u32, 8 * i), 255);
	end
	return arr;
end

local function readU32(arr)
	local val = 0;

	for i = 0, 3 do
		val = bit32.bor(val, bit32.lshift(arr[i + 1], 8 * i));
	end

	return val;
end

local unpack = table.unpack or unpack

local function bytesToString(arr)
    local length = arr.n or #arr;

    if length < MAX_UNPACK_COUNT then
        return string.char(unpack(arr))
    end

    local str = "";
    local overflow = length % MAX_UNPACK_COUNT;

    for i = 1, (#arr - overflow) / MAX_UNPACK_COUNT do
        str = str .. string.char(unpack(arr, (i - 1) * MAX_UNPACK_COUNT + 1, i * MAX_UNPACK_COUNT));
    end

    return str..(overflow > 0 and string.char(unpack(arr, length - overflow + 1, length)) or "");
end

local function isNaN(n)
	return type(n) == "number" and n ~= n;
end

local function isInt(n)
	return math.floor(n) == n;
end

local function isU32(n)
	return n >= 0 and n <= 4294967295 and isInt(n);
end

local function toBits(num)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
	local rest;
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return t
end


local function readonly(obj)
    local r = newproxy(true);
    local mt = getmetatable(r)
    mt.__index = obj;
    mt.__newindex = function(t, k, v)
        error("Attempted to modify read-only table")
    end
    return r;
end

local function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- local scriptId = uuid.generate() -- Assuming a UUID generation function
-- uuid function
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math_random(0, 0xf) or math_random(8, 0xb)
        return string_format('%x', v)
    end)
end

return {
    lookupify = lookupify,
    unlookupify = unlookupify,
    escape = escape,
    chararray = chararray,
    keys = keys,
    shuffle = shuffle,
    deepCopy = deepCopy,
    shuffle_string = shuffle_string,
    readDouble = readDouble,
    writeDouble = writeDouble,
    readU16 = readU16,
    writeU16 = writeU16,
    readU32 = readU32,
    writeU32 = writeU32,
    readU24 = readU24,
    writeU24 = writeU24,
    isNaN = isNaN,
    isU32 = isU32,
    isInt = isInt,
    utf8char = utf8char,
    toBits = toBits,
    bytesToString = bytesToString,
    readonly = readonly,
    contains = contains,
    uuid = uuid
}