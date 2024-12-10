-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- SplitStrings.lua
--
-- This Script provides a Simple Obfuscation Step for splitting Strings
local Step = require("Prometheus.step");
local Ast = require("Prometheus.ast");
local visitAst = require("Prometheus.visitast");
local Parser = require("Prometheus.parser");
local util = require("Prometheus.util");
local enums = require("Prometheus.enums")

local LuaVersion = enums.LuaVersion;

local SplitStrings = Step:extend();
SplitStrings.Description = "This Step splits Strings to a specific or random length";
SplitStrings.Name = "Split Strings";

SplitStrings.SettingsDescriptor = {
	Treshold = {
		name = "Treshold",
		description = "The relative amount of nodes that will be affected",
		type = "number",
		default = 1,
		min = 0,
		max = 1,
	},
	MinLength = {
		name = "MinLength",
		description = "The minimal length for the chunks in that the Strings are splitted",
		type = "number",
		default = 5,
		min = 1,
		max = nil,
	},
	MaxLength = {
		name = "MaxLength",
		description = "The maximal length for the chunks in that the Strings are splitted",
		type = "number",
		default = 5,
		min = 1,
		max = nil,
	},
	ConcatenationType = {
		name = "ConcatenationType",
		description =
		"The Functions used for Concatenation. Note that when using custom, the String Array will also be Shuffled",
		type = "enum",
		values = {
			"strcat",
			"table",
			"custom",
		},
		default = "custom",
	},
	CustomFunctionType = {
		name = "CustomFunctionType",
		description =
		"The Type of Function code injection This Option only applies when custom Concatenation is selected.\
Note that when chosing inline, the code size may increase significantly!",
		type = "enum",
		values = {
			"global",
			"local",
			"inline",
		},
		default = "global",
	},
	CustomLocalFunctionsCount = {
		name = "CustomLocalFunctionsCount",
		description = "The number of local functions per scope. This option only applies when CustomFunctionType = local",
		type = "number",
		default = 2,
		min = 1,
	},
	NestedLayers = {
		name = "NestedLayers",
		description = "The number of times the string is split into chunks",
		type = "number",
		default = 1,
		min = 1,
		max = nil,
	},
}

function SplitStrings:init(settings) end

local function generateTableConcatNode(chunks, data)
    local chunkNodes = {}
    for i = 1, #chunks do
        chunkNodes[i] = Ast.TableEntry(Ast.StringExpression(chunks[i]))
    end
    local tb = Ast.TableConstructorExpression(chunkNodes)
    data.scope:addReferenceToHigherScope(data.tableConcatScope, data.tableConcatId)
    return Ast.FunctionCallExpression(Ast.VariableExpression(data.tableConcatScope, data.tableConcatId), {tb})
end

local function generateStrCatNode(chunks)
    if #chunks == 0 then return nil end
    -- Use table.concat for efficient string concatenation
    local strTable = {}
    for i = 1, #chunks do
        strTable[i] = chunks[i]
    end
    return Ast.StringExpression(table.concat(strTable))
end

