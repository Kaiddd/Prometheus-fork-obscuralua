unpack = unpack or table.unpack;
local random = math.random
local log = math.log

local Step = require("Prometheus.step");
local Ast = require("Prometheus.ast");
local visitast = require("Prometheus.visitast");
local util = require("Prometheus.util")
local AstKind = Ast.AstKind;

local NumbersToExpressions = Step:extend();
NumbersToExpressions.Description = "This Step Converts number Literals to Expressions";
NumbersToExpressions.Name = "Numbers To Expressions";

NumbersToExpressions.SettingsDescriptor = {
    Treshold = {
        type = "number",
        default = 1,
        min = 0,
        max = 1,
    },
    InternalTreshold = {
        type = "number",
        default = 0.2,
        min = 0,
        max = 0.8,
    },
    MaxDepth = {
        type = "number",
        default = 50,
        min = 0,
        max = 100,
    },
    Range = {
        type = "number",
        default = 30,
        min = 0,
        max = 100,
    }
}

function NumbersToExpressions:init(settings)
    self.ExpressionGenerators = {
        function(val, depth)                       -- Addition
            local range = 2 ^ (self.Range - depth) -- Varying range based on depth
            local val2 = math.random(-range, range);
            local diff = val - val2;
            if tonumber(tostring(diff)) + tonumber(tostring(val2)) ~= val then
                return false;
            end
            return Ast.AddExpression(self:CreateNumberExpression(val2, depth), self:CreateNumberExpression(diff, depth),
                false);
        end,
        function(val, depth)                       -- Subtraction
            local range = 2 ^ (self.Range - depth) -- Varying range based on depth
            local val2 = math.random(-range, range);
            local diff = val + val2;
            if tonumber(tostring(diff)) - tonumber(tostring(val2)) ~= val then
                return false;
            end
            return Ast.SubExpression(self:CreateNumberExpression(diff, depth), self:CreateNumberExpression(val2, depth),
                false);
        end,
        function(val, depth)                       -- Multiplication
            local range = 2 ^ (self.Range - depth) -- Varying range based on depth
            local val2 = math.random(1, range);
            local product = val / val2;
            if tonumber(tostring(product)) * tonumber(tostring(val2)) ~= val then
                return false;
            end
            return Ast.MulExpression(self:CreateNumberExpression(val2, depth),
                self:CreateNumberExpression(product, depth), false);
        end,
        function(val, depth)                       -- Division
            local range = 2 ^ (self.Range - depth) -- Varying range based on depth
            local val2 = math.random(1, range);
            local quotient = val * val2;
            if tonumber(tostring(quotient)) / tonumber(tostring(val2)) ~= val then
                return false;
            end
            return Ast.DivExpression(self:CreateNumberExpression(quotient, depth),
                self:CreateNumberExpression(val2, depth), false);
        end,
        function(val, depth)                       -- Exponential
            if val <= 1 then return false end    -- Exponential results are meaningful for values greater than 1
            for base = 2, 10 do                  -- Iterate through possible bases
                local exponent = math.log(val) / math.log(base)
                if exponent == math.floor(exponent) then -- Check for a perfect power
                    return Ast.PowExpression(self:CreateNumberExpression(base, depth),
                        self:CreateNumberExpression(exponent, depth), false)
                end
            end
            return false -- Return false if no perfect power is found
        end,
        function(val, depth)                       -- Modulo
            for divisor = 2, 10 do                                       -- Iterate through possible divisors
                if val % divisor ~= 0 then                               -- Ensure the divisor does not evenly divide the value
                    local dividend = val * divisor + math.random(1, divisor - 1) -- Ensure a non-trivial dividend
                    return Ast.ModExpression(self:CreateNumberExpression(dividend, depth),
                        self:CreateNumberExpression(divisor, depth), false)
                end
            end
            return false -- Return false if no suitable divisor is found
        end,
        function(val, depth)                       -- Trigonometric (Sine and Arcsine)
            if val < 0 or val > 1 then return false end -- Sine and arcsine are meaningful in this range for obfuscation
            local angle = math.asin(val)
            local sine = math.sin(angle)
            if math.abs(sine - val) > 0.0001 then return false end -- Precision check
            return Ast.SinExpression(self:CreateNumberExpression(angle, depth), false)
        end,
    }
    
    self.ExpressionGenerators = util.shuffle(self.ExpressionGenerators)
    self.cachedExpressionGenerators = self.ExpressionGenerators
end


