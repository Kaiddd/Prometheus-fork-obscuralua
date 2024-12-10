-- ControlFlowObfuscator.lua
local ControlFlowObfuscator = {}
ControlFlowObfuscator.__index = ControlFlowObfuscator
ControlFlowObfuscator.maxDepth = 20 -- Limit the maximum depth of recursion

-- Constructor
function ControlFlowObfuscator:new()
    local newObj = {
        memo = {},
        memoRare = {},
        numberMemo = {}, -- Add memoization for numberMutation
    }
    setmetatable(newObj, ControlFlowObfuscator)
    return newObj
end

-- Generate Nested Obfuscated Condition
function ControlFlowObfuscator:generateNestedObfuscatedCondition(depth)
    if depth > self.maxDepth then return "false" end -- Limit the depth of recursion
    if self.memo[depth] then return self.memo[depth] end

    if depth <= 0 then
        -- Return a simple equation as a string
        self.memo[depth] = "math.random() > 0.5"
    else
        local conditions = {}
        local numConditions = math.random(2, 10)
        for i = 1, numConditions do
            local decrement = math.random(1, 4)
            local newDepth = depth - decrement
            conditions[i] = self:generateNestedObfuscatedCondition(newDepth)
        end

        local randomPath = math.random()
        if randomPath < 0.2 and #conditions >= 2 then
            self.memo[depth] = "(" .. conditions[1] .. ") and (" .. conditions[2] .. ")"
        elseif randomPath < 0.4 and #conditions >= 2 then
            self.memo[depth] = "(" .. conditions[1] .. ") or (" .. conditions[2] .. ")"
        elseif randomPath < 0.6 and #conditions >= 3 then
            self.memo[depth] = "not (" .. conditions[1] .. ") or (" .. conditions[3] .. ")"
        elseif randomPath < 0.8 and #conditions >= 3 then
            self.memo[depth] = "((" .. conditions[1] .. ") and (" .. conditions[2] .. ")) or (" .. conditions[3] .. ")"
        elseif #conditions >= 5 then
            self.memo[depth] = "((" .. conditions[1] .. ") and ((" .. conditions[2] .. ") or (" .. conditions[3] .. "))) and ((" .. conditions[4] .. ") or not (" .. conditions[5] .. "))"
        else
            self.memo[depth] = "math.random() > 0.5"
        end
    end
    return self.memo[depth]
end

-- Enhanced generateNestedObfuscatedConditionWithRarelyCheckedConditions
function ControlFlowObfuscator:generateNestedObfuscatedConditionWithRarelyCheckedConditions(depth)
    if depth <= 0 then return function() return math.random() > math.random() end end
    if self.memoRare[depth] then return self.memoRare[depth] end
    local conditions = {}
    for i=1, math.random(2, 3) do
        local newDepth = depth - 2
        conditions[i] = self:generateNestedObfuscatedConditionWithRarelyCheckedConditions(newDepth)
    end
    self.memoRare[depth] = function()
        local result = true
        for i=1, #conditions do
            result = result and conditions[i]()
        end
        return result
    end
    return self.memoRare[depth]
end