local customVariants = 2;
local custom1Code = [=[
function custom(table)
    local stringTable, strTable = table[#table], {};
    for i=1,#stringTable, 1 do
        strTable[#strTable + 1] = stringTable[table[i]];
    end
    return table.concat(strTable)
end
]=];

local custom2Code = [=[
function custom(tb)
    local strTable = {};
    for i=1, #tb / 2, 1 do
        strTable[#strTable + 1] = tb[#tb / 2 + tb[i]];
    end
    return table.concat(strTable)
end
]=];

local function generateCustomNodeArgs(chunks, data, variant)
    local shuffledIndices = {}
    for i = 1, #chunks do
        shuffledIndices[i] = i
    end
    util.shuffle(shuffledIndices)

    local args = {}
    for i, index in ipairs(shuffledIndices) do
        args[i] = Ast.TableEntry(Ast.NumberExpression(index))
    end
    if variant == 1 then
        local tbNodes = {}
        for i, chunk in ipairs(chunks) do
            tbNodes[i] = Ast.TableEntry(Ast.StringExpression(chunk))
        end
        local tb = Ast.TableConstructorExpression(tbNodes)
        table.insert(args, Ast.TableEntry(tb))
    else
        for i, chunk in ipairs(chunks) do
            table.insert(args, Ast.TableEntry(Ast.StringExpression(chunk)))
        end
    end
    return {Ast.TableConstructorExpression(args)}
end

local parsedCustomFunctions = {}

local parser = Parser:new({
	LuaVersion = LuaVersion.LuaU,
});

-- Helper function to parse code and create function declaration
local function parseAndCreateFuncDecl(parser, code, scope)
    local funcDeclNode = parser:parse(code).body.statements[1];
    local funcBody = funcDeclNode.body;
    local funcArgs = funcDeclNode.args;
    funcBody.scope:setParent(scope);
    return Ast.FunctionLiteralExpression(funcArgs, funcBody);
end

-- Optimized generateCustomFunctionLiteral
local function generateCustomFunctionLiteral(parentScope, variant)
    if not parsedCustomFunctions[variant] then
        local code = variant == 1 and custom1Code or custom2Code
        parsedCustomFunctions[variant] = parseAndCreateFuncDecl(parser, code, parentScope)
    end
    return parsedCustomFunctions[variant]
end

-- Optimized generateGlobalCustomFunctionDeclaration
local function generateGlobalCustomFunctionDeclaration(ast, data)
    local astScope = ast.body.scope;
    local code = data.customFunctionVariant == 1 and custom1Code or custom2Code
    local funcExpr = parseAndCreateFuncDecl(parser, code, astScope)
    return Ast.LocalVariableDeclaration(data.customFuncScope, { data.customFuncId }, { funcExpr });
end

function SplitStrings:variant()
	return math.random(1, customVariants);
end

-- Optimized getVariableLength (seed random number generator once, possibly in an initialization phase)
function SplitStrings:getVariableLength()
    local sineWave = math.sin(os.time());
    local randomFactor = math.random();
    local length = math.floor((sineWave * randomFactor * (self.MaxLength - self.MinLength)) + self.MinLength);
    return length;
end

function SplitStrings:shuffleChunks(chunks)
	local shuffledChunks = {};
	local indices = {};
	for i = 1, #chunks do
		indices[i] = i;
	end
	util.shuffle(indices);
	for i, index in ipairs(indices) do
		shuffledChunks[i] = chunks[index];
	end
	return shuffledChunks, indices;
end

function SplitStrings:storeOrder(indices)
	local order = {};
	for i, index in ipairs(indices) do
		order[index] = i;
	end
	return order;
end

function SplitStrings:apply(ast, pipeline)
    local data = {};
    local concatenationType = self.ConcatenationType
    local customFunctionType = self.CustomFunctionType
    local nestedLayers = self.NestedLayers
    local threshold = self.Treshold

    if (concatenationType == "table") then
        local scope = ast.body.scope;
        local id = scope:addVariable();
        data.tableConcatScope = scope;
        data.tableConcatId = id;
    elseif (concatenationType == "custom") then
        data.customFunctionType = customFunctionType;
        if customFunctionType == "global" then
            local scope = ast.body.scope;
            local id = scope:addVariable();
            data.customFuncScope = scope;
            data.customFuncId = id;
            data.customFunctionVariant = self:variant();
        end
    end

    local customLocalFunctionsCount = self.CustomLocalFunctionsCount;
    local self2 = self;

    visitAst(ast, function(node, data)
        if (concatenationType == "custom" and customFunctionType == "local" and node.kind == Ast.AstKind.Block and node.isFunctionBlock) then
            data.functionData.localFunctions = {};
            for i = 1, customLocalFunctionsCount do
                local scope = data.scope;
                local id = scope:addVariable();
                local variant = self:variant();
                table.insert(data.functionData.localFunctions, {
                    scope = scope,
                    id = id,
                    variant = variant,
                    used = false,
                });
            end
        end
    end, function(node, data)
        if (concatenationType == "custom" and customFunctionType == "local" and node.kind == Ast.AstKind.Block and node.isFunctionBlock) then
            for _, func in ipairs(data.functionData.localFunctions) do
                if func.used then
                    local literal = generateCustomFunctionLiteral(func.scope, func.variant);
                    table.insert(node.statements, 1, Ast.LocalVariableDeclaration(func.scope, { func.id }, { literal }));
                end
            end
        end

        if (node.kind == Ast.AstKind.StringExpression) then
            local str = node.value;
            local chunks = {};
            local nestedChunks = chunks;
            for _ = 1, nestedLayers do
                local newChunks = {};
                for _, chunk in ipairs(nestedChunks) do
                    local i = 1;
                    while i <= string.len(chunk) do
                        local len = self:getVariableLength();
                        table.insert(newChunks, string.sub(chunk, i, i + len - 1));
                        i = i + len;
                    end
                end
                nestedChunks = newChunks;
            end

            local shuffledChunks, indices = self:shuffleChunks(chunks);
            local order = self:storeOrder(indices);

            if (#shuffledChunks > 1 and math.random() < threshold) then
                if concatenationType == "strcat" then
                    node = generateStrCatNode(shuffledChunks);
                elseif concatenationType == "table" then
                    node = generateTableConcatNode(shuffledChunks, data);
                elseif concatenationType == "custom" then
                    if customFunctionType == "global" then
                        local args = generateCustomNodeArgs(shuffledChunks, data, data.customFunctionVariant);
                        data.scope:addReferenceToHigherScope(data.customFuncScope, data.customFuncId);
                        node = Ast.FunctionCallExpression(Ast.VariableExpression(data.customFuncScope, data.customFuncId), args);
                    elseif customFunctionType == "local" then
                        local lfuncs = data.functionData.localFunctions;
                        local idx = math.random(1, #lfuncs);
                        local func = lfuncs[idx];
                        local args = generateCustomNodeArgs(shuffledChunks, data, func.variant);
                        func.used = true;
                        data.scope:addReferenceToHigherScope(func.scope, func.id);
                        node = Ast.FunctionCallExpression(Ast.VariableExpression(func.scope, func.id), args);
                    elseif customFunctionType == "inline" then
                        local variant = self:variant();
                        local args = generateCustomNodeArgs(shuffledChunks, data, variant);
                        local literal = generateCustomFunctionLiteral(data.scope, variant);
                        node = Ast.FunctionCallExpression(literal, args);
                    end
                end
            end

            return node, true;
        end
    end, data)

    if (concatenationType == "table") then
        local globalScope = data.globalScope;
        local tableScope, tableId = globalScope:resolve("table")
        ast.body.scope:addReferenceToHigherScope(globalScope, tableId);
        table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(data.tableConcatScope, { data.tableConcatId },
            { Ast.IndexExpression(Ast.VariableExpression(tableScope, tableId), Ast.StringExpression("concat")) }));
    elseif (concatenationType == "custom" and customFunctionType == "global") then
        table.insert(ast.body.statements, 1, generateGlobalCustomFunctionDeclaration(ast, data));
    end

    return ast;
end


return SplitStrings;
