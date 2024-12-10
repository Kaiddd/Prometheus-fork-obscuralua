-- This script is a component of the Prometheus Obfuscator developed by levno-710.
--
-- ProxifyLocals.lua
--
-- This script encapsulates all local variables within proxy objects. The script achieves this by creating a layer of abstraction between the actual local variables and their usage in the code.
local Step = require("Prometheus.step");
local Ast = require("Prometheus.ast");
local Scope = require("Prometheus.scope");
local visitast = require("Prometheus.visitast");
local RandomLiterals = require("Prometheus.randomLiterals")

local AstKind = Ast.AstKind;

-- Cache frequently used global functions
local pairs = pairs
local math_random = math.random
local type = type
local ipairs = ipairs
local assert = assert

local Proxify = Step:extend();
Proxify.Description = "This Step wraps all locals into Proxy Objects";
Proxify.Name = "Proxify Locals";

Proxify.SettingsDescriptor = {
    LiteralType = {
        name = "LiteralType",
        description = "The type of the randomly generated literals",
        type = "enum",
        values = { "dictionary", "number", "string", "any", "function", "table" },
        default = "dictionary"
    },
    ProxyLayers = {
        name = "ProxyLayers",
        description = "The number of layers of proxy objects",
        type = "number",
        default = 1
    }
}

local function shallowcopy(orig)
    local copy = {}
    for orig_key, orig_value in pairs(orig) do
        copy[orig_key] = orig_value
    end
    return copy
end

