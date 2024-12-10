-- function_test.lua
function add(a, b)
    return a + b
end

function test_function()
    assert(add(2, 2) == 4, "Function call failed")
end

test_function()
print("Function test passed")