local function checkType(var)
    if type(var) == "number" then
        return "Variable is a number"
    elseif type(var) == "string" then
        return "Variable is a string"
    elseif type(var) == "table" then
        return "Variable is a table"
    elseif type(var) == "boolean" then
        return "Variable is a boolean"
    else
        return "Variable is of unknown type"
    end
end

print(checkType(10)) -- Output: Variable is a number
print(checkType("Hello")) -- Output: Variable is a string
print(checkType({1, 2, 3})) -- Output: Variable is a table
print(checkType(true)) -- Output: Variable is a boolean
print(checkType(function() end)) -- Output: Variable is of unknown type
