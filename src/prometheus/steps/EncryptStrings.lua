-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- EncryptStrings.lua
--
-- This Script provides a Simple Obfuscation Step that encrypts strings

local Step                        = require("Prometheus.step")
local Ast                         = require("Prometheus.ast")
local Parser                      = require("Prometheus.parser")
local Enums                       = require("Prometheus.enums")
local visitast                    = require("Prometheus.visitast");
local util                        = require("Prometheus.util")
local AstKind                     = Ast.AstKind;

local EncryptStrings              = Step:extend()
EncryptStrings.Description        = "This Step will encrypt strings within your Program."
EncryptStrings.Name               = "Encrypt Strings"
EncryptStrings.SettingsDescriptor = {}

-- Custom random number generator
local function create_mersenne_twister(seed)
    local MT = {}
    local index = 0
    local bit32 = {}; local N = 32; local P = 2 ^ N;
    bit32.bnot=function(x)x=x%P;return(P-1)-x end;bit32.band=function(x,y)if(y==255)then return x%256 end;if(y==65535)then return x%65536 end;if(y==4294967295)then return x%4294967296 end;x,y=x%P,y%P;local r=0;local p=1;for i=1,N do local a,b=x%2,y%2;x,y=math.floor(x/2),math.floor(y/2)if((a+b)==2)then r=r+p end;p=2*p end;return r end;bit32.bor=function(x,y)if(y==255)then return(x-(x%256))+255 end;if(y==65535)then return(x-(x%65536))+65535 end;if(y==4294967295)then return 4294967295 end;x,y=x%P,y%P;local r=0;local p=1;for i=1,N do local a,b=x%2,y%2;x,y=math.floor(x/2),math.floor(y/2)if((a+b)>=1)then r=r+p end;p=2*p end;return r end;bit32.bxor=function(x,y)x,y=x%P,y%P;local r=0;local p=1;for i=1,N do local a,b=x%2,y%2;x,y=math.floor(x/2),math.floor(y/2)if((a+b)==1)then r=r+p end;p=2*p end;return r end;bit32.lshift=function(x,s_amount)if(math.abs(s_amount)>=N)then return 0 end;x=x%P;if(s_amount<0)then return math.floor(x*(2^s_amount))else return(x*(2^s_amount))%P end end;bit32.rshift=function(x,s_amount)if(math.abs(s_amount)>=N)then return 0 end;x=x%P;if(s_amount>0)then return math.floor(x*(2^-s_amount))else return(x*(2^-s_amount))%P end end;bit32.arshift=function(x,s_amount)if(math.abs(s_amount)>=N)then return 0 end;x=x%P;if(s_amount>0)then local add=0;if(x>=(P/2))then add=P-(2^(N-s_amount))end;return math.floor(x*(2^-s_amount))+add else return(x*(2^-s_amount))%P end end

    MT[0] = seed
    for i = 1, 623 do
        MT[i] = bit32.band((0x6c078965 * bit32.bxor(MT[i - 1], bit32.rshift(MT[i - 1], 30)) + i), 0xffffffff)
    end

    local function generate_numbers()
        for i = 0, 623 do
            local y = bit32.bor(bit32.band(MT[i], 0x80000000), bit32.band(MT[(i + 1) % 624], 0x7fffffff))
            MT[i] = bit32.bxor(MT[(i + 397) % 624], bit32.rshift(y, 1))
            if y % 2 ~= 0 then -- y is odd
                MT[i] = bit32.bxor(MT[i], 0x9908b0df)
            end
        end
    end

    local function extract_number()
        if index == 0 then
            generate_numbers()
        end

        local y = MT[index]
        y = bit32.bxor(y, bit32.rshift(y, 11))
        y = bit32.bxor(y, bit32.band(bit32.lshift(y, 7), 0x9d2c5680))
        y = bit32.bxor(y, bit32.band(bit32.lshift(y, 15), 0xefc60000))
        y = bit32.bxor(y, bit32.rshift(y, 18))

        index = (index + 1) % 624
        return y
    end

    return extract_number
end

local mersenne_twister = create_mersenne_twister(os.time())

function EncryptStrings:init(settings) end

