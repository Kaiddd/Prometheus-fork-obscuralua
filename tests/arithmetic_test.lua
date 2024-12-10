-- arithmetic_test.lua
function test_arithmetic()
    assert(2 + 2 == 4, "Addition failed")
    assert(2 - 2 == 0, "Subtraction failed")
    assert(2 * 2 == 4, "Multiplication failed")
    assert(2 / 2 == 1, "Division failed")
end

test_arithmetic()
print("Arithmetic test passed")