local Old = setmetatable
local SUnpack = table.unpack

function OnTable(Table, Value)
    for i, v in pairs(Table) do
        if v == Value then
            return true
        end
    end

    return false
end

local BlackList = {
    "__index",
    "__gc",
    "__len",
    "table",
    "math",
    "math",
    "floor",
    "char",
    "remove",
    "random",
    "string"
}

local TempFunction = function(Table, NewFunctions)
    local __Index = rawget(NewFunctions, "__index")
    if __Index then
        local __IndexMod = function(self, Value)
            if type(__Index) == "table" then
                local Result = __Index[Value]
                if OnTable(__Index, "__gc") and OnTable(__Index, "__metatable") == false then
                    local New = {}
                    for i, v in pairs(__Index) do
                        if OnTable(BlackList, v) == false then
                            table.insert(New, v)
                        end
                    end
                    if #New > 2 and New[1] ~= "math" then
                        print("New Dump", New)
                        for key, value in pairs(New) do
                            print("\tKey:", key, "Value:", value)
                        end
                    end
                end
                return Result
            elseif type(__Index) == "function" then
                return __Index(self, Value)
            end
        end

        local Clone = NewFunctions
        rawset(Clone, "__index", __IndexMod)

        return Old(Table, Clone)
    end

    return Old(Table, NewFunctions)
end

getfenv().setmetatable = coroutine.wrap(function(...)
    local args = { ... }
    while true do
        args = { coroutine.yield(TempFunction(unpack(args))) }
    end
end)

require = coroutine.wrap(function(...)
    local args = { ... }
    while true do
        args = { coroutine.yield(TempFunction(unpack(args))) }
    end
end)