function EncryptStrings:CreateEncrypionService()
    local usedSeeds = {};
    local generator = create_mersenne_twister(mersenne_twister())
    local secret_key_6 = generator() % (2^16) -- Increased range
    local secret_key_7 = generator() % 256
    local modulus = 2 ^ 32
    local secret_key_44 = generator() % modulus
    local secret_key_8 = generator() % (2^16) -- Increased range
    local secret_key_9 = generator() % (2^16) -- Increased range, new secret key
    local floor = math.floor
    local primitive_root_257_cache = {}
    for idx = 0, 255 do
        local g, m, d = 1, 128, 2 * idx + 1
        repeat
            g, m, d = g * g * (d >= m and 3 or 1) % 257, m / 2, d % m
        until m < 1
        primitive_root_257_cache[idx] = g
    end
    local param_mul_8 = primitive_root_257_cache[secret_key_7]
    local param_mul_45 = secret_key_6 * 4 + 1
    local param_add_45 = secret_key_44 * 2 + 1
    local state_45 = 0
    local state_8 = 2
    local prev_values = {}
    local function set_seed(seed_53)
        state_45 = seed_53 % modulus
        state_8 = seed_53 % 255 + 2
        prev_values = {}
    end
    local function gen_seed()
        local seed;
        repeat
            seed = floor(generator() % modulus);
        until not usedSeeds[seed];
        usedSeeds[seed] = true;
        return seed;
    end
    local function get_random_32()
        state_45 = (state_45 * param_mul_45 + param_add_45) % modulus
        local r
        repeat
            state_8 = state_8 * param_mul_8 % 257
            r = state_8 % 32
        until state_8 ~= 1
        local n = floor(state_45 / 2 ^ (13 - (state_8 - r) / 32)) % 2 ^ 32 / 2 ^ r
        return floor(n % 1 * 2 ^ 32) + floor(n)
    end
    local function get_next_pseudo_random_byte()
        if #prev_values == 0 then
            local rnd = get_random_32()
            local low_16 = rnd % 65536
            local high_16 = (rnd - low_16) / 65536
            local b1 = low_16 % 256
            local b2 = (low_16 - b1) / 256
            local b3 = high_16 % 256
            local b4 = (high_16 - b3) / 256
            prev_values = { b1, b2, b3, b4 }
        end
        return table.remove(prev_values)
    end
    local function join(tbl)
        local str = ""
        for i = 1, #tbl do
            str = str .. tbl[i]
        end
        return str
    end

    local function encrypt(str)
        local salt = generator() % 256 -- Generate a salt
        local seed = gen_seed() + #str + salt; -- Incorporate salt into seed generation
        set_seed(seed)
        local out = {}
        local prevVal = secret_key_8;
        for i = 1, #str do
            local byte = str:byte(i);
            local encryptedByte = (byte - (get_next_pseudo_random_byte() + prevVal)) % 256
            out[i] = string.char(encryptedByte);
            prevVal = byte;
        end
        return join(out), seed, salt;
    end

    local function genCode(param_mul_45, param_add_45, param_mul_8, secret_key_8, secret_key_9) -- Updated function signature
        local code = [[
    do
        local function join(tbl)
            local str = ""
            for i = 1, #tbl do
                str = str .. tbl[i]
            end
            return str
        end

        local floor = math.floor
        local random = math.random;
        local table = table;
        local remove = table.remove;
        local char = string.char;
        local state_45 = 0
        local state_8 = 2
        local digits = {}
        local charmap = {};
        local i = 0;

        local nums = {};
        for i = 1, 256 do
            nums[i] = i;
        end

        repeat
            local idx = random(1, #nums);
            local n = remove(nums, idx);
            charmap[n] = char(n - 1);
        until #nums == 0;

        local prev_values = {}
        local function get_next_pseudo_random_byte()
            if #prev_values == 0 then
                state_45 = (state_45 * ]] ..
            tostring(param_mul_45) .. [[ + ]] .. tostring(param_add_45) .. [[) % ]] .. tostring(modulus) .. [[
                repeat
                    state_8 = state_8 * ]] .. tostring(param_mul_8) .. [[ % 257
                until state_8 ~= 1
                local r = state_8 % 32
                local n = floor(state_45 / 2 ^ (13 - (state_8 - r) / 32)) % 2 ^ 32 / 2 ^ r
                local rnd = floor(n % 1 * 2 ^ 32) + floor(n)
                local low_16 = rnd % 65536
                local high_16 = (rnd - low_16) / 65536
                local b1 = low_16 % 256
                local b2 = (low_16 - b1) / 256
                local b3 = high_16 % 256
                local b4 = (high_16 - b3) / 256
                prev_values = { b1, b2, b3, b4 }
            end
            return remove(prev_values)
        end

        local realStrings = {};
        STRINGS = setmetatable({}, {
            __index = realStrings;
            __metatable = nil;
        });
        function DECRYPT(str, seed)
            local realStringsLocal = realStrings;
            local prevVal = ]] .. tostring(secret_key_8) .. [[;
            if not realStringsLocal[seed] then
                prev_values = {};
                local chars = charmap;
                state_45 = seed % ]] .. tostring(modulus) .. [[
                state_8 = seed % 255 + 2
                local len = #str;
                local realStringsLocalTable = {};
                for i=1, len do
                    local byte = str:byte(i)
                    prevVal = (byte + get_next_pseudo_random_byte() + prevVal) % 256
                    realStringsLocalTable[i] = chars[prevVal + 1];
                end
                realStringsLocal[seed] = join(realStringsLocalTable);
            end
            if type(realStringsLocal[seed]) == table then
                local encryptedConstant = realStringsLocal[seed]
                local decryptedConstant = ""
                for i = 1, #encryptedConstant do
                    local c = encryptedConstant:sub(i,i)
                    local byte = c:byte()
                    local decryptedByte = (byte - (get_next_pseudo_random_byte() + prevVal)) % 256
                    decryptedConstant = decryptedConstant .. charmap[decryptedByte + 1]
                end
                realStringsLocal[seed] = decryptedConstant
            end
            return seed;
        end
    end]]

        return code;
    end

    return {
        encrypt = encrypt,
        param_mul_45 = param_mul_45,
        param_mul_8 = param_mul_8,
        param_add_45 = param_add_45,
        secret_key_8 = secret_key_8,
        secret_key_9 = secret_key_9,
        genCode = genCode,
    }
end

function EncryptStrings:apply(ast, pipeline)
    local Encryptor = self:CreateEncrypionService();
    local code = Encryptor.genCode(Encryptor.param_mul_45, Encryptor.param_add_45, Encryptor.param_mul_8,
        Encryptor.secret_key_8);

    local newAst, doStat, scope, decryptVar, stringsVar = self:initializeVariables(code, ast)

    self:visitNewAst(newAst, scope, decryptVar, stringsVar)
    self:visitAst(ast, scope, stringsVar, decryptVar, Encryptor)

    -- Insert to Main Ast
    self:insertToMainAst(ast, doStat, decryptVar, stringsVar)

    -- Additional code to encrypt variables and functions
    visitast(ast, function(node, parent)
        if node.kind == AstKind.Var or node.kind == AstKind.Function then
            local encrypted, seed = Encryptor.encrypt(node[1])
            node[1] = encrypted
            node[2] = seed
        end
    end)

    return ast
end

function EncryptStrings:initializeVariables(code, ast)
    local newAst = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 }):parse(code);
    local doStat = newAst.body.statements[1];
    local scope = ast.body.scope;
    local decryptVar = scope:addVariable();
    local stringsVar = scope:addVariable();
    local shuffledVars = util.shuffle { decryptVar, stringsVar }
    
    -- Assign shuffled variables back to decryptVar and stringsVar
    decryptVar = shuffledVars[1]
    stringsVar = shuffledVars[2]

    doStat.body.scope:setParent(ast.body.scope);
    return newAst, doStat, scope, decryptVar, stringsVar
