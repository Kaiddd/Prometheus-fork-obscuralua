local function runScript(script)
    local func = loadstring(script)
    return func()
end

-- Test scripts
local tests = {
    {
        script = "return 1 + 1",
        expectedOutput = 2
    },
    {
        script = "return 'Hello, world!'",
        expectedOutput = "Hello, world!"
    },
    {
        script = "return math.sqrt(16)",
        expectedOutput = 4
    },
}

-- Run tests
for i, test in ipairs(tests) do
    print("Running test " .. i .. "...")
	local output = runScript(test.script)

    assert(output == test.expectedOutput, "Test " .. i .. " failed: expected " .. tostring(test.expectedOutput) .. ", got " .. tostring(output))
    print("Test " .. i .. " passed")
end

print("All tests passed")