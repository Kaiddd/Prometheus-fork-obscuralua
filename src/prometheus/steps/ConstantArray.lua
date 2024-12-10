-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- ConstantArray.lua
--
-- This Script provides a Simple Obfuscation Step that wraps the entire Script into a function

-- TODO: Wrapper Functions
-- TODO: Proxy Object for indexing: e.g: ARR[X] becomes ARR + X

local Step                       = require("Prometheus.step");
local Ast                        = require("Prometheus.ast");
local Scope                      = require("Prometheus.scope");
local visitast                   = require("Prometheus.visitast");
local util                       = require("Prometheus.util")
local Parser                     = require("Prometheus.parser");
local enums                      = require("Prometheus.enums")
local EncryptStrings             = require("Prometheus.steps.EncryptStrings")
local LuaVersion                 = enums.LuaVersion;
local AstKind                    = Ast.AstKind;

local ConstantArray              = Step:extend();
ConstantArray.Description        =
"This Step will Extract all Constants and put them into an Array at the beginning of the script";
ConstantArray.Name               = "Constant Array";

ConstantArray.SettingsDescriptor = {
	Treshold = {
		name = "Treshold",
		description = "The relative amount of nodes that will be affected",
		type = "number",
		default = 1,
		min = 0,
		max = 1,
	},
	StringsOnly = {
		name = "StringsOnly",
		description = "Wether to only Extract Strings",
		type = "boolean",
		default = false,
	},
	Shuffle = {
		name = "Shuffle",
		description = "Wether to shuffle the order of Elements in the Array",
		type = "boolean",
		default = true,
	},
	Rotate = {
		name = "Rotate",
		description = "Wether to rotate the String Array by a specific (random) amount. This will be undone on runtime.",
		type = "boolean",
		default = true,
	},
	LocalWrapperTreshold = {
		name = "LocalWrapperTreshold",
		description = "The relative amount of nodes functions, that will get local wrappers",
		type = "number",
		default = 1,
		min = 0,
		max = 1,
	},
	LocalWrapperCount = {
		name = "LocalWrapperCount",
		description =
		"The number of Local wrapper Functions per scope. This only applies if LocalWrapperTreshold is greater than 0",
		type = "number",
		min = 0,
		max = 512,
		default = 0,
	},
	LocalWrapperArgCount = {
		name = "LocalWrapperArgCount",
		description = "The number of Arguments to the Local wrapper Functions",
		type = "number",
		min = 1,
		default = 10,
		max = 200,
	},
	MaxWrapperOffset = {
		name = "MaxWrapperOffset",
		description = "The Max Offset for the Wrapper Functions",
		type = "number",
		min = 0,
		default = 65535,
	},
	Encoding = {
		name = "Encoding",
		description = "The Encoding to use for the Strings",
		type = "enum",
		default = "random",
		values = {
			"none",
			"base64",
			"hexadecimal",
			"url",
			"random",
		},
	}
};

local function callNameGenerator(generatorFunction, ...)
	if (type(generatorFunction) == "table") then
		generatorFunction = generatorFunction.generateName;
	end
	return generatorFunction(...);
end

function ConstantArray:init(settings)

end

function ConstantArray:createTable(size)
    local t = {}
    for i = 1, size do
        t[i] = nil
    end
    -- Introduce random delays to confuse attackers
    for i = 1, math.random(1, 10) do
        table.insert(t, math.random(1, size), nil)
    end
    return t
end

