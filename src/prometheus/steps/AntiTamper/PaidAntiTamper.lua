-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- PaidAntiTamper.lua
--
-- This script adds PaidAntiTamper code to the script to prevent tampering. When tampering is detected, the script will stop executing.
local Step = require("Prometheus.step");
local Parser = require("Prometheus.parser");
local Enums = require("Prometheus.enums");
local EncryptStrings = require("Prometheus.steps.EncryptStrings");
local WrapInFunction = require("Prometheus.steps.WrapInFunction");

-- Initialize the steps
local wrapInFunctionStep = WrapInFunction:new()

local PaidAntiTamper = Step:extend();
PaidAntiTamper.Description =
"This step adds PaidAntiTamper code to the script to prevent tampering. When tampering is detected, the script will stop executing.";
PaidAntiTamper.Name = "Anti Tamper";

function PaidAntiTamper:init(settings) end

function PaidAntiTamper:apply(ast, pipeline)
    local code = "do local valid = true;";

    code = code .. [[
            -- Initialize multiple error handling functions with different messages and types
            local err1 = function() originalError({msg = "Tampering detected. Please contact the owner of this script for a new version."}) while true do end end
            local err2 = function() originalError("Tampering detected. Error code: " .. math.random(1000, 9999)) while true do end end
            local err3 = function() originalError(function() return "Tampering detected. This incident will be reported." end) while true do end end
            local errFuncs = {err1, err2, err3}
            local err = errFuncs[math.random(1, #errFuncs)]
        ]]

    -- anti over write code ..
    local antiOverwriteCode = [[
-- Store the original error function in a local variable
local originalError = error
-- Store the original functions in local variables
local originalPairs = pairs
local originalSetmetatable = setmetatable
local originalGetmetatable = getmetatable
local originalType = type
local originalLoad = load
local originalLoadstring = loadstring
local originalPcall = pcall
local originalMathRandom = math.random
local originalXpcall = xpcall
local originalDebug = debug
local originalDebugGetinfo = debug.getinfo
-- Store the original tables in local variables
local originalPackage = package
local originalCoroutine = coroutine
local originalString = string

local originalMath = math
local originalTable = table
local originalOs = os
local originalIo = io
local originalFile = file
local AntiOverwrite = {}
local originalGlobals = {}
for k, v in originalPairs(_G) do
    originalGlobals[k] = v
end

local function protect(t)
    local mt = {
        __index = t,
        __newindex = function(t, k, v)
            if originalGlobals[k] then
                err()
            else
                originalGlobals[k] = v
            end
        end,
        __metatable = false,
        __gc = function()
            err()
        end,
        __mode = "k",
        __call = function()
            err()
        end,
        __len = function()
            err()
        end,
        __pairs = function()
            err()
        end,
        __ipairs = function()
            err()
        end,
        __debug = function()
            err()
        end,
        __tostring = function()
            err()
        end,
        __concat = function()
            err()
        end,
        __unm = function()
            err()
        end,
        __add = function()
            err()
        end,
        __sub = function()
            err()
        end,
        __mul = function()
            err()
        end,
        __div = function()
            err()
        end,
        __mod = function()
            err()
        end,
        __pow = function()
            err()
        end,
        __eq = function()
            err()
        end,
        __lt = function()
            err()
        end,
        __le = function()
            err()
        end,
    }
    return originalSetmetatable({}, mt)
end

function AntiOverwrite.protectGlobals()
    for k, v in originalPairs(_G) do
        if originalType(v) == "function" then
            originalGlobals[k] = v
        end
    end
    _G = protect(originalGlobals)
    originalSetmetatable(_G, {
        __metatable = "This metatable is locked."
    })
end

function AntiOverwrite.protectTable(t)
    return protect(t)
end

function AntiOverwrite.protectFunction(f)
    local protectedFunction = function(...)
        return f(...)
    end
    return originalSetmetatable({}, {
        __index = function(t, k)
            if k == '__call' then
                return protectedFunction
            else
                err()
            end
        end,
        __newindex = function(t, k, v)
            err()
        end,
        __metatable = false,
        __gc = function()
            err()
        end,
        __mode = "k",
        __call = function()
            err()
        end,
        __len = function()
            err()
        end,
        __pairs = function()
            err()
        end,
        __ipairs = function()
            err()
        end,
        __debug = function()
            err()
        end,
    })
end

-- Check for hooking attempts
if error ~= originalError or pairs ~= originalPairs or setmetatable ~= originalSetmetatable or getmetatable ~= originalGetmetatable or type ~= originalType or load ~= originalLoad or loadstring ~= originalLoadstring or pcall ~= originalPcall or xpcall ~= originalXpcall or debug ~= originalDebug or package ~= originalPackage or coroutine ~= originalCoroutine or string ~= originalString or math ~= originalMath or table ~= originalTable then
    err()
end

-- Add checks to ensure that the pcall and math.random functions have not been tampered with
if pcall ~= originalPcall or math.random ~= originalMathRandom then
    err()
end

-- List of critical global variables that should not be changed
local criticalGlobals = {"os", "io", "file", "debug"}

-- Check for environment tampering
for _, v in ipairs(criticalGlobals) do
    if _G[v] ~= originalGlobals[v] then
        err()
    end
end

-- Check for debug hooks only if not in Roblox's Luau
local success, result = pcall(originalDebug.gethook)
if success then
    if result then
        err()
    end
end

local gmatch = string.gmatch
local status, pcallErr = pcall(main)

-- Check for changes in the metatable of critical global variables
for _, v in ipairs(criticalGlobals) do
    if getmetatable(_G[v]) ~= getmetatable(originalGlobals[v]) then
        err()
    end
end

]]

    code = code .. antiOverwriteCode

    local PaidAntiTamperCode = [[

local pcallIntact2 = false;
local pcallIntact = originalPcall(function()
    pcallIntact2 = true;
end) and pcallIntact2;



local random = math.random
local tblconcat = table.concat;
local unpkg = table and table.unpack or unpack;
n = originalMathRandom(3, 65)
if n < 3 or n > 65 then
    local a = random(1, 2^24) - RandomStrings.randomString() ^ random(1, 2^24)
    return RandomStrings.randomString() / a;
end
local acc1 = 0;
local acc2 = 0;
local pcallRet = {pcall(function() local a = random(1, 2^24) - RandomStrings.randomString() ^ random(1, 2^24) return RandomStrings.randomString() / a; end)};
local origMsg = pcallRet[2];
local line = tonumber(gmatch(tostring(origMsg), ':(%d*):')());

for i = 1, 100 do
    local len = 100;
    local n2 = i % 256;
    local pos = i % len + 1;
    local shouldErr = i % 2 == 0;
    local msg = origMsg:gsub(':(%d*):', ':' .. tostring(random(0, 10000)) .. ':');
    local arr = {pcall(function()
        if random(1, 2) == 1 or i == n then
            local line2 = tonumber(gmatch(tostring(({pcall(function() local a = random(1, 2^24) - RandomStrings.randomString() ^ random(1, 2^24) return RandomStrings.randomString() / a; end)})[2]), ':(%d*):')());
            valid = valid and line == line2;
        end
        if shouldErr then
            error(msg, 0);
        end
        local arr = {};
        for i = 1, len do
            arr[i] = random(0, 255);
        end
        arr[pos] = n2;
        return unpkg(arr);
    end)};
    if shouldErr then
        valid = valid and arr[1] == false and arr[2] == msg;
    else
        valid = valid and arr[1];
        acc1 = (acc1 + arr[pos + 1]) % 256;
        acc2 = (acc2 + n2) % 256;
    end
end

valid = valid and acc1 == acc2;

if valid then else
    repeat
        return (function()
            -- tamper detected
            err()
        end)()
    until true;
    return;
end
end
        ]]
    code = code .. PaidAntiTamperCode;

    local parsed = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 }):parse(code);
    local doStat = parsed.body.statements[1];
    doStat.body.scope:setParent(ast.body.scope);
    table.insert(ast.body.statements, 2, doStat); -- Insert after the first statement

    -- Encrypt the PaidAntiTamper code
    local encryptStringsStep = EncryptStrings:new()
    ast = encryptStringsStep:apply(ast, pipeline)

    -- Apply the WrapInFunction step
    ast = wrapInFunctionStep:apply(ast, pipeline)

    return ast
end

return PaidAntiTamper;