-- Incorporate conditional expressions based on the parity of the number
function NumbersToExpressions:encodeDecodeNumber(val)
    -- Enhanced encoding using multiple steps and operations
    local step1 = (val * 12345) + 67890
    local step2 = step1 ^ 2 -- Squaring as an additional step
    local encoded = step2 - 13579

    -- Decoding function reflecting the encoding steps
    return encoded, function(depth)
        local step2Expr = Ast.SubExpression(Ast.NumberExpression(encoded), Ast.NumberExpression(13579), false)
        local step1Expr = Ast.PowExpression(step2Expr, Ast.NumberExpression(0.5), false) -- Square root for decoding
        local subExpr = Ast.SubExpression(step1Expr, Ast.NumberExpression(67890), false)
        local divExpr = Ast.DivExpression(subExpr, Ast.NumberExpression(12345), false)
        return divExpr
    end
end

function NumbersToExpressions:CreateConditionalExpression(val, depth)
    -- More complex conditional based on divisibility and presence of certain digits
    local isDivisibleBy3 = val % 3 == 0
    local containsSeven = tostring(val):find('7') ~= nil

    local encodedVal, decodeFunc = self:encodeDecodeNumber(val)
    local conditionalExpr

    if isDivisibleBy3 then
        -- Use a trigonometric operation for numbers divisible by 3
        local angle = math.pi / 6 -- 30 degrees, for example
        conditionalExpr = Ast.SinExpression(Ast.NumberExpression(angle), false)
    elseif containsSeven then
        -- Use a modulo operation for numbers containing the digit 7
        conditionalExpr = Ast.ModExpression(Ast.NumberExpression(encodedVal), Ast.NumberExpression(7), false)
    else
        -- Fallback to a simple addition for other numbers
        conditionalExpr = Ast.AddExpression(Ast.NumberExpression(encodedVal), Ast.NumberExpression(1), false)
    end

    local decodeExpr = decodeFunc(depth)
    return Ast.AddExpression(conditionalExpr, decodeExpr, false)
end

function NumbersToExpressions:generateOperationChain(val, depth)
    -- Dynamically adjust operations based on the number's characteristics
    local operations = {
        function(x) return x ^ 2, function(y) return math.sqrt(y) end end, -- Square and square root
        function(x) return x * math.pi, function(y) return y / math.pi end end, -- Multiply and divide by pi
    }

    local operationCount = math.min(depth, 3) -- Limit the operation count based on depth
    local currentVal = val
    local exprStack = {}

    for i = 1, operationCount do
        local opIndex = (currentVal % #operations) + 1 -- Select operation based on current value
        local operation, inverseOperation = operations[opIndex](currentVal)
        table.insert(exprStack, inverseOperation)
        currentVal = operation
    end

    local finalExpr = Ast.NumberExpression(currentVal)
    for i = #exprStack, 1, -1 do
        finalExpr = exprStack[i](finalExpr)
    end

    return finalExpr
end


-- Modify the CreateNumberExpression function to use generateOperationChain for creating complex expressions
function NumbersToExpressions:CreateNumberExpression(val, depth)
    if val == nil then
        return
    end

    if depth > 0 and random() >= self.InternalTreshold * 0.1 or depth > self.MaxDepth then
        return self:generateOperationChain(val, depth)
    end

    -- Use conditional expressions based on certain criteria (e.g., parity)
    local conditionalExpression = self:CreateConditionalExpression(val, depth)
    if conditionalExpression then
        return conditionalExpression
    end

    for i, generator in ipairs(self.cachedExpressionGenerators) do
        local encodedVal, decodeFunc = self:encodeDecodeNumber(val)
        local node = generator(encodedVal, depth + 1); -- Use encoded value for generation
        if node then
            -- Wrap the generated node with the decoding expression
            local decodeExpr = decodeFunc(depth + 1)
            return Ast.AddExpression(node, decodeExpr, false)
        end
    end

    -- Allow nested expressions
    local encodedVal, decodeFunc = self:encodeDecodeNumber(val)
    local nestedExpression = self:CreateNumberExpression(random(), depth + 1)
    if nestedExpression then
        local decodeExpr = decodeFunc(depth + 1)
        return Ast.AddExpression(Ast.NumberExpression(encodedVal), Ast.AddExpression(nestedExpression, decodeExpr, false), false)
    end

    local _, decodeFunc = self:encodeDecodeNumber(val)
    return decodeFunc(depth) -- Return just the decoding expression if all else fails
end

function NumbersToExpressions:apply(ast)
    local function isNumberExpression(node)
        return node.kind == AstKind.NumberExpression
    end

    visitast(ast, function(node)
        if isNumberExpression(node) then
            while random() < self.Treshold do
                local newNode = self:CreateNumberExpression(node.value, 0)
                if newNode then
                    node = newNode
                else
                    break
                end
            end
        end
    end)
end

return NumbersToExpressions;