-- generateDeeplyNestedObfuscatedCondition
function ControlFlowObfuscator:generateDeeplyNestedObfuscatedCondition(depth)
    if depth <= 0 then 
        return function() 
            return math.random() > math.random() 
        end 
    end

    local conditions = {}
    for i = 1, math.random(2, 20) do
        local newDepth = depth - math.random(1, 3)
        conditions[i] = self:generateDeeplyNestedObfuscatedCondition(newDepth)
    end

    local operators = {"and", "or"}
    local negation = math.random() > 0.5 and "not " or ""

    return function()
        local result = math.random() > 0.5
        for i = 1, #conditions do
            local operator = operators[math.random(1, #operators)]
            if operator == "and" then
                result = result and conditions[i]()
            else
                result = result or conditions[i]()
            end
        end
        return load("return " .. negation .. tostring(result))()
    end
end

-- generateDeeplyNestedObfuscatedConditionWithFunctionCalls
function ControlFlowObfuscator:generateDeeplyNestedObfuscatedConditionWithFunctionCalls(depth)
    if depth <= 0 then return function() return math.random() > math.random() end end

    local conditions = {}
    local numConditions = math.random(3, 30)  -- Increase randomness in the number of conditions

    for i = 1, numConditions do
        local newDepth = depth - math.random(1, 3)  -- Randomize depth decrement
        conditions[i] = self:generateDeeplyNestedObfuscatedConditionWithFunctionCalls(newDepth)
    end

    return function()
        local result = math.random() > 0.5  -- Start with a random boolean value
        for i = 1, #conditions do
            local op = math.random(1, 3)
            if op == 1 then
                result = result and conditions[i]()
            elseif op == 2 then
                result = result or conditions[i]()
            else
                result = result ~= conditions[i]()
            end
            -- Introduce random delays and no-op function calls
            if math.random() > 0.7 then
                for j = 1, math.random(1, 5) do
                    local noop = function() end
                    noop()
                end
            end
        end
        return result
    end
end

-- generateDynamicCondition
function ControlFlowObfuscator:generateDynamicCondition()
    local conditions = {}
    local operators = {"and", "or"}
    
    -- Generate a random number of conditions between 5 and 50
    for i = 1, math.random(5, 50) do
        local conditionType = math.random(1, 3)
        if conditionType == 1 then
            conditions[i] = function() return math.random() > 0.5 end
        elseif conditionType == 2 then
            conditions[i] = function() return math.random(1, 100) % 2 == 0 end
        else
            conditions[i] = function() return math.random(1, 100) > 50 end
        end
    end
    
    return function()
        local result = conditions[1]()
        for i = 2, #conditions do
            local operator = operators[math.random(1, #operators)]
            if operator == "and" then
                result = result and conditions[i]()
            else
                result = result or conditions[i]()
            end
        end
        return result
    end
end

-- Enhanced eqmutate
function ControlFlowObfuscator:eqmutate()
    local operators = {
        "==", "~=", "<", ">", "<=", ">=", "and", "or", "not", "xor",
        "math.random() < 0.5 and", "math.random() > 0.5 or",
        "math.random() < 0.5 and math.random() > 0.5 or",
        "|", "&", "<<", ">>", "^^",
        "math.random() < 0.5 and math.random() > 0.5 or math.random() < 0.5",
        "math.random() > 0.5 and math.random() < 0.5 or math.random() > 0.5"
    }
    local randomOperator = operators[math.random(#operators)]
    local nestedOperator = operators[math.random(#operators)]
    return randomOperator .. " " .. nestedOperator
end

-- Enhanced inlining
function ControlFlowObfuscator:inlining()
    local funcs = {
        "math.random()", "math.sin(math.random())", "math.cos(math.random())",
        "math.tan(math.random())", "math.abs(math.random())", "math.sqrt(math.random())",
        "math.log(math.random())", "math.exp(math.random())", "math.pow(math.random(), math.random())",
        "math.sin(math.cos(math.random()))", "math.random() * math.random()",
        "math.random() / (math.random() + 1)", "math.random() - math.random()",
        "math.random() + math.random()", "math.random() ^ math.random()",
        "math.random() % math.random()"
    }
    local randomFunc = funcs[math.random(#funcs)]
    local nestedFunc = funcs[math.random(#funcs)]
    return "function() return " .. randomFunc .. " + " .. nestedFunc .. " end"
end

-- Enhanced numberMutation
function ControlFlowObfuscator:numberMutation(depth)
    depth = depth or 0
    if self.numberMemo[depth] then return self.numberMemo[depth] end
    if depth > self.maxDepth then
        self.numberMemo[depth] = math.random() * math.random(1, 1000) * math.sin(math.random()) + math.random(1, 100) ^ 2
        return self.numberMemo[depth]
    end
    local operation = math.random(1, 3)
    if operation == 1 then
        self.numberMemo[depth] = self:numberMutation(depth + 2) * math.random()
    elseif operation == 2 then
        self.numberMemo[depth] = self:numberMutation(depth + 2) + math.random()
    else
        self.numberMemo[depth] = self:numberMutation(depth + 2) ^ math.random()
    end
    return self.numberMemo[depth]
end

-- Enhanced bounce with more dynamic conditions
function ControlFlowObfuscator:bounce()
    local condition = self:generateNestedObfuscatedCondition(math.random(1, self.maxDepth))
    if type(condition) == "function" then
        condition = condition()
    end
    local randomCondition = "math.random() > 0.5 or math.random() < 0.5"
    local complexCondition = "not " .. tostring(condition) .. " and " .. randomCondition
    if math.random() > 0.5 then
        complexCondition = complexCondition .. " or math.random() > 0.25"
    else
        complexCondition = complexCondition .. " and math.random() < 0.75"
    end
    return complexCondition
end

return ControlFlowObfuscator