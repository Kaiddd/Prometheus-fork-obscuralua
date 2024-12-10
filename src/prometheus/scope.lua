-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- scope.lua

local logger = require("logger")
local config = require("config")

local Scope = {}

local scopeCounter = 0
local function generateNextScopeName()
    scopeCounter = scopeCounter + 1
    return "local_scope_" .. tostring(scopeCounter)
end

local function generateWarning(token, message)
    return "Warning at Position " .. tostring(token.line) .. ":" .. tostring(token.linePos) .. ", " .. message
end

-- Create a new Local Scope
function Scope:new(parentScope, name)
    local scope = {
        isGlobal = false,
        parentScope = parentScope,
        variables = {},
        referenceCounts = {},
        variablesLookup = {},
        variablesFromHigherScopes = {},
        skipIdLookup = {},
        name = name or generateNextScopeName(),
        children = {},
        level = parentScope.level and (parentScope.level + 1) or 1
    }
    
    setmetatable(scope, self)
    self.__index = self
    parentScope:addChild(scope)
    return scope
end

-- Create a new Global Scope
function Scope:newGlobal()
    local scope = {
        isGlobal = true,
        parentScope = nil,
        variables = {},
        variablesLookup = {},
        referenceCounts = {},
        skipIdLookup = {},
        name = "global_scope",
        children = {},
        level = 0
    }
    
    setmetatable(scope, self)
    self.__index = self
    
    return scope
end

-- Returns the Parent Scope
function Scope:getParent()
    return self.parentScope
end

-- Sets the Parent Scope
function Scope:setParent(parentScope)
    self.parentScope:removeChild(self)
    parentScope:addChild(self)
    self.parentScope = parentScope
    self.level = parentScope.level + 1
end

local variableCounter = 1
-- Adds a Variable to the scope and returns the variable id, if no name is passed then a name is generated
function Scope:addVariable(name, token)
    if not name then
        name = string.format("%s%i", config.IdentPrefix, variableCounter)
        variableCounter = variableCounter + 1
    end
    
    if self.variablesLookup[name] then
        if token then
            logger:warn(generateWarning(token, "the variable \"" .. name .. "\" is already defined in that scope"))
        else
            logger:error(string.format("A variable with the name \"%s\" was already defined, you should have no variables starting with \"%s\"", name, config.IdentPrefix))
        end
        return self.variablesLookup[name]
    end
    
    table.insert(self.variables, name)
    local id = #self.variables
    self.variablesLookup[name] = id
    return id
end

-- Enables a Variable in the scope
function Scope:enableVariable(id)
    local name = self.variables[id]
    self.variablesLookup[name] = id
end

-- Adds a Disabled Variable to the scope
function Scope:addDisabledVariable(name, token)
    if not name then
        name = string.format("%s%i", config.IdentPrefix, variableCounter)
        variableCounter = variableCounter + 1
    end
    
    if self.variablesLookup[name] then
        if token then
            logger:warn(generateWarning(token, "the variable \"" .. name .. "\" is already defined in that scope"))
        else
            logger:warn(string.format("a variable with the name \"%s\" was already defined", name))
        end
        return self.variablesLookup[name]
    end
    
    table.insert(self.variables, name)
    local id = #self.variables
    return id
end

function Scope:addIfNotExists(id)
    if not self.variables[id] then
        local name = string.format("%s%i", config.IdentPrefix, next_name_i)
        next_name_i = next_name_i + 1
        self.variables[id] = name
        self.variablesLookup[name] = id
    end
    return id
end

-- Get all variables from the current scope and all its parent scopes
function Scope:getAllVariables()
    local allVariables = {}
    for k, v in pairs(self.variables) do
        allVariables[k] = v
    end

    local parentScope = self.parentScope
    while parentScope do
        for k, v in pairs(parentScope.variables) do
            allVariables[k] = v
        end
        parentScope = parentScope.parentScope
    end

    return allVariables
end

-- Check if a variable is global
function Scope:isGlobalVariable(name)
    return self.isGlobal and self:hasVariable(name)
end

-- Check if a variable is local
function Scope:isLocalVariable(name)
    return not self.isGlobal and self:hasVariable(name)
end

-- Get all global variables
function Scope:getGlobalVariables()
    if self.isGlobal then
        return self.variables
    elseif self.parentScope then
        return self.parentScope:getGlobalVariables()
    else
        return {}
    end
end

-- Get all local variables
function Scope:getLocalVariables()
    if not self.isGlobal then
        return self.variables
    else
        return {}
    end
end

-- Check if the variable is defined in this Scope
function Scope:hasVariable(name)
    if self.isGlobal then
        if not self.variablesLookup[name] then
            self:addVariable(name)
        end
        return true
    end
    return self.variablesLookup[name] ~= nil
end

-- Get list of all variables defined in this Scope
function Scope:getVariables()
    return self.variables
end

-- Reset reference count for a variable
function Scope:resetReferences(id)
    self.referenceCounts[id] = 0
end

-- Get reference count for a variable
function Scope:getReferences(id)
    return self.referenceCounts[id] or 0
end

