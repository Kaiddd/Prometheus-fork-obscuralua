-- table_test.lua
function test_table()
    local t = {1, 2, 3}
    assert(#t == 3, "Table length failed")
    table.insert(t, 4)
    assert(#t == 4, "Table insert failed")
    table.remove(t, 1)
    assert(#t == 3 and t[1] == 2, "Table remove failed")
end

test_table()
print("Table test passed")