function ConstantArray:createArray()
    -- Dynamic Table Size Adjustment
    local sizeFactor = math.random(1, 3)
    local adjustedSize = #self.constants * sizeFactor

    if self.cachedEntries and self.cachedConstants == self.constants then
        return self.cachedEntries
    end

    local entries = self.cachedEntries or self:createTable(adjustedSize)
    local encodeStrategies = {self.encode, self.complexEncode}

    for i, v in pairs(self.constants) do
        -- Variable Entry Encoding
        local encodeFunc = encodeStrategies[math.random(#encodeStrategies)]
        if type(v) == "string" then
            v = encodeFunc(self, v)
        end
        table.insert(entries, Ast.TableEntry(Ast.ConstantNode(v)))

        if math.random() > 0.5 then
            table.insert(entries, Ast.TableEntry(Ast.ConstantNode(v)))
        end
    end

    self:complexShuffle(entries)

    self.cachedEntries = Ast.TableConstructorExpression(entries)
    self.cachedConstants = self.constants

    return self.cachedEntries
end

-- Additional functions for the new features
function ConstantArray:complexEncode(value)
    -- A more complex encoding strategy for strings
    local encoded = ""
    for i = 1, #value do
        local char = value:sub(i, i)
        if math.random() > 0.5 then
            encoded = encoded .. char:upper()
        else
            encoded = encoded .. char:lower()
        end
    end
    return encoded
end

function ConstantArray:complexShuffle(entries)
    for i = #entries, 2, -1 do
        local j = math.random(1, i)
        entries[i], entries[j] = entries[j], entries[i]
    end
    for i = 1, math.random(1, 10) do
        table.insert(entries, math.random(1, #entries), entries[i])
    end
end


function ConstantArray:addToConstants(value)
    if self.lookup[value] then
        return
    end
    local idx = #self.constants + 1
    table.insert(self.constants, value)
    self.lookup[value] = idx
end

function ConstantArray:getConstant(value, data)
    self:addToConstants(value)
    return Ast.IndexExpression(Ast.VariableExpression(self.rootScope, self.arrId), Ast.NumberExpression(self.lookup[value]))
end

function ConstantArray:addConstant(value)
    self:addToConstants(value)
end

local function reverse(t, i, j)
    while i < j do
        t[i], t[j] = t[j], t[i]
        i, j = i + 1, j - 1
    end
end

local function rotate(t, d, n)
    n = n or #t
    d = (d or 1) % n
    reverse(t, 1, n)
    reverse(t, 1, d)
    reverse(t, d + 1, n)
end

local rotateCode = [=[
    for i, v in ipairs({{1, %d}, {1, %d}, {%d + 1, %d}}) do
        while v[1] < v[2] do
            ARR[v[1]], ARR[v[2]], v[1], v[2] = ARR[v[2]], ARR[v[1]], v[1] + 1, v[2] - 1
        end
    end
]=]

function ConstantArray:addRotateCode(ast, shift)
    local parser = Parser:new({ LuaVersion = LuaVersion.Lua51 })
    local newAst = parser:parse(string.format(rotateCode, #self.constants, shift, shift, #self.constants))
    local forStat = newAst.body.statements[1]
    forStat.body.scope:setParent(ast.body.scope)
    visitast(newAst, nil, function(node, data)
        if node.kind == AstKind.VariableExpression then
            if node.scope:getVariableName(node.id) == "ARR" then
                data.scope:removeReferenceToHigherScope(node.scope, node.id)
                data.scope:addReferenceToHigherScope(self.rootScope, self.arrId)
                node.scope = self.rootScope
                node.id = self.arrId
            end
        end
    end)
    table.insert(ast.body.statements, 1, forStat)
end

function ConstantArray:addDecodeCode(ast)
    if self.Encoding == "base64" then
        local base64DecodeCode = [[
    do ]] .. table.concat(util.shuffle {
            "local lookup = LOOKUP_TABLE;",
            "local len = string.len;",
            "local sub = string.sub;",
            "local floor = math.floor;",
            "local strchar = string.char;",
            "local insert = table.insert;",
            "local concat = table.concat;",
            "local type = type;",
            "local arr = ARR;",
        }) .. [[
        for i = 1, #arr do
            local data = arr[i];
            if type(data) == "string" then
                if len(data) % 4 ~= 0 or data:match("[^A-Za-z0-9+/=]") then
                    error("Invalid base64 string " .. tostring(math.random()))
                end
                local length = len(data)
                local parts = {}
                local index = 1
                local value = 0
                local count = 0
                while index <= length do
                    local char = sub(data, index, index)
                    local code = lookup[char]
                    if code then
                        value = value + code * (64 ^ (3 - count))
                        count = count + 1
                        if count == 4 then
                            count = 0
                            local c1 = floor(value / 65536)
                            local c2 = floor(value % 65536 / 256)
                            local c3 = value % 256
                            insert(parts, strchar(c1, c2, c3))
                            value = 0
                        end
                    elseif char == "=" then
                        insert(parts, strchar(floor(value / 65536)))
                        if index >= length or sub(data, index + 1, index + 1) ~= "=" then
                            insert(parts, strchar(floor(value % 65536 / 256)))
                        end
                        break
                    end
                    index = index + 1
                end
                arr[i] = concat(parts)
            end
        end
    end
        ]]

        local parser = Parser:new({ LuaVersion = LuaVersion.Lua51 })
        local newAst = parser:parse(base64DecodeCode)
        local forStat = newAst.body.statements[1]
        forStat.body.scope:setParent(ast.body.scope)

        visitast(newAst, nil, function(node, data)
            if node.kind == AstKind.VariableExpression then
                if node.scope:getVariableName(node.id) == "ARR" then
                    data.scope:removeReferenceToHigherScope(node.scope, node.id)
                    data.scope:addReferenceToHigherScope(self.rootScope, self.arrId)
                    node.scope = self.rootScope
                    node.id = self.arrId
                end

                if node.scope:getVariableName(node.id) == "LOOKUP_TABLE" then
                    data.scope:removeReferenceToHigherScope(node.scope, node.id)
                    return self:createBase64Lookup()
                end
            end
        end)

        table.insert(ast.body.statements, 1, forStat)
    end
end

function ConstantArray:createBase64Lookup()
    local entries = {}
    for i = 1, #self.base64chars do
        local char = self.base64chars:sub(i, i)
        table.insert(entries, Ast.KeyedTableEntry(Ast.StringExpression(char), Ast.NumberExpression(i - 1)))
    end
    util.shuffle(entries)
    return Ast.TableConstructorExpression(entries)
end

function ConstantArray:encode(str)
    if self.Encoding == "random" then
        local encodings = { "base64", "hexadecimal", "url" }
        self.Encoding = encodings[math.random(#encodings)]
        print("Encoding type: " .. self.Encoding)
    end
    if self.Encoding == "base64" then
        local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        return ((str:gsub('.', function(x)
            local r, b = '', x:byte()
            for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
            return r
        end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if (#x < 6) then return '' end
            local c = 0
            for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
            return b:sub(c + 1, c + 1)
        end) .. ({ '', '==', '=' })[#str % 3 + 1])
    elseif self.Encoding == "hexadecimal" then
        return (str:gsub('.', function(c)
            return string.format('%02X', string.byte(c))
        end))
    elseif self.Encoding == "url" then
        return (str:gsub("[^%w%-_%.~]", function(c)
            return string.format("%%%02X", string.byte(c))
        end))
    end
end

function ConstantArray:reverseConstants()
    local i, j = 1, #self.constants
    while i < j do
        self.constants[i], self.constants[j] = self.constants[j], self.constants[i]
        i = i + 1
        j = j - 1
    end
end

function ConstantArray:apply(ast, pipeline)
    self.rootScope = ast.body.scope
    self.arrId = self.rootScope:addVariable()

    self.base64chars = table.concat(util.shuffle {
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "+", "/",
    })

    self.constants = {}
    self.lookup = {}

    self:extractConstants(ast)

    local encryptStringsStep = EncryptStrings:new()
    ast = encryptStringsStep:apply(ast, pipeline)

    if self.Shuffle then
        self:shuffleConstants()
        self.lookup = {}
        for i, v in ipairs(self.constants) do
            self.lookup[v] = i
        end
    end

    self.wrapperOffset = math.random(-self.MaxWrapperOffset, self.MaxWrapperOffset)
    self.wrapperId = self.rootScope:addVariable()

    self:processAST(ast, pipeline)

    self:addDecodeCode(ast)

    self:addWrapperFunction(ast)

    self:addRotateCodeIfNeeded(ast)

    table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(self.rootScope, { self.arrId }, { self:createArray() }))

    self:resetState()
end

function ConstantArray:extractConstants(ast)
    visitast(ast, nil, function(node, data)
        if math.random() <= self.Treshold then
            node.__apply_constant_array = true
            if node.kind == AstKind.StringExpression then
                self:addConstant(node.value)
            elseif not self.StringsOnly then
                if node.isConstant and node.value ~= nil then
                    self:addConstant(node.value)
                end
            end
        end
    end)
end

function ConstantArray:shuffleConstants()
    self.constants = util.shuffle(self.constants)
    self.lookup = {}
    for i, v in ipairs(self.constants) do
        self.lookup[v] = i
    end
end

function ConstantArray:processAST(ast, pipeline)
    visitast(ast, function(node, data)
        self:addLocalWrapperFunctions(node, data, pipeline)
        if node.__apply_constant_array then
            data.functionData.__used = true
        end
    end, function(node, data)
        self:insertStatements(node, data)
    end)
end

function ConstantArray:addLocalWrapperFunctions(node, data, pipeline)
    if self.LocalWrapperCount > 0 and node.kind == AstKind.Block and node.isFunctionBlock then
        local shouldInsertWrapper = self:shouldInsertWrapper(node)
        if shouldInsertWrapper then
            local id = node.scope:addVariable()
            data.functionData.local_wrappers = { id = id, scope = node.scope }
            local nameLookup = {}
            for i = 1, self.LocalWrapperCount do
                local name
                repeat
                    name = self:generateComplexName(pipeline.namegenerator, i)
                until not nameLookup[name]
                nameLookup[name] = true

                local offset = self:calculateVariableOffset(i, self.LocalWrapperCount)
                local argPos = self:determineDynamicArgPosition(node, i)

                data.functionData.local_wrappers[i] = {
                    arg = argPos,
                    index = name,
                    offset = offset,
                }
                data.functionData.__used = false
            end
        end
    end
end

function ConstantArray:shouldInsertWrapper(node)
    -- Complex condition to decide whether to insert a wrapper
    return math.random() <= self.LocalWrapperTreshold and #node.statements > 5
end

function ConstantArray:generateComplexName(namegenerator, iteration)
    -- Enhanced name generation with more complexity
    return callNameGenerator(namegenerator, math.random(1, self.LocalWrapperArgCount * 16)) .. tostring(iteration)
end

function ConstantArray:calculateVariableOffset(iteration, totalCount)
    -- More complex calculation for variable offset
    return math.random(-self.MaxWrapperOffset, self.MaxWrapperOffset) + (iteration % 3 == 0 and 1 or -1) * totalCount
end

function ConstantArray:determineDynamicArgPosition(node, iteration)
    -- Dynamically determine the argument position
    return (iteration % #node.statements) + 1
end

function ConstantArray:insertStatements(node, data)
    if node.__apply_constant_array then
        if node.kind == AstKind.StringExpression then
            return self:getConstant(node.value, data)
        elseif not self.StringsOnly and node.isConstant and node.value ~= nil then
            return self:getConstant(node.value, data)
        end
        node.__apply_constant_array = nil
    end

    if self.LocalWrapperCount > 0 and node.kind == AstKind.Block and node.isFunctionBlock and data.functionData.local_wrappers and data.functionData.__used then
        data.functionData.__used = nil
        local elems = {}
        local wrappers = data.functionData.local_wrappers
        for i = 1, self.LocalWrapperCount do
            local wrapper = wrappers[i]
            local argPos = wrapper.arg
            local offset = wrapper.offset
            local name = wrapper.index

            local funcScope = Scope:new(node.scope)

            local args = {}

            for j = 1, self.LocalWrapperArgCount do
                args[j] = funcScope:addVariable()
            end

            local arg = args[argPos]

            local addSubArg = self:generateComplexExpression(funcScope, arg, offset)

            funcScope:addReferenceToHigherScope(self.rootScope, self.wrapperId)
            local callArg = Ast.FunctionCallExpression(Ast.VariableExpression(self.rootScope, self.wrapperId), { addSubArg })

            local fargs = {}
            for k, v in ipairs(args) do
                fargs[k] = Ast.VariableExpression(funcScope, v)
            end

            elems[i] = Ast.KeyedTableEntry(
                Ast.StringExpression(name),
                Ast.FunctionLiteralExpression(fargs, Ast.Block({
                    Ast.ReturnStatement({ callArg }),
                }, funcScope))
            )
        end
        table.insert(node.statements, 1, Ast.LocalVariableDeclaration(node.scope, { wrappers.id }, { Ast.TableConstructorExpression(elems) }))
    end
end

function ConstantArray:generateComplexExpression(funcScope, arg, offset)
    local baseExpression = Ast.VariableExpression(funcScope, arg)
    if offset < 0 then
        baseExpression = Ast.SubExpression(baseExpression, Ast.NumberExpression(-offset))
    else
        baseExpression = Ast.AddExpression(baseExpression, Ast.NumberExpression(offset))
    end

    -- Randomized operation selection for added complexity
    local operations = {
        function(x) return Ast.MulExpression(x, Ast.NumberExpression(math.random(1, 10))) end,
        function(x) return Ast.DivExpression(x, Ast.NumberExpression(math.random(1, 10))) end,
        function(x) return Ast.AddExpression(x, Ast.NumberExpression(math.random(-100, 100))) end,
        function(x) return Ast.ModExpression(x, Ast.NumberExpression(math.random(1, 10))) end,
        function(x) return Ast.PowExpression(x, Ast.NumberExpression(math.random(1, 3))) end
    }

    local complexExpression = baseExpression
    for i = 1, #operations do
        local operation = operations[math.random(#operations)]
        complexExpression = operation(complexExpression)
    end

    return complexExpression
end

function ConstantArray:addWrapperFunction(ast)
    local funcScope = Scope:new(self.rootScope)
    funcScope:addReferenceToHigherScope(self.rootScope, self.arrId)

    local arg = funcScope:addVariable()
    local addSubArg

    if self.wrapperOffset < 0 then
        addSubArg = Ast.SubExpression(Ast.VariableExpression(funcScope, arg), Ast.NumberExpression(-self.wrapperOffset))
    else
        addSubArg = Ast.AddExpression(Ast.VariableExpression(funcScope, arg), Ast.NumberExpression(self.wrapperOffset))
    end

    table.insert(ast.body.statements, 1, Ast.LocalFunctionDeclaration(self.rootScope, self.wrapperId, {
        Ast.VariableExpression(funcScope, arg)
    }, Ast.Block({
        Ast.ReturnStatement({
            Ast.IndexExpression(Ast.VariableExpression(self.rootScope, self.arrId), addSubArg)
        }),
    }, funcScope)))
end

function ConstantArray:addRotateCodeIfNeeded(ast)
    if self.Rotate and #self.constants > 1 then
        local shift = math.random(1, #self.constants - 1)
        rotate(self.constants, -shift)
        self:addRotateCode(ast, shift)
    end
end

function ConstantArray:resetState()
    self.rootScope = nil
    self.arrId = nil
	self.constants = nil
	self.lookup = nil
	self.cachedEntries = nil
	self.cachedConstants = nil
	self.cachedArgs = nil
	self.cachedOfs = nil
end

return ConstantArray