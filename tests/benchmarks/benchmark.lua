print("Custom Benchmark")
local Iterations = 100000
print("Iterations: " .. tostring(Iterations))

local tests = {
    ["CLOSURE"] = function()
        for Idx = 1, Iterations do
            (function()
                if not true then
                    print("Hey gamer.")
                end
            end)()
        end
    end,
    ["SETTABLE"] = function()
        local T = {}
        for Idx = 1, Iterations do
            T[tostring(Idx)] = "EPIC GAMER " .. tostring(Idx)
        end
    end,
    ["GETTABLE"] = function()
        local T = {}
        for Idx = 1, Iterations do
            T[1] = T[tostring(Idx)]
        end
    end,
    ["FUNCTION CALL"] = function()
        local function foo() end
        for Idx = 1, Iterations do
            foo()
        end
    end,
    ["ARITHMETIC"] = function()
        local a = 0
        for Idx = 1, Iterations do
            a = a + Idx
        end
    end,
    ["STRING MANIPULATION"] = function()
        local s = ""
        for Idx = 1, Iterations do
            s = s .. tostring(Idx)
        end
    end,
}

local totalStart = os.time()
for testName, testFunc in pairs(tests) do
    print(testName .. " testing.")
    local start = os.time()
    testFunc()
    print("Time:", os.time() - start .. "s")
end
print("Total Time:", os.time() - totalStart .. "s")