-- Decrease reference count for a variable
function Scope:removeReference(id)
    self.referenceCounts[id] = (self.referenceCounts[id] or 0) - 1
end

-- Increase reference count for a variable
function Scope:addReference(id)
    self.referenceCounts[id] = (self.referenceCounts[id] or 0) + 1
end

-- Resolve the scope of a variable by name
function Scope:resolve(name)
    if self:hasVariable(name) then
        return self, self.variablesLookup[name]
    end
    assert(self.parentScope, "No Global Variable Scope was Created! This should not be Possible!")
    local scope, id = self.parentScope:resolve(name)
    self:addReferenceToHigherScope(scope, id, nil, true)
    return scope, id
end

-- Resolve the global scope of a variable by name
function Scope:resolveGlobal(name)
    if self.isGlobal and self:hasVariable(name) then
        return self, self.variablesLookup[name]
    end
    assert(self.parentScope, "No Global Variable Scope was Created! This should not be Possible!")
    local scope, id = self.parentScope:resolveGlobal(name)
    self:addReferenceToHigherScope(scope, id, nil, true)
    return scope, id
end

-- Get the name of a variable by id - used for unparsing
function Scope:getVariableName(id)
    return self.variables[id]
end

-- Remove a variable from this Scope
function Scope:removeVariable(id)
    local name = self.variables[id]
    self.variables[id] = nil
    self.variablesLookup[name] = nil
    self.skipIdLookup[id] = true
end

-- Add a child Scope
function Scope:addChild(scope)
    -- This will add all references from that Scope to higher Scopes. Note that the higher scopes may only be global
    for higherScope, ids in pairs(scope.variablesFromHigherScopes) do
        for id, count in pairs(ids) do
            if count and count > 0 then
                self:addReferenceToHigherScope(higherScope, id, count)
            end
        end
    end
    table.insert(self.children, scope)
end

-- Clear all references
function Scope:clearReferences()
    self.referenceCounts = {}
    self.variablesFromHigherScopes = {}
end

function Scope:removeChild(child)
    for i, v in ipairs(self.children) do
        if v == child then
            -- Remove all references from the child scope to higher scopes
            for scope, ids in pairs(v.variablesFromHigherScopes) do
                for id, count in pairs(ids) do
                    if count and count > 0 then
                        self:removeReferenceToHigherScope(scope, id, count)
                    end
                end
            end
            return table.remove(self.children, i)
        end
    end
end

function Scope:getMaxId()
    return #self.variables
end

function Scope:addReferenceToHigherScope(scope, id, n, propagate)
    n = n or 1
    if self.isGlobal then
        if not scope.isGlobal then
            logger:error(string.format("Could not resolve Scope \"%s\"", scope.name))
        end
        return
    end
    if scope == self then
        self.referenceCounts[id] = (self.referenceCounts[id] or 0) + n
        return
    end
    if not self.variablesFromHigherScopes[scope] then
        self.variablesFromHigherScopes[scope] = {}
    end
    local scopeReferences = self.variablesFromHigherScopes[scope]
    scopeReferences[id] = (scopeReferences[id] or 0) + n
    if not propagate then
        self.parentScope:addReferenceToHigherScope(scope, id, n)
    end
end

function Scope:removeReferenceToHigherScope(scope, id, n, propagate)
    n = n or 1
    if self.isGlobal then
        return
    end
    if scope == self then
        self.referenceCounts[id] = (self.referenceCounts[id] or 0) - n
        return
    end
    if not self.variablesFromHigherScopes[scope] then
        self.variablesFromHigherScopes[scope] = {}
    end
    local scopeReferences = self.variablesFromHigherScopes[scope]
    scopeReferences[id] = (scopeReferences[id] or 0) - n
    if not propagate then
        self.parentScope:removeReferenceToHigherScope(scope, id, n)
    end
end

-- Rename variables from the current scope downwards
-- settings object should have the following properties:
-- Keywords => forbidden variable names
-- generateName(id, scope, originalName) => function to generate unique variable name based on the id and scope
function Scope:renameVariables(settings)
    if not self.isGlobal then
        local prefix = settings.prefix or ""
        local forbiddenNamesLookup = {}
        for _, keyword in pairs(settings.Keywords) do
            forbiddenNamesLookup[keyword] = true
        end
        
        for scope, ids in pairs(self.variablesFromHigherScopes) do
            for id, count in pairs(ids) do
                if count and count > 0 then
                    local name = scope:getVariableName(id)
                    forbiddenNamesLookup[name] = true
                end
            end
        end
        
        self.variablesLookup = {}
        
        local i = 0
        for id, originalName in pairs(self.variables) do
            if not self.skipIdLookup[id] and (self.referenceCounts[id] or 0) >= 0 then
                local name
                repeat
                    name = prefix .. settings.generateName(i, self, originalName)
                    if name == nil then
                        name = originalName
                    end
                    i = i + 1
                until not forbiddenNamesLookup[name]

                self.variables[id] = name
                self.variablesLookup[name] = id
            end
        end
    end
    
    for _, scope in pairs(self.children) do
        scope:renameVariables(settings)
    end
end

return Scope