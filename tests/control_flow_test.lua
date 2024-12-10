-- control_flow_test.lua
function test_control_flow()
    local a = 10
    if a > 5 then
        assert(true, "If statement failed")
    else
        assert(false, "If statement failed")
    end

    for i = 1, 10 do
        a = a - 1
    end
    assert(a == 0, "For loop failed")
end

test_control_flow()
print("Control flow test passed")