local function shuffleTable(t)
    for i = #t, 2, -1 do
        local j = math_random(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- Use complex data structures
local function callNameGenerator(generatorFunction, ...)
    if (type(generatorFunction) == "table") then
        generatorFunction = generatorFunction.generateName;
    end
    return generatorFunction(...);
end

-- Metatable Configurations Cache
local metatableConfigurationsCache = {}

-- Dynamic Metatable Expressions
local function generateMetatableExpressions()
    local MetatableExpressions = {
        { constructor = Ast.AddExpression,    key = "__add" },
        { constructor = Ast.SubExpression,    key = "__sub" },
        { constructor = Ast.IndexExpression,  key = "__index" },
        { constructor = Ast.MulExpression,    key = "__mul" },
        { constructor = Ast.DivExpression,    key = "__div" },
        { constructor = Ast.PowExpression,    key = "__pow" },
        { constructor = Ast.StrCatExpression, key = "__concat" }
    }
    shuffleTable(MetatableExpressions)
    return MetatableExpressions
end

function Proxify:init(settings) end

-- Dynamic Metatable Generation
local function generateLocalMetatableInfo(pipeline, varType)
    varType = varType or "any"

    -- Reuse metatable configurations based on varType
    if metatableConfigurationsCache[varType] then
        return metatableConfigurationsCache[varType]
    end

    local info = {
        ops = {"setValue", "getValue", "index"},
        expressionsCopy = shallowcopy(generateMetatableExpressions()),
        valueName = callNameGenerator(pipeline.namegenerator, math.random(1, 4096)),
        varType = varType
    }

    -- shuffleTable is called with a valid table
    shuffleTable(info.ops)

    for i, v in ipairs(info.ops) do
        -- expressionsCopy is not empty before accessing
        assert(#info.expressionsCopy > 0, "Not enough metatable expressions for operations")
        local rop = table.remove(info.expressionsCopy, 1) -- Use table.remove with index for clarity and safety
        assert(rop and rop.constructor ~= nil, "Error: constructor is nil for metatable expression: " .. (rop and rop.key or "nil"))
        info[v] = rop
    end

    -- Cache the generated metatable configuration for reuse
    metatableConfigurationsCache[varType] = info

    return info
end

function Proxify:CreateAssignmentExpression(info, expr, parentScope, depth, pipeline)
    local metatableVals = {};
    local isExprNumber = type(expr) == 'number'

    local function createFunctionLiteralExpression(scope, arg1, arg2, body)
        return Ast.FunctionLiteralExpression({
            Ast.VariableExpression(scope, arg1),
            Ast.VariableExpression(scope, arg2)
        }, Ast.Block(body, scope))
    end

    local function createSetValueFunction()
        local scope = Scope:new(parentScope);
        local self = scope:addVariable();
        local arg = scope:addVariable();
        local functionLiteral = createFunctionLiteralExpression(scope, self, arg, {
            Ast.AssignmentStatement({
                Ast.AssignmentIndexing(
                    Ast.VariableExpression(scope, self),
                    Ast.StringExpression(info.valueName))
            }, { Ast.VariableExpression(scope, arg) })
        })
        table.insert(metatableVals,
            Ast.KeyedTableEntry(Ast.StringExpression(info.setValue.key),
                functionLiteral));
    end

    local function createGetValueFunction()
        local scope = Scope:new(parentScope);
        local self = scope:addVariable();
        local arg = scope:addVariable();
        local idxExpr;
        if (info.getValue.key == "__index") then
            idxExpr = Ast.FunctionCallExpression(
                Ast.VariableExpression(
                    scope:resolveGlobal("rawget")),
                {
                    Ast.VariableExpression(scope, self),
                    Ast.StringExpression(info.valueName)
                });
        else
            idxExpr = isExprNumber and Ast.SubExpression(
                Ast.IndexExpression(
                    Ast.VariableExpression(scope,
                        self),
                    Ast.StringExpression(info.valueName)),
                Ast.NumberExpression(expr)) or Ast.IndexExpression(
                Ast.VariableExpression(scope,
                    self),
                Ast.StringExpression(info.valueName));
        end

        local functionLiteral = createFunctionLiteralExpression(scope, self, arg, {
            Ast.ReturnStatement({ idxExpr })
        })
        -- Add __metatable to the metatableVals
        table.insert(metatableVals,
            Ast.KeyedTableEntry(Ast.StringExpression(info.getValue.key),
                functionLiteral));
    end

    local function createMetatableProtectionFunction()
        local scope = Scope:new(parentScope);
        local self = scope:addVariable();
        local arg = scope:addVariable();
        local functionLiteral = createFunctionLiteralExpression(scope, self, arg, {
            Ast.ReturnStatement({
                Ast.NilExpression()
            })
        })
        table.insert(metatableVals,
            Ast.KeyedTableEntry(Ast.StringExpression("__metatable"),
                functionLiteral));
    end

    -- Validate metatable keys to prevent unauthorized access
    local function validateMetatableKeys()
        local allowedKeys = {
            __index = true,
            __newindex = true,
            __metatable = true,
            __gc = true,
            __len = true,
            __call = true,
            __tostring = true,
            __pairs = true,
            __ipairs = true,
            __add = true,
            __sub = true,
            __mul = true,
            __div = true,
            __pow = true,
            __concat = true
        }
        for _, entry in ipairs(metatableVals) do
            local key = entry.key.value
            if not allowedKeys[key] then
                return false, "Unauthorized metatable key: " .. key
            end
        end
        return true
    end

    createSetValueFunction()
    createGetValueFunction()
    createMetatableProtectionFunction()

    local isValid, errorMsg = validateMetatableKeys()
    if not isValid then
        -- Handle the error in the AST/block-related functions
        return Ast.ErrorExpression(errorMsg)
    end

    parentScope:addReferenceToHigherScope(self.setMetatableVarScope,
        self.setMetatableVarId);

    local nestedTable = Ast.TableConstructorExpression({
        Ast.KeyedTableEntry(Ast.StringExpression(info.valueName), expr)
    })

    local nestedFunction = Ast.FunctionLiteralExpression({}, Ast.Block({
        Ast.ReturnStatement({ nestedTable })
    }, Scope:new(parentScope)))

    local proxyObject = Ast.FunctionCallExpression(
        Ast.VariableExpression(self.setMetatableVarScope, self.setMetatableVarId), {
            Ast.FunctionCallExpression(nestedFunction, {}),
            Ast.TableConstructorExpression(metatableVals)
        }
    );

    if depth > 1 then
        local newInfo = generateLocalMetatableInfo(pipeline)
        proxyObject = self:CreateAssignmentExpression(newInfo, proxyObject,
            parentScope,
            depth - 1, pipeline)
    end

    return proxyObject;
end

function Proxify:apply(ast, pipeline)
    local localMetatableInfos = {};
    local generateLocalMetatableInfo = generateLocalMetatableInfo

    local function getLocalMetatableInfoKey(scope, id)
        return tostring(scope) .. "_" .. tostring(id)
    end

    local function getLocalMetatableInfo(scope, id, varType)
        if (scope.isGlobal) then return nil end

        local key = getLocalMetatableInfoKey(scope, id)
        local info = localMetatableInfos[key]
        if info then
            if info.locked then return nil end
            return info
        end
        local localMetatableInfo = generateLocalMetatableInfo(pipeline, varType)
        localMetatableInfos[key] = localMetatableInfo
        return localMetatableInfo
    end

    local function disableMetatableInfo(scope, id)
        if (scope.isGlobal) then return end

        local key = getLocalMetatableInfoKey(scope, id)
        localMetatableInfos[key] = { locked = true }
    end

    self.setMetatableVarScope = ast.body.scope
    self.setMetatableVarId = ast.body.scope:addVariable()

    local emptyFunctionScope = ast.body.scope
    local emptyFunctionId = ast.body.scope:addVariable()

    table.insert(ast.body.statements, 1,
        Ast.LocalVariableDeclaration(emptyFunctionScope,
            { emptyFunctionId }, {
                Ast.FunctionLiteralExpression({},
                    Ast.Block({}, Scope:new(ast.body.scope)))
            }))

    visitast(ast, function(node, data)
        if node.kind == AstKind.ForStatement or node.kind == AstKind.ForInStatement then
            local ids = node.kind == AstKind.ForStatement and { node.id } or node.ids
            for _, id in ipairs(ids) do
                disableMetatableInfo(node.scope, id)
            end
        elseif node.kind == AstKind.FunctionDeclaration or node.kind == AstKind.LocalFunctionDeclaration or node.kind == AstKind.FunctionLiteralExpression then
            if node.args then
                for _, expr in ipairs(node.args) do
                    if expr.kind == AstKind.VariableExpression then
                        disableMetatableInfo(expr.scope, expr.id)
                    end
                end
            end
        elseif node.kind == AstKind.AssignmentStatement and #node.lhs == 1 and node.lhs[1].kind == AstKind.AssignmentVariable then
            local variable = node.lhs[1]
            local localMetatableInfo = getLocalMetatableInfo(variable.scope, variable.id)
            if localMetatableInfo then
                local args = shallowcopy(node.rhs)
                local vexp = Ast.VariableExpression(variable.scope, variable.id)
                vexp.__ignoreProxifyLocals = true
                args[1] = localMetatableInfo.setValue.constructor(vexp, args[1])
                emptyFunctionScope:addReferenceToHigherScope(emptyFunctionScope, emptyFunctionId)
                data.scope:addReferenceToHigherScope(emptyFunctionScope, emptyFunctionId)
                return Ast.FunctionCallStatement(Ast.VariableExpression(emptyFunctionScope, emptyFunctionId), args)
            end
        end
    end, function(node, data)
        -- Local Function Declaration
        if (node.kind == AstKind.LocalFunctionDeclaration) then
            local localMetatableInfo =
                getLocalMetatableInfo(node.scope, node.id);
            -- Apply Only to Some Variables if Treshold is non 1
            if localMetatableInfo then
                local funcLiteral = Ast.FunctionLiteralExpression(node.args,
                    node.body);
                local newExpr = self:CreateAssignmentExpression(
                    localMetatableInfo, funcLiteral, node.scope,
                    self.ProxyLayers, pipeline);
                return Ast.LocalVariableDeclaration(node.scope, { node.id },
                    { newExpr });
            end
        end

        -- Return Statement
        if (node.kind == AstKind.ReturnStatement) then
            -- Check if node.expressions is not nil
            if node.expressions then
                for i, expr in ipairs(node.expressions) do
                    local varType = type(expr)
                    local localMetatableInfo = generateLocalMetatableInfo(pipeline, varType);
                    if localMetatableInfo then
                        local newExpr = self:CreateAssignmentExpression(
                            localMetatableInfo, expr, node.scope,
                            self.ProxyLayers, pipeline);
                        node.expressions[i] = newExpr;
                    end
                end
            end
        end

        -- Local Variable Declaration
        if (node.kind == AstKind.LocalVariableDeclaration) then
            for i, id in ipairs(node.ids) do
                local expr = node.expressions[i] or Ast.NilExpression();
                local varType = type(expr)
                local localMetatableInfo = getLocalMetatableInfo(node.scope, id, varType);
                -- Apply Only to Some Variables if Treshold is non 1
                if localMetatableInfo then
                    local newExpr = self:CreateAssignmentExpression(
                        localMetatableInfo, expr, node.scope,
                        self.ProxyLayers, pipeline);
                    node.expressions[i] = newExpr;
                end
            end
        end

        -- Variable Expression
        if (node.kind == AstKind.VariableExpression and
                not node.__ignoreProxifyLocals) then
            local localMetatableInfo =
                getLocalMetatableInfo(node.scope, node.id);
            -- Apply Only to Some Variables if Treshold is non 1
            if localMetatableInfo then
                local literal;
                if self.LiteralType == "dictionary" then
                    literal = RandomLiterals.Dictionary(pipeline);
                elseif self.LiteralType == "number" then
                    literal = RandomLiterals.Number();
                elseif self.LiteralType == "string" then
                    literal = RandomLiterals.String(pipeline);
                elseif self.LiteralType == "function" then
                    literal = RandomLiterals.Function();
                elseif self.LiteralType == "table" then
                    literal = RandomLiterals.Table();
                else
                    literal = RandomLiterals.Any();
                end
                return localMetatableInfo.getValue.constructor(node, literal);
            end
        end

        -- Assignment Variable for Assignment Statement
        if (node.kind == AstKind.AssignmentVariable) then
            local localMetatableInfo =
                getLocalMetatableInfo(node.scope, node.id);
            -- Apply Only to Some Variables if Treshold is non 1
            if localMetatableInfo then
                return Ast.AssignmentIndexing(node, Ast.StringExpression(
                    localMetatableInfo.valueName));
            end
        end

        -- Local Function Declaration
        if (node.kind == AstKind.LocalFunctionDeclaration) then
            local localMetatableInfo =
                getLocalMetatableInfo(node.scope, node.id);
            -- Apply Only to Some Variables if Treshold is non 1
            if localMetatableInfo then
                local funcLiteral = Ast.FunctionLiteralExpression(node.args,
                    node.body);
                local newExpr = self:CreateAssignmentExpression(
                    localMetatableInfo, funcLiteral, node.scope);
                return Ast.LocalVariableDeclaration(node.scope, { node.id },
                    { newExpr });
            end
        end

        -- Function Declaration
        if (node.kind == AstKind.FunctionDeclaration) then
            local localMetatableInfo =
                getLocalMetatableInfo(node.scope, node.id);
            if (localMetatableInfo) then
                table.insert(node.indices, 1, localMetatableInfo.valueName);
            end
        end
    end)

    -- Add Setmetatable Variable Declaration
    table.insert(ast.body.statements, 1,
        Ast.LocalVariableDeclaration(self.setMetatableVarScope,
            { self.setMetatableVarId }, {
                Ast.VariableExpression(self.setMetatableVarScope:resolveGlobal("setmetatable"))
            }))
end

return Proxify;