end

function EncryptStrings:visitNewAst(newAst, scope, decryptVar, stringsVar)
    visitast(newAst, nil, function(node, data)
        self:handleFunctionDeclaration(node, data, scope, decryptVar)
        self:handleAssignmentVariable(node, data, scope, stringsVar)
    end)
end

function EncryptStrings:handleFunctionDeclaration(node, data, scope, decryptVar)
    if (node.kind == AstKind.FunctionDeclaration) then
        if (node.scope:getVariableName(node.id) == "DECRYPT") then
            data.scope:removeReferenceToHigherScope(node.scope, node.id);
            data.scope:addReferenceToHigherScope(scope, decryptVar);
            node.scope = scope;
            node.id    = decryptVar;
        end
    end
end

function EncryptStrings:handleAssignmentVariable(node, data, scope, stringsVar)
    if (node.kind == AstKind.AssignmentVariable or node.kind == AstKind.VariableExpression) then
        if (node.scope:getVariableName(node.id) == "STRINGS") then
            data.scope:removeReferenceToHigherScope(node.scope, node.id);
            data.scope:addReferenceToHigherScope(scope, stringsVar);
            node.scope = scope;
            node.id    = stringsVar;
        end
    end
end

function EncryptStrings:visitAst(ast, scope, stringsVar, decryptVar, Encryptor)
    visitast(ast, nil, function(node, data)
        if (node.kind == AstKind.StringExpression) then
            data.scope:addReferenceToHigherScope(scope, stringsVar);
            data.scope:addReferenceToHigherScope(scope, decryptVar);
            local encrypted, seed = Encryptor.encrypt(node.value);
            return Ast.IndexExpression(Ast.VariableExpression(scope, stringsVar),
                Ast.FunctionCallExpression(Ast.VariableExpression(scope, decryptVar), {
                    Ast.StringExpression(encrypted), Ast.NumberExpression(seed),
                }));
        end
    end)
end

function EncryptStrings:insertToMainAst(ast, doStat, decryptVar, stringsVar)
    local scope = ast.body.scope; -- Define scope here
    local shuffledVars = util.shuffle { decryptVar, stringsVar }
    table.insert(ast.body.statements, 1, doStat);
    table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(scope, shuffledVars, {}));
end

return EncryptStrings
